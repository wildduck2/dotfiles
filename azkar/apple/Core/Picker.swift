// Picking the next card, and the progress through today's lists that it keeps.
import Foundation

enum Session: String, Codable { case sabah, masaa, general }

struct Card: Equatable {
  var zikr: Zikr
  var session: Session
  /// 1-based position within the morning/evening list; nil for general azkar.
  var position: Int?
  var total: Int?
}

/// Persisted between launches so the morning/evening lists continue where they left off today.
struct AppState: Codable, Equatable {
  var day = ""
  var sabah = 0
  var masaa = 0
  var general = 0
  var lastGeneral: Int?
  var paused = false
}

enum Picker {
  /// Inside the morning (evening) window, walks that list in order once per day; otherwise,
  /// or once the list is done, picks from `general` (one tap each unless `repeatGeneral`).
  /// `random(n)` must return 0..<n.
  static func next(
    at date: Date, calendar: Calendar, config: Config, library: Library,
    state: inout AppState, random: (Int) -> Int
  ) -> Card? {
    let today = dayKey(date, calendar)
    if state.day != today {
      state.day = today
      state.sabah = 0
      state.masaa = 0
    }

    let minute = minuteOfDay(date, calendar)
    let timed: [(Session, TimeWindow?, [Zikr], WritableKeyPath<AppState, Int>)] = [
      (.sabah, config.sabah, library.sabah, \.sabah),
      (.masaa, config.masaa, library.masaa, \.masaa),
    ]
    for (session, window, list, progress) in timed {
      guard let window, window.contains(minuteOfDay: minute), state[keyPath: progress] < list.count else { continue }
      let i = state[keyPath: progress]
      state[keyPath: progress] += 1
      return Card(zikr: list[i], session: session, position: i + 1, total: list.count)
    }

    let general = library.general
    guard !general.isEmpty else { return nil }
    let i: Int
    switch config.order {
    case .sequential:
      i = state.general % general.count
      state.general = i + 1
    case .random:
      if general.count == 1 {
        i = 0
      } else if let last = state.lastGeneral, last < general.count {
        let r = random(general.count - 1)  // skip `last` so the same zikr never shows twice in a row
        i = r >= last ? r + 1 : r
      } else {
        i = random(general.count)
      }
    }
    state.lastGeneral = i
    var zikr = general[i]
    if !config.repeatGeneral { zikr.count = 1 }
    return Card(zikr: zikr, session: .general, position: nil, total: nil)
  }
}
