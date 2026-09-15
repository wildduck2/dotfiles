// Building blocks shared by the pages: rows, their icons and footnotes.
import SwiftUI

/// A System Settings-style coloured icon square.
struct Tile: View {
  let symbol: String
  let color: Color

  var body: some View {
    Image(systemName: symbol)
      .font(.system(size: 12, weight: .semibold))
      .foregroundStyle(.white)
      .frame(width: 24, height: 24)
      .background(color.gradient, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
  }
}

/// Explanation under a section, left-aligned like System Settings.
struct Footnote: View {
  let text: String
  init(_ text: String) { self.text = text }

  var body: some View {
    Text(text)
      .font(.callout)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)
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
    HStack(spacing: 10) {
      Tile(symbol: symbol, color: color)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
        if let detail { Text(detail).font(.caption).foregroundStyle(.secondary) }
      }
      Spacer()
      trailing
    }
  }
}
