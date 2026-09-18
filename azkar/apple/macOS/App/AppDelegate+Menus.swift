// The 📿 menu-bar item and its menu, and the app menu shown while the window is open.
import AppKit

extension AppDelegate: NSMenuDelegate {
  func updateTitle() {
    statusItem.button?.title = stack.count > 0 && config.showCount ? "📿 \(stack.count)" : "📿"
    statusItem.button?.appearsDisabled = state.paused
    refreshWindow()
  }

  func menuNeedsUpdate(_ menu: NSMenu) {
    menu.removeAllItems()
    menu.addItem(info(statusLine()))
    if state.day == dayKey(Date(), .current) {
      menu.addItem(
        info("Morning \(state.sabah)/\(library.sabah.count) · Evening \(state.masaa)/\(library.masaa.count)"))
    }
    for error in fileErrors + [hotkeyError, loginError].compactMap({ $0 }) {
      menu.addItem(info("⚠️ \(error)"))
    }
    menu.addItem(.separator())
    let hasCards = stack.count > 0
    menu.addItem(action("Count on oldest   \(config.hotkey.display) or click", #selector(tapOldest), enabled: hasCards))
    menu.addItem(action("Dismiss oldest", #selector(dismissOldest), enabled: hasCards))
    menu.addItem(action("Dismiss all", #selector(dismissAll), enabled: hasCards))
    menu.addItem(action("Show one now", #selector(showNow)))
    menu.addItem(action(state.paused ? "Resume" : "Pause", #selector(togglePause)))
    menu.addItem(.separator())
    menu.addItem(action("Open Azkar…", #selector(openWindow)))
    menu.addItem(.separator())
    let quit = NSMenuItem(title: "Quit Azkar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
    quit.target = NSApp
    menu.addItem(quit)
  }

  /// The menu bar while the window is open (the app is a regular app then).
  func mainMenu() -> NSMenu {
    let app = NSMenu()
    app.addItem(
      withTitle: "About Azkar", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
    app.addItem(.separator())
    app.addItem(withTitle: "Settings…", action: #selector(openWindow), keyEquivalent: ",").target = self
    app.addItem(.separator())
    app.addItem(withTitle: "Hide Azkar", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
    app.addItem(withTitle: "Quit Azkar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

    let window = NSMenu(title: "Window")
    window.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
    window.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
    NSApp.windowsMenu = window

    let bar = NSMenu()
    for submenu in [app, window] {
      let item = NSMenuItem()
      item.submenu = submenu
      bar.addItem(item)
    }
    return bar
  }

  private func statusLine() -> String {
    if state.paused { return "Paused" }
    let left = max(0, Int(nextFire.timeIntervalSinceNow.rounded()))
    var line = String(format: "Next in %d:%02d", left / 60, left % 60)
    if let lastSkip { line += " · last skipped: \(lastSkip)" }
    return line
  }

  private func info(_ title: String) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
    item.isEnabled = false
    return item
  }

  private func action(_ title: String, _ selector: Selector, enabled: Bool = true) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: selector, keyEquivalent: "")
    item.target = self
    item.isEnabled = enabled
    return item
  }
}
