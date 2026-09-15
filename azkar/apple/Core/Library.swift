// azkar.json: the morning, evening and general lists.
import Foundation

struct Zikr: Codable, Equatable {
  var text: String
  var count: Int
  var note: String?
  var ref: Int?

  init(text: String, count: Int, note: String?, ref: Int?) {
    self.text = text
    self.count = count
    self.note = note
    self.ref = ref
  }

  /// `count` may be omitted in azkar.json (defaults to 1).
  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    text = try c.decode(String.self, forKey: .text)
    count = try c.decodeIfPresent(Int.self, forKey: .count) ?? 1
    note = try c.decodeIfPresent(String.self, forKey: .note)
    ref = try c.decodeIfPresent(Int.self, forKey: .ref)
  }
}

struct Library: Codable, Equatable {
  var sabah: [Zikr]
  var masaa: [Zikr]
  var general: [Zikr]

  init(sabah: [Zikr], masaa: [Zikr], general: [Zikr]) {
    self.sabah = sabah
    self.masaa = masaa
    self.general = general
  }

  /// Any of the three lists may be omitted.
  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    sabah = try c.decodeIfPresent([Zikr].self, forKey: .sabah) ?? []
    masaa = try c.decodeIfPresent([Zikr].self, forKey: .masaa) ?? []
    general = try c.decodeIfPresent([Zikr].self, forKey: .general) ?? []
  }

  static func decode(_ data: Data) throws -> Library {
    do {
      return try JSONDecoder().decode(Library.self, from: data)
    } catch DecodingError.dataCorrupted(let ctx) {
      throw ConfigError("not valid JSON (\(ctx.underlyingError?.localizedDescription ?? ctx.debugDescription))")
    } catch DecodingError.keyNotFound(let key, let ctx) {
      throw ConfigError("missing \"\(key.stringValue)\" at \(path(ctx))")
    } catch DecodingError.typeMismatch(_, let ctx) {
      throw ConfigError("\(ctx.debugDescription) at \(path(ctx))")
    } catch DecodingError.valueNotFound(_, let ctx) {
      throw ConfigError("\(ctx.debugDescription) at \(path(ctx))")
    }
  }

  private static func path(_ ctx: DecodingError.Context) -> String {
    ctx.codingPath.map { $0.intValue.map { "[\($0)]" } ?? ".\($0.stringValue)" }.joined()
  }
}
