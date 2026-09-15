import AppKit

// One instance only: the LaunchAgent may already be running it. Launching it again just opens
// the running one's window.
if let id = Bundle.main.bundleIdentifier,
  NSRunningApplication.runningApplications(withBundleIdentifier: id).count > 1
{
  DistributedNotificationCenter.default().postNotificationName(
    .azkarOpen, object: nil, userInfo: nil,
    deliverImmediately: true)
  exit(0)
}

// Top-level code runs on the main thread; Swift 5 mode just doesn't know it's the main actor.
MainActor.assumeIsolated {
  let app = NSApplication.shared
  let delegate = AppDelegate()  // app.delegate is weak; run() never returns, so this stays alive
  app.delegate = delegate
  app.setActivationPolicy(.accessory)
  app.run()
}
