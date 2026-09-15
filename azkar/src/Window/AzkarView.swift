// The window's content (launch the app, or "Open Azkar…" in the menu bar): a sidebar of pages —
// today's progress, the schedule, card options, the azkar list and general settings.
import SwiftUI

private enum Page: String, CaseIterable, Identifiable {
  case today, schedule, cards, azkar, general

  var id: Self { self }
  var title: String { rawValue.capitalized }
  var symbol: String {
    switch self {
    case .today: "sun.max"
    case .schedule: "clock"
    case .cards: "rectangle.stack"
    case .azkar: "book"
    case .general: "gearshape"
    }
  }
}

struct AzkarView: View {
  @ObservedObject var model: SettingsModel
  @State private var page: Page? = .today

  var body: some View {
    NavigationSplitView {
      List(Page.allCases, selection: $page) { p in
        Label(p.title, systemImage: p.symbol)
      }
      .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 240)
    } detail: {
      switch page ?? .today {
      case .today: TodayPage(model: model)
      case .schedule: SchedulePage(model: model)
      case .cards: CardsPage(model: model)
      case .azkar: AzkarPage(model: model)
      case .general: GeneralPage(model: model)
      }
    }
  }
}
