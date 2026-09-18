import AppKit

/// The colour each list is drawn in, on cards and in the window (its title is in Core/CardText).
extension Session {
  var accent: NSColor {
    switch self {
    case .sabah: .systemOrange
    case .masaa: .systemPurple
    case .general: .systemTeal
    }
  }
}
