import AppKit

/// How each list looks, on cards and in the window.
extension Session {
  var title: String {
    switch self {
    case .sabah: "أذكار الصباح"
    case .masaa: "أذكار المساء"
    case .general: "ذِكْر"
    }
  }

  var accent: NSColor {
    switch self {
    case .sabah: .systemOrange
    case .masaa: .systemPurple
    case .general: .systemTeal
    }
  }
}
