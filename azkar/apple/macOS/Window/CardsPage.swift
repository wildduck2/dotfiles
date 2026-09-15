import AppKit
import SwiftUI

/// The shortcut, how general azkar are picked, and how cards look.
struct CardsPage: View {
  @ObservedObject var model: SettingsModel

  var body: some View {
    Form {
      Section {
        Row(title: "Count / close shortcut", symbol: "keyboard", color: .blue) {
          ShortcutRecorder(model: model)
        }
        if let error = model.status.hotkeyError {
          Label(error, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
        }
      } footer: {
        Footnote(
          "Each press — or a click on the card — counts once, and the last one closes it. × closes a card straight away."
        )
      }

      Section("General azkar") {
        SwiftUI.Picker(selection: $model.config.order) {  // Core has its own `Picker`
          Text("Random").tag(Order.random)
          Text("In order").tag(Order.sequential)
        } label: {
          Row(title: "Order", symbol: "shuffle", color: .teal) { EmptyView() }
        }
        Toggle(isOn: $model.config.repeatGeneral) {
          Row(
            title: "Repeat counts", symbol: "repeat", color: .green,
            detail: "Off: one tap each, even for ×100 azkar."
          ) { EmptyView() }
        }
        .toggleStyle(.switch)
      }

      Section("Cards") {
        Stepper(value: $model.config.maxStack, in: 1...10) {
          Row(title: "Cards on screen at most", symbol: "rectangle.stack.fill", color: .pink) {
            Text("\(model.config.maxStack)").monospacedDigit().foregroundStyle(.secondary)
          }
        }
        Row(title: "Text size", symbol: "textformat.size", color: .gray) {
          // No `step:` (it draws tick marks); whole points instead.
          Slider(
            value: Binding(get: { model.config.fontSize }, set: { model.config.fontSize = $0.rounded() }),
            in: 14...36
          )
          .frame(width: 200)
          Text("\(Int(model.config.fontSize))").monospacedDigit().foregroundStyle(.secondary).frame(width: 24)
        }
        CardPreview(fontSize: model.config.fontSize, hint: model.config.hotkey.display)
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Cards")
  }
}

/// Roughly what a card looks like at the chosen text size.
private struct CardPreview: View {
  let fontSize: Double
  let hint: String

  var body: some View {
    VStack(spacing: 10) {
      HStack(spacing: 8) {
        Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
        Text("×3").font(.caption.bold()).foregroundStyle(.orange)
        Spacer()
        Text("أذكار الصباح  ·  7 من 25").font(.caption.weight(.semibold)).foregroundStyle(.orange)
      }
      Text("سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ")
        .font(.system(size: fontSize))
        .lineSpacing(fontSize * 0.3)
        .multilineTextAlignment(.trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
      Text("انقر أو \(hint)").font(.caption2).foregroundStyle(.tertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(18)
    .frame(maxWidth: 440)
    .background(Color(white: 0.13), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .environment(\.colorScheme, .dark)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 6)
  }
}
