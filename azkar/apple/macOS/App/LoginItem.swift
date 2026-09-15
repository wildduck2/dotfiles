// "Open at login": the LaunchAgent in ~/Library/LaunchAgents. Only the file is written or removed —
// launchd reads it at the next login, and the running app is left alone.
import Foundation

struct LoginItem {
  let label: String
  let url: URL
  let executable: String

  /// The running app's own agent, or nil unless this is the installed app (not tests or a dev build).
  static var current: LoginItem? {
    let bundle = Bundle.main
    guard let label = bundle.bundleIdentifier, label == "com.wildduck.azkar",
      bundle.bundleURL.deletingLastPathComponent().lastPathComponent == "Applications",
      let executable = bundle.executablePath
    else { return nil }
    let url = Paths.home.appendingPathComponent("Library/LaunchAgents/\(label).plist")
    return LoginItem(label: label, url: url, executable: executable)
  }

  var isEnabled: Bool { FileManager.default.fileExists(atPath: url.path) }

  /// Returns nil on success, otherwise why it failed.
  func set(enabled: Bool) -> String? {
    do {
      if enabled {
        let plist = launchAgentPlist(label: label, executable: executable)
        if (try? Data(contentsOf: url)) != plist {
          try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
          try plist.write(to: url, options: .atomic)
        }
      } else if isEnabled {
        try FileManager.default.removeItem(at: url)
      }
      return nil
    } catch {
      return "Open at login: \(error.localizedDescription)"
    }
  }
}
