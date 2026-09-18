// The shell: iOS starts here and hands the window straight to Compose, from kotlin/shared.
import Shared
import SwiftUI
import UIKit

@main
struct AzkarApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

  var body: some Scene {
    WindowGroup {
      ComposeView().ignoresSafeArea()
    }
  }
}

/// The Compose screen, as a SwiftUI view.
struct ComposeView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController { EntryKt.mainViewController() }

  func updateUIViewController(_ controller: UIViewController, context: Context) {}
}

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Kotlin takes the notification delegate and registers the background refresh, which iOS only
    // allows while the app is launching.
    EntryKt.startAzkar()
    return true
  }
}
