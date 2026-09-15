// The reminders ahead, for phones that can't run code every few minutes: iOS schedules them as notifications.
import Foundation

struct PlannedReminder: Equatable {
  var fireAt: Date
  var card: Card
  /// The state after this card, which the app keeps once the reminder has fired.
  var state: AppState
}

enum Plan {
  /// One reminder per interval after `now` (the first at `now + interval`), until `limit` reminders or `horizon`
  /// seconds. Ticks in quiet hours are skipped. Paused: none. `maxStack` doesn't apply, since nothing stacks up.
  static func make(
    now: Date, calendar: Calendar, config: Config, library: Library, state: AppState,
    limit: Int = 64, horizon: TimeInterval = 48 * 3600, random: (Int) -> Int = { Int.random(in: 0..<$0) }
  ) -> [PlannedReminder] {
    guard !state.paused, config.intervalMinutes > 0 else { return [] }
    var state = state
    var plan: [PlannedReminder] = []
    var step = 1
    while plan.count < limit {
      let offset = Double(step) * config.intervalMinutes * 60
      step += 1
      if offset > horizon { break }
      let date = now.addingTimeInterval(offset)
      if let quiet = config.quietHours, quiet.contains(minuteOfDay: minuteOfDay(date, calendar)) { continue }
      guard
        let card = Picker.next(
          at: date, calendar: calendar, config: config, library: library, state: &state, random: random)
      else { continue }
      plan.append(PlannedReminder(fireAt: date, card: card, state: state))
    }
    return plan
  }

  /// The state after the last reminder that has fired by `now`, or `current` if none has.
  static func commit(_ plan: [PlannedReminder], now: Date, current: AppState) -> AppState {
    plan.last { $0.fireAt <= now }?.state ?? current
  }
}
