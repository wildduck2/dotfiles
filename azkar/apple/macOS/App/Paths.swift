// Where the files live, and the app-wide notification names.
import Foundation

enum Paths {
  static let home = FileManager.default.homeDirectoryForCurrentUser
  static let config = home.appendingPathComponent(".config/azkar/config.json")
  static let azkar = home.appendingPathComponent(".config/azkar/azkar.json")
  static let state = home.appendingPathComponent(".local/state/azkar/state.json")
}

extension Notification.Name {
  static let azkarHotkey = Notification.Name("com.wildduck.azkar.hotkey")
  /// Posted by a second launch of the app: the running one opens its window instead.
  static let azkarOpen = Notification.Name("com.wildduck.azkar.open")
}
