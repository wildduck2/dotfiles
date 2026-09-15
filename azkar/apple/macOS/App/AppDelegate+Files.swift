// config.json, azkar.json and state.json: reloading on change, and saving.
import Foundation

extension AppDelegate {
  /// Re-reads config.json and azkar.json when either changes on disk. A broken file keeps the
  /// last good version and shows the error in the menu.
  func reloadFiles(force: Bool) {
    let changed = [Paths.config, Paths.azkar].map(stampChanged).contains(true)
    guard force || changed else { return }

    var errors: [String] = []
    var newConfig = Config()
    if FileManager.default.fileExists(atPath: Paths.config.path) {
      do {
        newConfig = try Config.decode(Data(contentsOf: Paths.config))
      } catch {
        errors.append("config.json: \(message(error))")
        newConfig = config
      }
    }
    do {
      library = try Library.decode(Data(contentsOf: Paths.azkar))
    } catch {
      errors.append("azkar.json: \(message(error))")
    }
    fileErrors = errors
    for error in errors { NSLog("Azkar: %@", error) }
    apply(newConfig, force: force)
    refreshWindow()
  }

  private func apply(_ newConfig: Config, force: Bool = false) {
    if force || newConfig.hotkey != config.hotkey {
      hotkeyError = hotkey.register(newConfig.hotkey)
      NSLog("Azkar: hotkey %@ %@", newConfig.hotkey.display, hotkeyError ?? "registered")
    }
    if force || newConfig.openAtLogin != config.openAtLogin {
      loginError = LoginItem.current?.set(enabled: newConfig.openAtLogin)
    }
    if newConfig.intervalMinutes != config.intervalMinutes {
      nextFire = min(nextFire, Date().addingTimeInterval(newConfig.intervalMinutes * 60))
    }
    config = newConfig
    updateTitle()
  }

  /// A change made in the window: apply it now and write config.json.
  func save(config newConfig: Config) {
    apply(newConfig)
    let url = Paths.config.resolvingSymlinksInPath()
    fileErrors.removeAll { $0.hasPrefix("config.json") }
    do {
      try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      try newConfig.encode().write(to: url, options: .atomic)
    } catch {
      fileErrors.append("config.json: \(message(error))")
    }
    _ = stampChanged(Paths.config)  // our own write: nothing to reload
    refreshWindow()
  }

  private func stampChanged(_ url: URL) -> Bool {
    let date = try? url.resolvingSymlinksInPath().resourceValues(forKeys: [.contentModificationDateKey])
      .contentModificationDate
    defer { stamps[url] = date }
    return stamps[url] != date
  }

  func saveState() {
    try? FileManager.default.createDirectory(
      at: Paths.state.deletingLastPathComponent(),
      withIntermediateDirectories: true)
    try? JSONEncoder().encode(state).write(to: Paths.state, options: .atomic)
  }
}
