// What the window shows and edits. Every change to `config` goes to the app, which applies it
// and writes config.json.
import AppKit
import Carbon.HIToolbox
import Combine

/// What the window shows about the running app; AppDelegate refreshes it every second while open.
struct AppStatus: Equatable {
  var paused = false
  var nextIn: Int?
  var lastSkip: String?
  var onScreen = 0
  var sabahDone = 0
  var sabahTotal = 0
  var masaaDone = 0
  var masaaTotal = 0
  var problems: [String] = []
  var hotkeyError: String?
}

enum WindowAction {
  case showNow, dismissAll
  case setPaused(Bool)
  case restart(Session)
  case editAzkar, revealConfig, quit
}

@MainActor
final class SettingsModel: ObservableObject {
  @Published var config: Config {
    didSet { if !syncing && config != oldValue { onConfigChange?(config) } }
  }
  @Published var status = AppStatus()
  @Published var library = Library(sabah: [], masaa: [], general: [])

  /// Every change made in the window; the app applies and saves it.
  var onConfigChange: ((Config) -> Void)?
  var perform: ((WindowAction) -> Void)?

  private var syncing = false
  /// Times of a window that was switched off, so switching it back on restores them.
  private var remembered: [WritableKeyPath<Config, TimeWindow?>: TimeWindow] = [:]

  init(config: Config) { self.config = config }

  /// Shows a config the app loaded from disk, without saving it back.
  func sync(config: Config) {
    syncing = true
    self.config = config
    syncing = false
  }

  func isEnabled(_ w: WritableKeyPath<Config, TimeWindow?>) -> Bool { config[keyPath: w] != nil }

  func setEnabled(_ w: WritableKeyPath<Config, TimeWindow?>, _ on: Bool) {
    if on {
      if config[keyPath: w] == nil { config[keyPath: w] = remembered[w] ?? Config()[keyPath: w] }
    } else if let current = config[keyPath: w] {
      remembered[w] = current
      config[keyPath: w] = nil
    }
  }

  func time(_ w: WritableKeyPath<Config, TimeWindow?>, start: Bool) -> Date {
    let window = config[keyPath: w] ?? remembered[w] ?? Config()[keyPath: w] ?? TimeWindow(start: 0, end: 0)
    let m = start ? window.start : window.end
    return Calendar.current.date(bySettingHour: m / 60, minute: m % 60, second: 0, of: Date())!
  }

  func setTime(_ w: WritableKeyPath<Config, TimeWindow?>, start: Bool, to date: Date) {
    guard var window = config[keyPath: w] else { return }
    let m = minuteOfDay(date, .current)
    if start { window.start = m } else { window.end = m }
    config[keyPath: w] = window
  }

  /// A key press from the shortcut recorder. False (and nothing changes) if it isn't a usable shortcut.
  func record(keyCode: UInt16, flags: NSEvent.ModifierFlags) -> Bool {
    let masks: [(NSEvent.ModifierFlags, Int)] = [
      (.control, controlKey), (.option, optionKey), (.shift, shiftKey), (.command, cmdKey),
    ]
    let mods = masks.filter { flags.contains($0.0) }.reduce(UInt32(0)) { $0 | UInt32($1.1) }
    guard let hotkey = Hotkey.from(keyCode: UInt32(keyCode), modifiers: mods) else { return false }
    config.hotkey = hotkey
    return true
  }
}
