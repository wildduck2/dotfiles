// The words on a card, wherever the card shows up: a window on the Mac, a notification on a phone.
import Foundation

/// What the last reminder of a plan says, since nothing is scheduled after it.
let keepGoing = "Open Azkar to keep reminders coming"

extension Session {
  /// The heading of a card, in Arabic.
  var title: String {
    switch self {
    case .sabah: "أذكار الصباح"
    case .masaa: "أذكار المساء"
    case .general: "ذِكْر"
    }
  }
}

/// "أذكار الصباح · 7 من 25": which list this zikr came from, and where in it. A general zikr has no place.
func cardHeader(_ card: Card, separator: String = "  ·  ") -> String {
  guard let position = card.position, let total = card.total else { return card.session.title }
  return card.session.title + separator + "\(position) من \(total)"
}

/// The zikr as one piece of text: what to say, with its note under it.
func cardBody(_ zikr: Zikr) -> String {
  guard let note = zikr.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    return zikr.text
  }
  return zikr.text + "\n\n" + note
}

/// A notification's body. The last one of a plan also says how to keep them coming.
func notificationBody(_ zikr: Zikr, last: Bool = false) -> String {
  last ? cardBody(zikr) + "\n\n" + keepGoing : cardBody(zikr)
}
