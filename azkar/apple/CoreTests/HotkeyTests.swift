import Carbon.HIToolbox

func hotkeyTests() {
  let hk = Hotkey.parse("ctrl+alt+z")
  eq(hk?.keyCode, UInt32(kVK_ANSI_Z), "ctrl+alt+z key")
  eq(hk?.modifiers, UInt32(controlKey | optionKey), "ctrl+alt+z modifiers")
  eq(hk?.display, "⌃⌥Z", "ctrl+alt+z display")
  eq(Hotkey.parse("Command+Shift+1")?.modifiers, UInt32(cmdKey | shiftKey), "modifier names are case-insensitive")
  eq(Hotkey.parse("cmd+opt+control+space")?.keyCode, UInt32(kVK_Space), "aliases and named keys")
  eq(Hotkey.parse("z"), nil, "a hotkey needs a modifier")
  eq(Hotkey.parse("ctrl+foo"), nil, "unknown key")
  eq(Hotkey.parse("ctrl+alt"), nil, "a hotkey needs a key")
  eq(Hotkey.parse("ctrl+z+x"), nil, "only one key")
  eq(Hotkey.parse(" ctrl ++ z ")?.spec, "ctrl+z", "spaces and empty parts are ignored")
  eq(Hotkey.parse("Command+Shift+1")?.spec, "shift+cmd+1", "spec is normalized, in display order")
  eq(Hotkey.parse("ctrl+alt+z")?.spec, "ctrl+alt+z", "default spec")
  eq(
    Hotkey.from(keyCode: UInt32(kVK_ANSI_Z), modifiers: UInt32(controlKey | optionKey)), Hotkey.parse("ctrl+alt+z"),
    "a recorded key press becomes the same hotkey as its spec")
  eq(Hotkey.from(keyCode: UInt32(kVK_ANSI_Z), modifiers: 0), nil, "a recorded key press needs a modifier")
  eq(Hotkey.from(keyCode: 0x7F, modifiers: UInt32(cmdKey)), nil, "unknown key code")
  eq(
    Hotkey.from(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey | alphaLock))?.spec, "cmd+space",
    "other modifier bits (caps lock) are ignored")

  let ansi: [(String, Int)] = [
    ("a", kVK_ANSI_A), ("b", kVK_ANSI_B), ("c", kVK_ANSI_C), ("d", kVK_ANSI_D), ("e", kVK_ANSI_E),
    ("f", kVK_ANSI_F), ("g", kVK_ANSI_G), ("h", kVK_ANSI_H), ("i", kVK_ANSI_I), ("j", kVK_ANSI_J),
    ("k", kVK_ANSI_K), ("l", kVK_ANSI_L), ("m", kVK_ANSI_M), ("n", kVK_ANSI_N), ("o", kVK_ANSI_O),
    ("p", kVK_ANSI_P), ("q", kVK_ANSI_Q), ("r", kVK_ANSI_R), ("s", kVK_ANSI_S), ("t", kVK_ANSI_T),
    ("u", kVK_ANSI_U), ("v", kVK_ANSI_V), ("w", kVK_ANSI_W), ("x", kVK_ANSI_X), ("y", kVK_ANSI_Y),
    ("z", kVK_ANSI_Z), ("0", kVK_ANSI_0), ("1", kVK_ANSI_1), ("2", kVK_ANSI_2), ("3", kVK_ANSI_3),
    ("4", kVK_ANSI_4), ("5", kVK_ANSI_5), ("6", kVK_ANSI_6), ("7", kVK_ANSI_7), ("8", kVK_ANSI_8),
    ("9", kVK_ANSI_9), ("f1", kVK_F1), ("f5", kVK_F5), ("f12", kVK_F12), ("return", kVK_Return),
    ("escape", kVK_Escape), ("/", kVK_ANSI_Slash), (".", kVK_ANSI_Period), ("-", kVK_ANSI_Minus),
  ]
  for (name, code) in ansi {
    eq(Hotkey.parse("ctrl+\(name)")?.keyCode, UInt32(code), "key code for '\(name)'")
    let h = Hotkey.parse("ctrl+\(name)")
    eq(h.flatMap { Hotkey.parse($0.spec) }, h, "spec round-trips for '\(name)'")
  }
}
