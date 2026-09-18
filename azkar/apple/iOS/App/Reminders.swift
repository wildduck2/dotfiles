// The reminders iOS delivers while Azkar isn't running: one notification per planned card.
import Foundation
import UserNotifications

enum Reminders {
  /// iOS keeps at most 64 pending notifications per app, which is how long a plan is.
  static let limit = 64

  private static var center: UNUserNotificationCenter { .current() }

  /// Asks the first time; after that it only reports the answer given.
  static func authorize() async -> UNAuthorizationStatus {
    let status = await center.notificationSettings().authorizationStatus
    guard status == .notDetermined else { return status }
    _ = try? await center.requestAuthorization(options: [.alert, .sound])
    return await center.notificationSettings().authorizationStatus
  }

  /// Replaces everything still pending with this plan. Delivered notifications are left alone:
  /// those are the azkar waiting to be opened.
  static func schedule(_ plan: [PlannedReminder], sound: Bool) async {
    center.removeAllPendingNotificationRequests()
    let calendar = Calendar.current
    for (i, reminder) in plan.enumerated() {
      let content = UNMutableNotificationContent()
      content.title = cardHeader(reminder.card)
      content.body = notificationBody(reminder.card.zikr, last: i == plan.count - 1)
      // One thread per list, so the morning azkar stack together and the evening ones apart.
      content.threadIdentifier = reminder.card.session.rawValue
      content.sound = sound ? .default : nil
      // The card the notification opens travels with it, so a tap needs no guesswork.
      content.userInfo = ["azkar": PlanFile.encode([reminder])]
      let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.fireAt)
      let request = UNNotificationRequest(
        identifier: "azkar-\(i)",
        content: content,
        trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false))
      try? await center.add(request)
    }
  }

  /// How many reminders are still to come.
  static func pending() async -> Int { await center.pendingNotificationRequests().count }
}
