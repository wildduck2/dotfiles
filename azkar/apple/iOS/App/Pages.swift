// The five pages, in a tab bar: today's progress, the schedule, how reminders look, the azkar
// themselves, and everything else.
import Combine
import SwiftUI
import UserNotifications

struct RootView: View {
  let model: Model

  var body: some View {
    TabView {
      NavigationStack { TodayPage(model: model) }
        .tabItem { Label("Today", systemImage: "sun.max") }
      NavigationStack { SchedulePage(model: model) }
        .tabItem { Label("Schedule", systemImage: "clock") }
      NavigationStack { RemindersPage(model: model) }
        .tabItem { Label("Reminders", systemImage: "bell") }
      NavigationStack { AzkarPage(model: model) }
        .tabItem { Label("Azkar", systemImage: "book") }
      NavigationStack { GeneralPage(model: model) }
        .tabItem { Label("General", systemImage: "gearshape") }
    }
    .fullScreenCover(isPresented: Binding(get: { model.card != nil }, set: { if !$0 { model.close() } })) {
      if let card = model.card {
        CardSheet(
          card: card, counter: model.counter, fontSize: model.config.fontSize,
          onCount: { model.count() }, onClose: { model.close() })
      }
    }
  }
}

/// Reminders on or off, when the next one arrives, and today's progress through the two lists.
struct TodayPage: View {
  let model: Model
  @State private var now = Date()
  private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    Form {
      Section {
        HStack(spacing: 14) {
          Text("📿")
            .font(.system(size: 28))
            .frame(width: 52, height: 52)
            .background(Color.teal.gradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
          VStack(alignment: .leading, spacing: 3) {
            Text(model.state.paused ? "Reminders are paused" : "Reminders are on").font(.headline)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary).monospacedDigit()
          }
          Spacer(minLength: 8)
          Toggle(
            "Reminders",
            isOn: Binding(get: { !model.state.paused }, set: { on in Task { await model.setPaused(!on) } })
          )
          .labelsHidden()
        }
        .padding(.vertical, 4)
      }

      Section("Today") {
        progress("Morning azkar", "sunrise.fill", .orange, model.sabahDone, model.library.sabah.count, .sabah)
        progress("Evening azkar", "moon.stars.fill", .purple, model.masaaDone, model.library.masaa.count, .masaa)
      }

      Section {
        Button {
          Task { await model.showNow() }
        } label: {
          Label("Show a zikr now", systemImage: "sparkles")
        }
      } footer: {
        Text(lined).font(.footnote)
      }

      if !model.problems.isEmpty {
        Section("Needs attention") {
          ForEach(model.problems) { problem in
            VStack(alignment: .leading, spacing: 8) {
              Label(problem.text, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
              if problem.opensSettings {
                Button("Open Settings") { openSystemSettings() }
                  .buttonStyle(.bordered)
                  .controlSize(.small)
              }
            }
          }
        }
      }
    }
    .navigationTitle("Today")
    .onReceive(tick) { now = $0 }
  }

  private var subtitle: String {
    if model.state.paused { return "No reminders until you switch them back on." }
    guard let n = model.nextIn(at: now) else { return "Nothing scheduled — open Azkar again." }
    return String(format: "Next zikr in %d:%02d", n / 60, n % 60)
  }

  private var lined: String {
    let n = model.scheduled
    let count = n == 1 ? "1 reminder is" : "\(n) reminders are"
    return "\(count) lined up. iOS holds \(Reminders.limit) at a time, so open Azkar now and then to top them up."
  }

  private func progress(
    _ title: String, _ symbol: String, _ color: Color, _ done: Int, _ total: Int, _ session: Session
  ) -> some View {
    HStack(spacing: 12) {
      Tile(symbol: symbol, color: color)
      VStack(alignment: .leading, spacing: 6) {
        HStack {
          Text(title)
          Spacer()
          Text(total > 0 && done >= total ? "Done" : "\(done) of \(total)")
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        ProgressView(value: Double(min(done, total)), total: Double(max(total, 1))).tint(color)
      }
      Button("Restart") { Task { await model.restart(session) } }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .disabled(done == 0)
    }
    .padding(.vertical, 2)
  }
}

/// How often reminders come, and the morning, evening and quiet-hours times.
struct SchedulePage: View {
  let model: Model

  var body: some View {
    Form {
      Section {
        Stepper(value: model.binding(\.intervalMinutes), in: 1...120, step: 1) {
          Row(title: "Remind me every", symbol: "timer", color: .teal) {
            Text("\(model.config.intervalMinutes.formatted()) min").monospacedDigit().foregroundStyle(.secondary)
          }
        }
      } footer: {
        Text("A reminder arrives on this interval, as long as Azkar has been opened recently enough to plan it.")
      }

      window(
        \.sabah, "Morning azkar", "sunrise.fill", .orange,
        "Goes through the \(model.library.sabah.count) morning azkar in order, once a day.")
      window(
        \.masaa, "Evening azkar", "moon.stars.fill", .purple,
        "Goes through the \(model.library.masaa.count) evening azkar in order, once a day.")
      window(\.quietHours, "Quiet hours", "moon.zzz.fill", .indigo, "No reminders during these hours.")

      Section {
        Label(
          "Between and after the morning and evening times — and once their list is done — you get general azkar\(model.config.repeatGeneral ? "" : ", one tap each").",
          systemImage: "info.circle"
        )
        .foregroundStyle(.secondary)
      }
    }
    .navigationTitle("Schedule")
  }

  private func window(
    _ w: WritableKeyPath<Config, TimeWindow?>, _ title: String, _ symbol: String, _ color: Color, _ footer: String
  ) -> some View {
    Section {
      Toggle(
        isOn: Binding(get: { model.isEnabled(w) }, set: { on in Task { await model.setEnabled(w, on) } })
      ) {
        Row(title: title, symbol: symbol, color: color) { EmptyView() }
      }
      if model.isEnabled(w) {
        DatePicker(
          "From",
          selection: Binding(
            get: { model.time(w, start: true) }, set: { d in Task { await model.setTime(w, start: true, to: d) } }),
          displayedComponents: .hourAndMinute)
        DatePicker(
          "To",
          selection: Binding(
            get: { model.time(w, start: false) }, set: { d in Task { await model.setTime(w, start: false, to: d) } }),
          displayedComponents: .hourAndMinute)
      }
    } footer: {
      Text(footer)
    }
  }
}

/// How general azkar are picked, and what a reminder looks like when it's opened.
struct RemindersPage: View {
  let model: Model

  var body: some View {
    Form {
      Section("General azkar") {
        SwiftUI.Picker(selection: model.binding(\.order)) {  // Core has its own `Picker`
          Text("Random").tag(Order.random)
          Text("In order").tag(Order.sequential)
        } label: {
          Row(title: "Order", symbol: "shuffle", color: .teal) { EmptyView() }
        }
        Toggle(isOn: model.binding(\.repeatGeneral)) {
          Row(
            title: "Repeat counts", symbol: "repeat", color: .green,
            detail: "Off: one tap each, even for ×100 azkar."
          ) { EmptyView() }
        }
      }

      Section {
        Toggle(isOn: model.binding(\.sound)) {
          Row(
            title: "Sounds", symbol: "speaker.wave.2.fill", color: .pink,
            detail: "A chime with each reminder."
          ) { EmptyView() }
        }
        Row(title: "Text size", symbol: "textformat.size", color: .gray) {
          Slider(value: fontSize, in: 14...36)
            .frame(width: 140)
          Text("\(Int(model.config.fontSize))").monospacedDigit().foregroundStyle(.secondary).frame(width: 24)
        }
      } header: {
        Text("Reminders")
      } footer: {
        Text("Tapping a reminder opens the zikr like this. Reminders wait in Notification Centre until you do.")
      }

      Section {
        CardPreview(fontSize: model.config.fontSize)
          .listRowInsets(EdgeInsets())
          .listRowBackground(Color.clear)
      }
    }
    .navigationTitle("Reminders")
  }

  /// Whole points only: a slider would otherwise save a config for every fraction it passes through.
  private var fontSize: Binding<Double> {
    let size = model.binding(\.fontSize)
    return Binding(get: { size.wrappedValue }, set: { size.wrappedValue = $0.rounded() })
  }
}

/// Roughly what a zikr looks like at the chosen text size.
private struct CardPreview: View {
  let fontSize: Double

  /// The seventh of the morning azkar, written the way a real card writes it.
  private static let sample = Card(
    zikr: Zikr(
      text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ",
      count: 3, note: nil, ref: nil),
    session: .sabah, position: 7, total: 25)

  var body: some View {
    VStack(spacing: 10) {
      HStack(spacing: 8) {
        Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
        Text("×\(Self.sample.zikr.count)").font(.caption.bold()).foregroundStyle(Self.sample.session.accent)
        Spacer()
        Text(cardHeader(Self.sample))
          .font(.caption.weight(.semibold))
          .foregroundStyle(Self.sample.session.accent)
      }
      Text(Self.sample.zikr.text)
        .font(.system(size: fontSize))
        .lineSpacing(fontSize * 0.3)
        .multilineTextAlignment(.trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
      Text(tapToCount).font(.caption2).foregroundStyle(.tertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(18)
    .background(Color(white: 0.13), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    .environment(\.colorScheme, .dark)
    .padding(.vertical, 8)
  }
}

/// The three lists, as they ship with the app.
struct AzkarPage: View {
  let model: Model
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
            .font(.caption.monospacedDigit())
            .foregroundStyle(.tertiary)
            .frame(width: 24, alignment: .leading)
          if count(zikr) > 1 {
            Text("×\(count(zikr))")
              .font(.caption2.bold())
              .foregroundStyle(list.accent)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(list.accent.opacity(0.15), in: Capsule())
          }
          Text(zikr.text)
            .font(.system(size: 15))
            .lineSpacing(4)
            .lineLimit(4)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 4)
      }
    }
    .safeAreaInset(edge: .top) {
      SwiftUI.Picker("List", selection: $list) {
        Text("Morning \(model.library.sabah.count)").tag(Session.sabah)
        Text("Evening \(model.library.masaa.count)").tag(Session.masaa)
        Text("General \(model.library.general.count)").tag(Session.general)
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(.bar)
    }
    .navigationTitle("Azkar")
    .navigationBarTitleDisplayMode(.inline)
  }

  /// General azkar are one tap each unless "Repeat counts" is on.
  private func count(_ z: Zikr) -> Int { list == .general && !model.config.repeatGeneral ? 1 : z.count }
}

/// Notifications, where the files are, and which version this is.
struct GeneralPage: View {
  let model: Model

  var body: some View {
    Form {
      Section {
        Row(title: "Notifications", symbol: "bell.badge.fill", color: .red, detail: permission) { EmptyView() }
        Button("Open Settings") { openSystemSettings() }
      } footer: {
        Text(
          "Reminders are notifications, so Azkar doesn't have to be running. Sounds, banners and Do Not Disturb are all settled in Settings."
        )
      }

      Section {
        Label("Background App Refresh keeps reminders coming", systemImage: "arrow.clockwise")
          .foregroundStyle(.secondary)
      } footer: {
        Text(
          "iOS holds \(Reminders.limit) reminders at a time. Azkar plans the next ones whenever you open it, and in the background when iOS allows it."
        )
      }

      Section {
        Label("config.json, state.json and plan.json", systemImage: "folder")
          .foregroundStyle(.secondary)
      } header: {
        Text("Where the files are")
      } footer: {
        Text(
          "Inside Azkar's own storage on this phone, in the same format as the Mac, Windows and Linux apps. azkar.json ships with the app."
        )
      }

      Section {
        LabeledContent("Version", value: version)
      }
    }
    .navigationTitle("General")
  }

  private var permission: String {
    switch model.notifications {
    case .authorized: "Allowed"
    case .provisional: "Quiet only"
    case .denied: "Off — no reminders can arrive"
    case .notDetermined: "Not asked yet"
    default: "Limited"
    }
  }

  private var version: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
  }
}
