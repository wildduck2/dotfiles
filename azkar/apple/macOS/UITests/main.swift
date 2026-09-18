// AppKit tests: clicks go through the real window event path (NSWindow.sendEvent), in-process,
// with the app inactive like the real menu-bar app, so every click is a "first click".
// Run with: apple/build.sh test
import AppKit

MainActor.assumeIsolated {
  NSApplication.shared.setActivationPolicy(.accessory)
  cardTests()
  placementTests()
  settingsModelTests()
  loginItemTests()
}

print("ui: \(passed) passed, \(failed) failed")
exit(failed == 0 ? 0 : 1)
