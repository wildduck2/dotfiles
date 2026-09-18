// The card a reminder opens: the zikr, big, with a tap for each repetition.
import SwiftUI

struct CardSheet: View {
  let card: Card
  let counter: TapCounter
  let fontSize: Double
  let onCount: () -> Void
  let onClose: () -> Void

  var body: some View {
    ZStack {
      Color(white: 0.08).ignoresSafeArea()
      VStack(spacing: 16) {
        header
        ScrollView {
          Text(cardBody(card.zikr))
            .font(.system(size: fontSize))
            .lineSpacing(fontSize * 0.35)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, 8)
        }
        footer
      }
      .padding(20)
    }
    .environment(\.colorScheme, .dark)
    // The whole card counts, apart from the ×, so there's nothing to aim at.
    .contentShape(Rectangle())
    .onTapGesture(perform: onCount)
  }

  private var header: some View {
    HStack(spacing: 10) {
      Button(action: onClose) {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
          .foregroundStyle(.secondary)
      }
      .accessibilityLabel("Close")
      if !counter.badge.isEmpty {
        Text(counter.badge).font(.callout.bold().monospacedDigit()).foregroundStyle(card.session.accent)
      }
      Spacer()
      Text(cardHeader(card))
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(card.session.accent)
    }
  }

  private var footer: some View {
    VStack(spacing: 10) {
      ProgressView(value: counter.fraction).tint(card.session.accent)
      Text(tapToCount).font(.caption).foregroundStyle(.tertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
