// The app: the timer, the cards, the global shortcut and the pause state. The files, the window
// and the menus are in the AppDelegate+*.swift extensions.
import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem!
  let stack = CardStack()
  let hotkey = GlobalHotkey()
  var config = Config()
  var library = Library(sabah: [], masaa: [], general: [])
  var state = AppState()
  var fileErrors: [String] = []
  var hotkeyError: String?
  var loginError: String?
  var lastSkip: String?
  var nextFire = Date()
  var locked = false
  var displaysAsleep = false
  var stamps: [URL: Date] = [:]
  var ticks = 0
  var model: SettingsModel?
  var mainWindow: MainWindow?

  func applicationDidFinishLaunching(_ notification: Notification) {
    state = (try? JSONDecoder().decode(AppState.self, from: Data(contentsOf: Paths.state))) ?? AppState()

    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = NSMenu()
    menu.delegate = self
    menu.autoenablesItems = false
    statusItem.menu = menu
    stack.onChange = { [weak self] in self?.updateTitle() }
    stack.onComplete = { [weak self] in self?.play("Glass") }

    reloadFiles(force: true)
    nextFire = Date().addingTimeInterval(5)  // first reminder right after launch/login

    let nc = NotificationCenter.default
    nc.addObserver(self, selector: #selector(tapOldest), name: .azkarHotkey, object: nil)
    nc.addObserver(
      self, selector: #selector(screensChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    let dnc = DistributedNotificationCenter.default()
    dnc.addObserver(self, selector: #selector(screenLocked), name: .init("com.apple.screenIsLocked"), object: nil)
    dnc.addObserver(self, selector: #selector(screenUnlocked), name: .init("com.apple.screenIsUnlocked"), object: nil)
    dnc.addObserver(self, selector: #selector(openWindow), name: .azkarOpen, object: nil)
    let ws = NSWorkspace.shared.notificationCenter
    ws.addObserver(self, selector: #selector(displaysSlept), name: NSWorkspace.screensDidSleepNotification, object: nil)
    ws.addObserver(self, selector: #selector(displaysWoke), name: NSWorkspace.screensDidWakeNotification, object: nil)

    let timer = Timer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    RunLoop.main.add(timer, forMode: .common)
    updateTitle()
    NSApp.mainMenu = mainMenu()
    if opensWindowAtLaunch(arguments: CommandLine.arguments, config: config) { openWindow() }
  }

  /// Clicking the app again while it runs (Finder, Spotlight, Dock) opens the window.
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    openWindow()
    return true
  }

  // MARK: timer

  @objc private func tick() {
    ticks += 1
    if ticks % 2 == 0 { reloadFiles(force: false) }
    if mainWindow?.isVisible == true { refreshWindow() }

    let now = Date()
    guard now >= nextFire else { return }
    nextFire = now.addingTimeInterval(config.intervalMinutes * 60)
    let quiet = config.quietHours?.contains(minuteOfDay: minuteOfDay(now, .current)) ?? false
    switch decideTick(
      paused: state.paused, locked: locked || displaysAsleep, quiet: quiet,
      stackCount: stack.count, maxStack: config.maxStack)
    {
    case .show:
      lastSkip = nil
      show(at: now)
    case .skip(let reason):
      lastSkip = reason
    }
  }

  private func show(at now: Date) {
    guard
      let card = Picker.next(
        at: now, calendar: .current, config: config, library: library,
        state: &state, random: { Int.random(in: 0..<$0) })
    else { return }
    saveState()
    stack.push(CardWindow(card: card, fontSize: config.fontSize, hint: config.hotkey.display))
    play("Glass")
    updateTitle()
  }

  /// A system sound — the same chime when a card pops in and when a count is finished — if sounds are on.
  /// Restarts it if it's still playing, so quick taps each get their sound.
  private func play(_ name: String) {
    guard config.sound, let sound = NSSound(named: name) else { return }
    sound.stop()
    sound.play()
  }

  // MARK: actions

  @objc func tapOldest() {
    NSLog("Azkar: hotkey pressed")
    stack.tapOldest()
  }

  @objc func dismissOldest() { stack.dismissOldest() }
  @objc func dismissAll() { stack.dismissAll() }

  @objc func showNow() {
    show(at: Date())
    nextFire = Date().addingTimeInterval(config.intervalMinutes * 60)
  }

  @objc func togglePause() {
    state.paused.toggle()
    saveState()
    if !state.paused { nextFire = Date().addingTimeInterval(config.intervalMinutes * 60) }
    updateTitle()
  }

  @objc func openAzkar() { NSWorkspace.shared.open(Paths.azkar) }

  @objc private func screensChanged() { stack.layout(animated: false) }
  @objc private func screenLocked() { locked = true }
  @objc private func screenUnlocked() { locked = false }
  @objc private func displaysSlept() { displaysAsleep = true }
  @objc private func displaysWoke() { displaysAsleep = false }
}
