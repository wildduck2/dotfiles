import AppKit
import SwiftUI

/// Hosts AzkarView in a regular window.
@MainActor
final class MainWindow: NSObject, NSWindowDelegate {
  private let model: SettingsModel
  private var window: NSWindow?

  init(model: SettingsModel) { self.model = model }

  var isVisible: Bool { window?.isVisible ?? false }

  /// While the window is open Azkar is a regular app (Dock icon, ⌘-Tab); closing it goes back to menu-bar only.
  func show() {
    let w = window ?? make()
    window = w
    NSApp.setActivationPolicy(.regular)
    NSApp.activate()
    w.makeKeyAndOrderFront(nil)
  }

  private func make() -> NSWindow {
    let hosting = NSHostingController(rootView: AzkarView(model: model))
    hosting.sizingOptions = []
    hosting.sceneBridgingOptions = [.toolbars, .title]
    let w = NSWindow(contentViewController: hosting)
    w.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
    w.title = "Azkar"
    w.toolbarStyle = .unified
    w.isReleasedWhenClosed = false
    w.setContentSize(NSSize(width: 780, height: 580))
    w.minSize = NSSize(width: 680, height: 480)
    w.center()
    w.setFrameAutosaveName("AzkarMain")
    w.delegate = self
    return w
  }

  func windowWillClose(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
  }
}
