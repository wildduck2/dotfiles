// Building blocks the pages are made of: rows, their icons, footnotes, and the bindings that
// write a settings change straight through to the model.
import SwiftUI
import UIKit

/// A Settings-style coloured icon square.
struct Tile: View {
  let symbol: String
  let color: Color

  var body: some View {
    Image(systemName: symbol)
      .font(.system(size: 13, weight: .semibold))
      .foregroundStyle(.white)
      .frame(width: 28, height: 28)
      .background(color.gradient, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
  }
}

/// Icon, title and optional detail on the left; `trailing` on the right.
struct Row<Trailing: View>: View {
  let title: String
  let symbol: String
  let color: Color
  var detail: String?
  @ViewBuilder var trailing: Trailing

  var body: some View {
    HStack(spacing: 12) {
      Tile(symbol: symbol, color: color)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
        if let detail { Text(detail).font(.caption).foregroundStyle(.secondary) }
      }
      Spacer(minLength: 8)
      trailing
    }
  }
}

/// The colour each list is drawn in (its title is in Core/CardText).
extension Session {
  var accent: Color {
    switch self {
    case .sabah: .orange
    case .masaa: .purple
    case .general: .teal
    }
  }
}

extension Model {
  /// Every settings control edits the live config and saves it; there is no Apply button.
  func binding<V: Equatable>(_ path: WritableKeyPath<Config, V>) -> Binding<V> {
    Binding(
      get: { self.config[keyPath: path] },
      set: { value in
        guard value != self.config[keyPath: path] else { return }
        var new = self.config
        new[keyPath: path] = value
        Task { await self.save(new) }
      })
  }
}

/// Azkar's own page in Settings, where notifications can be switched back on.
@MainActor
func openSystemSettings() {
  guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
  UIApplication.shared.open(url)
}
