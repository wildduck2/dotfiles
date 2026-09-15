// The Azkar window: opening it, its buttons, and keeping it in step with the app.
import AppKit

extension AppDelegate {
  @objc func openWindow() {
    if mainWindow == nil {
      let model = SettingsModel(config: config)
      model.onConfigChange = { [weak self] in self?.save(config: $0) }
      model.perform = { [weak self] in self?.handle($0) }
      self.model = model
      mainWindow = MainWindow(model: model)
    }
    refreshWindow()
    mainWindow?.show()
  }

  private func handle(_ action: WindowAction) {
    switch action {
    case .showNow: showNow()
    case .dismissAll: dismissAll()
    case .setPaused(let paused): if paused != state.paused { togglePause() }
    case .restart(let session):
      let today = dayKey(Date(), .current)
      if state.day != today {
        state = AppState(day: today, general: state.general, lastGeneral: state.lastGeneral, paused: state.paused)
      }
      if session == .sabah { state.sabah = 0 }
      if session == .masaa { state.masaa = 0 }
      saveState()
    case .editAzkar: openAzkar()
    case .revealConfig: NSWorkspace.shared.activateFileViewerSelecting([Paths.config])
    case .quit: NSApp.terminate(nil)
    }
    refreshWindow()
  }

  /// Pushes the app's current state into the window, once it has been opened.
  func refreshWindow() {
    guard let model else { return }
    let today = state.day == dayKey(Date(), .current)
    let status = AppStatus(
      paused: state.paused,
      nextIn: state.paused ? nil : max(0, Int(nextFire.timeIntervalSinceNow.rounded())),
      lastSkip: lastSkip,
      onScreen: stack.count,
      sabahDone: today ? state.sabah : 0, sabahTotal: library.sabah.count,
      masaaDone: today ? state.masaa : 0, masaaTotal: library.masaa.count,
      problems: fileErrors + [hotkeyError, loginError].compactMap { $0 },
      hotkeyError: hotkeyError)
    if model.status != status { model.status = status }
    if model.library != library { model.library = library }
    if model.config != config { model.sync(config: config) }
  }
}
