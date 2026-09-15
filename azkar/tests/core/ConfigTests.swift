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
}
