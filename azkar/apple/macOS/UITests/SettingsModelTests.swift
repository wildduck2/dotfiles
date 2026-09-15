import AppKit
import Carbon.HIToolbox

@MainActor
func settingsModelTests() {
  // Settings: every switch, time picker and the shortcut recorder write straight into the config.
  var saved: [Config] = []
  let model = SettingsModel(config: Config())
  model.onConfigChange = { saved.append($0) }

  model.config.sabah = TimeWindow(start: 240, end: 600)
  model.setEnabled(\.sabah, false)
  eq(model.config.sabah, nil, "switching the morning window off")
  model.setEnabled(\.sabah, true)
  eq(model.config.sabah, TimeWindow(start: 240, end: 600), "switching it back on restores its times")

  let offAtLaunch = SettingsModel(
    config: {
      var c = Config()
      c.masaa = nil
      return c
    }())
  offAtLaunch.setEnabled(\.masaa, true)
  eq(offAtLaunch.config.masaa, Config().masaa, "a window that started off comes back with the default times")

  let half4 = Calendar.current.date(bySettingHour: 4, minute: 30, second: 0, of: Date())!
  model.setTime(\.sabah, start: true, to: half4)
  eq(model.config.sabah, TimeWindow(start: 270, end: 600), "the start picker sets the start time")
  eq(minuteOfDay(model.time(\.sabah, start: true), .current), 270, "and shows it back")
  let ten30 = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date())!
  model.setTime(\.quietHours, start: false, to: ten30)
  eq(model.config.quietHours?.end, 1350, "the end picker sets the end time")

  check(model.record(keyCode: UInt16(kVK_ANSI_K), flags: [.command, .shift]), "records ⇧⌘K")
  eq(model.config.hotkey.spec, "shift+cmd+k", "recorded shortcut is saved")
  check(!model.record(keyCode: UInt16(kVK_ANSI_K), flags: []), "a key without a modifier is rejected")
  eq(model.config.hotkey.spec, "shift+cmd+k", "a rejected recording keeps the old shortcut")

  eq(saved.last, model.config, "every change is handed to the app to save")
  let before = saved.count
  model.sync(config: Config())
  eq(model.config, Config(), "the app can push a reloaded config into the window")
  eq(saved.count, before, "without it being saved back again")
}
