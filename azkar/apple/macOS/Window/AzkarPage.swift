import AppKit
import SwiftUI

/// The three lists from azkar.json, with a button to edit the file.
struct AzkarPage: View {
  @ObservedObject var model: SettingsModel
  @State private var list: Session = .sabah

  private var items: [Zikr] {
    switch list {
    case .sabah: model.library.sabah
    case .masaa: model.library.masaa
    case .general: model.library.general
    }
  }

  var body: some View {
    List {
      ForEach(Array(items.enumerated()), id: \.offset) { i, zikr in
        HStack(alignment: .firstTextBaseline, spacing: 12) {
          Text("\(i + 1)")
            .font(.callout.monospacedDigit())
            .foregroundStyle(.tertiary)
            .frame(width: 22, alignment: .leading)
          if count(zikr) > 1 {
            Text("×\(count(zikr))")
              .font(.caption.bold())
              .foregroundStyle(Color(nsColor: list.accent))
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color(nsColor: list.accent).opacity(0.15), in: Capsule())
          }
          Text(zikr.text)
            .font(.system(size: 15))
            .lineSpacing(4)
            .lineLimit(4)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .help(zikr.text)
        }
        .padding(.vertical, 6)
      }
    }
    .safeAreaInset(edge: .top) {
      HStack {
        SwiftUI.Picker("List", selection: $list) {
          Text("Morning  \(model.library.sabah.count)").tag(Session.sabah)
          Text("Evening  \(model.library.masaa.count)").tag(Session.masaa)
          Text("General  \(model.library.general.count)").tag(Session.general)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(maxWidth: 380)
        Spacer()
        Button {
          model.perform?(.editAzkar)
        } label: {
          Label("Edit azkar.json", systemImage: "square.and.pencil")
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(.bar)
    }
    .navigationTitle("Azkar")
  }

  /// General azkar are one tap each unless "Repeat counts" is on.
  private func count(_ z: Zikr) -> Int { list == .general && !model.config.repeatGeneral ? 1 : z.count }
}
