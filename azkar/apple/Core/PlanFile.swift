// plan.json: the reminders iOS has already been handed, so a later launch knows which of them have fired.
import Foundation

private struct StoredZikr: Codable {
  var text: String
  var count: Int
  var note: String?
}

private struct StoredReminder: Codable {
  var at: String
  var session: Session
  var position: Int?
  var total: Int?
  var zikr: StoredZikr
  var state: AppState
}

private struct StoredPlan: Codable {
  var reminders: [StoredReminder]
}

enum PlanFile {
  /// Whole seconds in UTC — "2026-09-16T18:45:00Z" — which is how Kotlin writes an instant.
  private static let iso: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    f.timeZone = TimeZone(identifier: "UTC")
    return f
  }()

  private static let isoWithFraction: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    f.timeZone = TimeZone(identifier: "UTC")
    return f
  }()

  static func encode(_ plan: [PlannedReminder]) -> String {
    let stored = StoredPlan(
      reminders: plan.map { reminder in
        StoredReminder(
          at: iso.string(from: Date(timeIntervalSince1970: reminder.fireAt.timeIntervalSince1970.rounded(.down))),
          session: reminder.card.session,
          position: reminder.card.position,
          total: reminder.card.total,
          zikr: StoredZikr(
            text: reminder.card.zikr.text, count: reminder.card.zikr.count, note: reminder.card.zikr.note),
          state: reminder.state)
      })
    guard let data = try? JSONEncoder().encode(stored), let text = String(data: data, encoding: .utf8) else {
      return #"{"reminders":[]}"#
    }
    return text
  }

  /// A plan is a convenience, not a record: anything unreadable is simply no plan.
  static func decode(_ text: String?) -> [PlannedReminder] {
    guard let data = text?.data(using: .utf8),
      let stored = try? JSONDecoder().decode(StoredPlan.self, from: data)
    else { return [] }
    return stored.reminders.compactMap { reminder in
      guard let fireAt = iso.date(from: reminder.at) ?? isoWithFraction.date(from: reminder.at) else { return nil }
      return PlannedReminder(
        fireAt: fireAt,
        card: Card(
          zikr: Zikr(text: reminder.zikr.text, count: reminder.zikr.count, note: reminder.zikr.note, ref: nil),
          session: reminder.session, position: reminder.position, total: reminder.total),
        state: reminder.state)
    }
  }
}
