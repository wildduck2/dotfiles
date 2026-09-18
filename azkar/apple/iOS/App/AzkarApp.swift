// The app itself: what happens when it launches, when a reminder is tapped, and in the background.
import BackgroundTasks
import SwiftUI
import UIKit
import UserNotifications

@main
struct AzkarApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
  @Environment(\.scenePhase) private var phase

  var body: some Scene {
    WindowGroup {
      RootView(model: delegate.model)
        .task { await delegate.model.refresh() }
    }
    .onChange(of: phase) { _, new in
      // Coming back to the app is the main chance to plan the next reminders.
      guard new == .active else { return }
      Task { await delegate.model.refresh() }
    }
  }
}

/// The parts of Azkar that aren't a screen: the notification centre's delegate, and the background
/// slice iOS grants now and then.
@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  static let refreshTask = "com.wildduck.azkar.refresh"

  let model = Model()

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    // The handler is called on a background queue, so hop back before touching the model.
    BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.refreshTask, using: nil) { task in
      Task { @MainActor in self.refresh(task) }
    }
    return true
  }

  func applicationDidEnterBackground(_ application: UIApplication) { askForBackgroundTime() }

  /// A reminder arrived while Azkar is open: show the card instead of a banner over it.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    model.open(notification: notification.request.content.userInfo)
    return []
  }

  /// A reminder was tapped: open its zikr, and plan the ones after it.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
  ) async {
    model.open(notification: response.notification.request.content.userInfo)
    await model.refresh()
  }

  /// iOS hands the app a few seconds now and then; that's enough to plan the next reminders.
  private func refresh(_ task: BGTask) {
    askForBackgroundTime()
    let work = Task {
      await model.refresh()
      task.setTaskCompleted(success: true)
    }
    task.expirationHandler = { work.cancel() }
  }

  /// Ask for the next slice. iOS decides when — or whether — it comes.
  private func askForBackgroundTime() {
    let request = BGAppRefreshTaskRequest(identifier: Self.refreshTask)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
    try? BGTaskScheduler.shared.submit(request)
  }
}
