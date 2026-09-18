import Foundation

func configTests() {
  do {
    let c = try Config.decode(Data("{}".utf8))
    eq(c, Config(), "empty config uses defaults")
    eq(c.intervalMinutes, 3, "default interval")
    eq(c.maxStack, 5, "default max stack")
    eq(c.order, .random, "default order")
    eq(c.hotkey, Hotkey.parse("ctrl+alt+z"), "default hotkey")
    eq(c.sabah, TimeWindow(start: 300, end: 660), "default sabah window")
    eq(c.masaa, TimeWindow(start: 930, end: 1260), "default masaa window")
    eq(c.quietHours, TimeWindow(start: 1410, end: 300), "default quiet hours")
    eq(c.repeatGeneral, false, "general azkar are one tap by default")
  } catch {
    failed += 1
    print("FAIL empty config threw \(error)")
  }

  do {
    eq(try Config.decode(Data(#"{"repeatGeneral": true}"#.utf8)).repeatGeneral, true, "repeatGeneral override")
  } catch {
    failed += 1
    print("FAIL repeatGeneral threw \(error)")
  }
  expectError("repeatGeneral must be a bool", mentioning: "repeatGeneral") {
    _ = try Config.decode(Data(#"{"repeatGeneral": 1}"#.utf8))
  }

  // the General page's switches
  do {
    let c = Config()
    eq(c.openAtLogin, true, "starts at login by default")
    eq(c.showWindowAtLogin, false, "starts quietly in the menu bar by default")
    eq(c.showCount, true, "shows the card count next to 📿 by default")
    eq(c.sound, false, "no sound by default")
    let json = #"{"openAtLogin": false, "showWindowAtLogin": true, "showCount": false, "sound": true}"#
    let o = try Config.decode(Data(json.utf8))
    eq(o.openAtLogin, false, "openAtLogin override")
    eq(o.showWindowAtLogin, true, "showWindowAtLogin override")
    eq(o.showCount, false, "showCount override")
    eq(o.sound, true, "sound override")
  } catch {
    failed += 1
    print("FAIL general switches threw \(error)")
  }
  for key in ["openAtLogin", "showWindowAtLogin", "showCount", "sound"] {
    expectError("\(key) must be a bool", mentioning: key) {
      _ = try Config.decode(Data(#"{"\#(key)": "yes"}"#.utf8))
    }
  }

  do {
    let json =
      #"{"intervalMinutes": 0.5, "order": "sequential", "quietHours": null, "sabah": {"start": "04:30", "end": "10:00"}}"#
    let c = try Config.decode(Data(json.utf8))
    eq(c.intervalMinutes, 0.5, "interval override")
    eq(c.order, .sequential, "order override")
    eq(c.quietHours, nil, "null disables quiet hours")
    eq(c.sabah, TimeWindow(start: 270, end: 600), "sabah override")
    eq(c.masaa, Config().masaa, "unspecified keys keep defaults")
  } catch {
    failed += 1
    print("FAIL partial config threw \(error)")
  }

  expectError("zero interval", mentioning: "intervalMinutes") {
    _ = try Config.decode(Data(#"{"intervalMinutes": 0}"#.utf8))
  }
  expectError("zero max stack", mentioning: "maxStack") { _ = try Config.decode(Data(#"{"maxStack": 0}"#.utf8)) }
  expectError("bad hotkey", mentioning: "hotkey") { _ = try Config.decode(Data(#"{"hotkey": "ctrl+foo"}"#.utf8)) }
  expectError("bad order", mentioning: "order") { _ = try Config.decode(Data(#"{"order": "shuffle"}"#.utf8)) }
  expectError("bad clock", mentioning: "sabah") {
    _ = try Config.decode(Data(#"{"sabah": {"start": "25:00", "end": "11:00"}}"#.utf8))
  }
  expectError("not json", mentioning: "JSON") { _ = try Config.decode(Data("{nope".utf8)) }

  // JSON booleans and strings are not numbers; whole numbers may be written with a fraction or an exponent.
  expectError("a boolean is not an interval", mentioning: "intervalMinutes") {
    _ = try Config.decode(Data(#"{"intervalMinutes": true}"#.utf8))
  }
  expectError("a boolean is not a max stack", mentioning: "maxStack") {
    _ = try Config.decode(Data(#"{"maxStack": true}"#.utf8))
  }
  expectError("a boolean is not a font size", mentioning: "fontSize") {
    _ = try Config.decode(Data(#"{"fontSize": true}"#.utf8))
  }
  expectError("a string is not a number", mentioning: "fontSize") {
    _ = try Config.decode(Data(#"{"fontSize": "22"}"#.utf8))
  }
  do {
    eq(try Config.decode(Data(#"{"maxStack": 3.0}"#.utf8)).maxStack, 3, "3.0 is a whole number")
    eq(try Config.decode(Data(#"{"maxStack": 1e2}"#.utf8)).maxStack, 100, "1e2 is a whole number")
  } catch {
    failed += 1
    print("FAIL whole numbers threw \(error)")
  }

  // encoding (what the settings window writes)
  do {
    var c = Config()
    c.intervalMinutes = 0.5
    c.hotkey = Hotkey.parse("cmd+shift+f5")!
    c.order = .sequential
    c.repeatGeneral = true
    c.maxStack = 2
    c.sabah = nil
    c.masaa = TimeWindow(start: 1020, end: 1200)
    c.quietHours = nil
    c.fontSize = 26.5
    c.sound = true
    c.showCount = false
    c.openAtLogin = false
    c.showWindowAtLogin = true
    eq(try Config.decode(c.encode()), c, "encode round-trips through decode")
    let text = String(decoding: c.encode(), as: UTF8.self)
    check(text.contains(#""sabah": null"#), "a switched-off window is written as null")
    check(text.contains(#""masaa": { "start": "17:00", "end": "20:00" }"#), "windows are written as HH:mm")
    check(text.contains(#""intervalMinutes": 0.5"#), "fractional numbers keep their fraction")
    eq(try Config.decode(Config().encode()), Config(), "defaults round-trip")
  } catch {
    failed += 1
    print("FAIL encode round-trip threw \(error)")
  }

  // The exact bytes. kotlin/shared ConfigTest has the same text and number table, so both apps write the same file.
  let defaults = """
    {
      "intervalMinutes": 3,
      "hotkey": "ctrl+alt+z",
      "order": "random",
      "repeatGeneral": false,
      "maxStack": 5,
      "sabah": { "start": "05:00", "end": "11:00" },
      "masaa": { "start": "15:30", "end": "21:00" },
      "quietHours": { "start": "23:30", "end": "05:00" },
      "fontSize": 22,
      "sound": false,
      "showCount": true,
      "openAtLogin": true,
      "showWindowAtLogin": false
    }

    """
  eq(
    String(decoding: Config().encode(), as: UTF8.self), defaults, "defaults are written in the settings window's layout"
  )

  let numbers: [(Double, String)] = [
    (3, "3"), (0.5, "0.5"), (26.5, "26.5"), (0.1 + 0.2, "0.30000000000000004"), (0.0001, "0.0001"),
    (0.00001, "1e-05"), (1.5e-7, "1.5e-07"), (12345678.5, "12345678.5"), (99999999999999.5, "99999999999999.5"),
    (1e15, "1000000000000000.0"), (9_007_199_254_740_992, "9007199254740992.0"),
    (9_007_199_254_740_994, "9.007199254740994e+15"), (1.25e16, "1.25e+16"), (1e100, "1e+100"),
  ]
  for (n, text) in numbers {
    var c = Config()
    c.fontSize = n
    check(
      String(decoding: c.encode(), as: UTF8.self).contains("\n  \"fontSize\": \(text),\n"),
      "fontSize \(text) is written as Swift writes it")
  }
}
