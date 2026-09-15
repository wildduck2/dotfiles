import AppKit
import SwiftUI

/// Reminders on/off, the next card, and today's progress through the morning and evening lists.
struct TodayPage: View {
  @ObservedObject var model: SettingsModel
  private var s: AppStatus { model.status }

  var body: some View {
    Form {
      Section {
        HStack(spacing: 14) {
          Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 52, height: 52)
          VStack(alignment: .leading, spacing: 3) {
            Text(s.paused ? "Reminders are paused" : "Reminders are on").font(.title3.weight(.semibold))
            Text(subtitle).foregroundStyle(.secondary).monospacedDigit()
          }
          Spacer()
          Toggle("Reminders", isOn: Binding(get: { !s.paused }, set: { model.perform?(.setPaused(!$0)) }))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.large)
        }
        .padding(.vertical, 4)
      }

      Section("Today") {
        progress("Morning azkar", "sunrise.fill", .orange, s.sabahDone, s.sabahTotal, .sabah)
        progress("Evening azkar", "moon.stars.fill", .purple, s.masaaDone, s.masaaTotal, .masaa)
      }

      Section {
        HStack {
          Button {
            model.perform?(.showNow)
          } label: {
            Label("Show a zikr now", systemImage: "sparkles")
          }
          Button {
            model.perform?(.dismissAll)
          } label: {
            Label("Dismiss all", systemImage: "xmark.circle")
          }
          .disabled(s.onScreen == 0)
          Spacer()
          Text(s.onScreen == 1 ? "1 card on screen" : "\(s.onScreen) cards on screen")
            .foregroundStyle(.secondary)
        }
      }

      if !s.problems.isEmpty {
        Section("Needs attention") {
          ForEach(s.problems, id: \.self) { problem in
            Label(problem, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
          }
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Today")
  }

  private var subtitle: String {
    if s.paused { return "No new cards until you switch them back on." }
    guard let n = s.nextIn else { return "" }
    let next = String(format: "Next zikr in %d:%02d", n / 60, n % 60)
    return s.lastSkip.map { "\(next)  ·  last one skipped: \($0)" } ?? next
  }

  private func progress(
    _ title: String, _ symbol: String, _ color: Color, _ done: Int, _ total: Int,
    _ session: Session
  ) -> some View {
    HStack(spacing: 10) {
      Tile(symbol: symbol, color: color)
      VStack(alignment: .leading, spacing: 6) {
        HStack {
          Text(title)
          Spacer()
          Text(total > 0 && done >= total ? "Done" : "\(done) of \(total)")
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        ProgressView(value: Double(min(done, total)), total: Double(max(total, 1)))
          .tint(color)
      }
      Button("Restart") { model.perform?(.restart(session)) }
        .controlSize(.small)
        .disabled(done == 0)
        .help("Start today's list again from the first zikr")
    }
    .padding(.vertical, 2)
  }
}
