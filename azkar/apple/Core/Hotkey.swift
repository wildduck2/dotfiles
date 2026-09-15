import Foundation

/// A global shortcut in Carbon terms (virtual key code + modifier mask).
struct Hotkey: Equatable {
  var keyCode: UInt32
  var modifiers: UInt32
  var display: String

  // Carbon modifier masks (cmdKey, shiftKey, optionKey, controlKey), in the order macOS displays them.
  private static let modifierOrder: [(mask: UInt32, symbol: String, names: [String])] = [
    (4096, "⌃", ["ctrl", "control"]),
    (2048, "⌥", ["alt", "opt", "option"]),
    (512, "⇧", ["shift"]),
    (256, "⌘", ["cmd", "command"]),
  ]

  // kVK_* virtual key codes (Carbon/HIToolbox Events.h).
  private static let keyCodes: [String: UInt32] = [
    "a": 0x00, "s": 0x01, "d": 0x02, "f": 0x03, "h": 0x04, "g": 0x05, "z": 0x06, "x": 0x07,
    "c": 0x08, "v": 0x09, "b": 0x0B, "q": 0x0C, "w": 0x0D, "e": 0x0E, "r": 0x0F, "y": 0x10,
    "t": 0x11, "1": 0x12, "2": 0x13, "3": 0x14, "4": 0x15, "6": 0x16, "5": 0x17, "=": 0x18,
    "9": 0x19, "7": 0x1A, "-": 0x1B, "8": 0x1C, "0": 0x1D, "]": 0x1E, "o": 0x1F, "u": 0x20,
    "[": 0x21, "i": 0x22, "p": 0x23, "l": 0x25, "j": 0x26, "'": 0x27, "k": 0x28, ";": 0x29,
    "\\": 0x2A, ",": 0x2B, "/": 0x2C, "n": 0x2D, "m": 0x2E, ".": 0x2F, "`": 0x32,
    "return": 0x24, "tab": 0x30, "space": 0x31, "delete": 0x33, "escape": 0x35,
    "f1": 0x7A, "f2": 0x78, "f3": 0x63, "f4": 0x76, "f5": 0x60, "f6": 0x61,
    "f7": 0x62, "f8": 0x64, "f9": 0x65, "f10": 0x6D, "f11": 0x67, "f12": 0x6F,
  ]

  private static let keyLabels: [String: String] = [
    "return": "↩", "tab": "⇥", "space": "Space", "delete": "⌫", "escape": "⎋",
  ]

  /// Parses "ctrl+alt+z": one or more modifiers plus exactly one key, case-insensitive.
  static func parse(_ s: String) -> Hotkey? {
    var mods: UInt32 = 0
    var key: String?
    for part in s.lowercased().split(separator: "+").map({ $0.trimmingCharacters(in: .whitespaces) }) {
      if let m = modifierOrder.first(where: { $0.names.contains(part) }) {
        mods |= m.mask
      } else if key == nil, keyCodes[part] != nil {
        key = part
      } else {
        return nil
      }
    }
    guard mods != 0, let key, let code = keyCodes[key] else { return nil }
    let symbols = modifierOrder.filter { mods & $0.mask != 0 }.map(\.symbol).joined()
    return Hotkey(keyCode: code, modifiers: mods, display: symbols + (keyLabels[key] ?? key.uppercased()))
  }

  /// A key press (virtual key code + Carbon modifier mask), e.g. from the shortcut recorder.
  static func from(keyCode: UInt32, modifiers: UInt32) -> Hotkey? {
    guard let key = keyCodes.first(where: { $0.value == keyCode })?.key else { return nil }
    let mods = modifierOrder.filter { modifiers & $0.mask != 0 }.map { $0.names[0] }
    return parse((mods + [key]).joined(separator: "+"))
  }

  /// Canonical "ctrl+alt+z" form, as written to config.json.
  var spec: String {
    let mods = Self.modifierOrder.filter { modifiers & $0.mask != 0 }.map { $0.names[0] }
    let key = Self.keyCodes.first { $0.value == keyCode }?.key ?? "?"
    return (mods + [key]).joined(separator: "+")
  }
}
