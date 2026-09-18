// config.json: decoding (missing keys keep their defaults) and the canonical form the settings
// window writes.
import Foundation

enum Order: String { case random, sequential }

struct ConfigError: Error, CustomStringConvertible {
  let description: String
  init(_ description: String) { self.description = description }
}

/// What went wrong with a file, in words a person can act on.
func message(_ error: Error) -> String {
  (error as? ConfigError)?.description ?? error.localizedDescription
}

struct Config: Equatable {
  var intervalMinutes: Double = 3
  var hotkey = Hotkey.parse("ctrl+alt+z")!
  var order: Order = .random
  /// Off: general azkar are one tap each. On: they keep their full count (e.g. ×100).
  var repeatGeneral = false
  var maxStack = 5
  var sabah: TimeWindow? = TimeWindow(start: 5 * 60, end: 11 * 60)
  var masaa: TimeWindow? = TimeWindow(start: 15 * 60 + 30, end: 21 * 60)
  var quietHours: TimeWindow? = TimeWindow(start: 23 * 60 + 30, end: 5 * 60)
  var fontSize: Double = 22
  /// Play a sound when a new card appears.
  var sound = false
  /// "📿 3" in the menu bar while cards are waiting.
  var showCount = true
  /// Start at login (a LaunchAgent), in the background.
  var openAtLogin = true
  /// Also open the window when starting at login.
  var showWindowAtLogin = false

  /// JSONSerialization returns booleans as NSNumber too, so `true as? Double` is 1. Only real numbers count.
  private static func isNumber(_ v: Any) -> Bool {
    guard let n = v as? NSNumber else { return false }
    return CFGetTypeID(n) != CFBooleanGetTypeID()
  }

  /// Missing keys keep their defaults; `null` disables a time window.
  static func decode(_ data: Data) throws -> Config {
    let json: Any
    do {
      json = try JSONSerialization.jsonObject(with: data)
    } catch {
      throw ConfigError("not valid JSON (\(error.localizedDescription))")
    }
    guard let dict = json as? [String: Any] else { throw ConfigError("must be a JSON object") }

    var c = Config()
    if let v = dict["intervalMinutes"] {
      guard isNumber(v), let n = v as? Double, n > 0 else { throw ConfigError("intervalMinutes must be a number > 0") }
      c.intervalMinutes = n
    }
    if let v = dict["maxStack"] {
      guard isNumber(v), let n = v as? Int, n >= 1 else { throw ConfigError("maxStack must be a whole number >= 1") }
      c.maxStack = n
    }
    if let v = dict["hotkey"] {
      guard let s = v as? String, let hk = Hotkey.parse(s) else {
        throw ConfigError("hotkey \(v) is not valid, use e.g. \"ctrl+alt+z\"")
      }
      c.hotkey = hk
    }
    if let v = dict["order"] {
      guard let s = v as? String, let o = Order(rawValue: s) else {
        throw ConfigError("order must be \"random\" or \"sequential\"")
      }
      c.order = o
    }
    let switches: [(String, WritableKeyPath<Config, Bool>)] = [
      ("repeatGeneral", \.repeatGeneral), ("sound", \.sound), ("showCount", \.showCount),
      ("openAtLogin", \.openAtLogin), ("showWindowAtLogin", \.showWindowAtLogin),
    ]
    for (key, path) in switches {
      guard let v = dict[key] else { continue }
      guard let b = v as? NSNumber, CFGetTypeID(b) == CFBooleanGetTypeID() else {
        throw ConfigError("\(key) must be true or false")
      }
      c[keyPath: path] = b.boolValue
    }
    if let v = dict["fontSize"] {
      guard isNumber(v), let n = v as? Double, n > 0 else { throw ConfigError("fontSize must be a number > 0") }
      c.fontSize = n
    }
    for (key, path) in [("sabah", \Config.sabah), ("masaa", \Config.masaa), ("quietHours", \Config.quietHours)] {
      guard let v = dict[key] else { continue }
      if v is NSNull {
        c[keyPath: path] = nil
        continue
      }
      guard let w = v as? [String: Any],
        let s = (w["start"] as? String).flatMap(parseClock),
        let e = (w["end"] as? String).flatMap(parseClock)
      else {
        throw ConfigError("\(key) must be null or {\"start\": \"HH:mm\", \"end\": \"HH:mm\"}")
      }
      c[keyPath: path] = TimeWindow(start: s, end: e)
    }
    return c
  }

  /// The config.json the settings window writes, in the same layout as the shipped file.
  func encode() -> Data {
    func number(_ n: Double) -> String { n == n.rounded() && abs(n) < 1e15 ? String(Int(n)) : String(n) }
    func string(_ s: String) -> String {
      "\"" + s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
    }
    func window(_ w: TimeWindow?) -> String {
      guard let w else { return "null" }
      return "{ \"start\": \(string(formatClock(w.start))), \"end\": \(string(formatClock(w.end))) }"
    }
    let fields = [
      ("intervalMinutes", number(intervalMinutes)),
      ("hotkey", string(hotkey.spec)),
      ("order", string(order.rawValue)),
      ("repeatGeneral", String(repeatGeneral)),
      ("maxStack", String(maxStack)),
      ("sabah", window(sabah)),
      ("masaa", window(masaa)),
      ("quietHours", window(quietHours)),
      ("fontSize", number(fontSize)),
      ("sound", String(sound)),
      ("showCount", String(showCount)),
      ("openAtLogin", String(openAtLogin)),
      ("showWindowAtLogin", String(showWindowAtLogin)),
    ]
    let body = fields.map { "  \"\($0.0)\": \($0.1)" }.joined(separator: ",\n")
    return Data("{\n\(body)\n}\n".utf8)
  }
}
