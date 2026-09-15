import SwiftUI

/// The interval, and the morning, evening and quiet-hours times.
struct SchedulePage: View {
  @ObservedObject var model: SettingsModel

  var body: some View {
    Form {
      Section {
        Stepper(value: $model.config.intervalMinutes, in: 1...120, step: 1) {
          Row(title: "Remind me every", symbol: "timer", color: .teal) {
            Text("\(model.config.intervalMinutes.formatted()) min").monospacedDigit().foregroundStyle(.secondary)
          }
        }
      } footer: {
        Footnote("A new card appears on this interval while there's room on screen.")
      }

      window(
        \.sabah, "Morning azkar", "sunrise.fill", .orange,
        "Goes through the \(model.library.sabah.count) morning azkar in order, once a day.")
      window(
        \.masaa, "Evening azkar", "moon.stars.fill", .purple,
        "Goes through the \(model.library.masaa.count) evening azkar in order, once a day.")
      window(\.quietHours, "Quiet hours", "moon.zzz.fill", .indigo, "No new cards during these hours.")

      Section {
        Label(
          "Between and after the morning and evening times — and once their list is done — you get general azkar\(model.config.repeatGeneral ? "" : ", one tap each").",
          systemImage: "info.circle"
        )
        .foregroundStyle(.secondary)
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Schedule")
  }

  private func window(
    _ w: WritableKeyPath<Config, TimeWindow?>, _ title: String, _ symbol: String,
    _ color: Color, _ footer: String
  ) -> some View {
    Section {
      Toggle(isOn: Binding(get: { model.isEnabled(w) }, set: { model.setEnabled(w, $0) })) {
        Row(title: title, symbol: symbol, color: color) { EmptyView() }
      }
      .toggleStyle(.switch)
      if model.isEnabled(w) {
        DatePicker(
          "From",
          selection: Binding(get: { model.time(w, start: true) }, set: { model.setTime(w, start: true, to: $0) }),
          displayedComponents: .hourAndMinute)
        DatePicker(
          "To",
          selection: Binding(get: { model.time(w, start: false) }, set: { model.setTime(w, start: false, to: $0) }),
          displayedComponents: .hourAndMinute)
      }
    } footer: {
      Footnote(footer)
    }
  }
}
