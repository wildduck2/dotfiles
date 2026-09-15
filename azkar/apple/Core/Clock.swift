// Clock times (minutes after midnight) and the daily time windows made from them.
import Foundation

/// "HH:mm" (or "H:mm") -> minutes after midnight.
func parseClock(_ s: String) -> Int? {
  let parts = s.split(separator: ":", omittingEmptySubsequences: false)
  guard parts.count == 2, parts[1].count == 2,
    let h = Int(parts[0]), let m = Int(parts[1]),
    (0..<24).contains(h), (0..<60).contains(m)
  else { return nil }
  return h * 60 + m
}

/// Minutes after midnight -> "HH:mm".
func formatClock(_ minutes: Int) -> String {
  String(format: "%02d:%02d", minutes / 60, minutes % 60)
}

func minuteOfDay(_ date: Date, _ calendar: Calendar) -> Int {
  let c = calendar.dateComponents([.hour, .minute], from: date)
  return c.hour! * 60 + c.minute!
}

func dayKey(_ date: Date, _ calendar: Calendar) -> String {
  let c = calendar.dateComponents([.year, .month, .day], from: date)
  return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
}

/// [start, end) in minutes after midnight; wraps past midnight when end < start.
struct TimeWindow: Equatable {
  var start: Int
  var end: Int

  func contains(minuteOfDay m: Int) -> Bool {
    start <= end ? (start <= m && m < end) : (m >= start || m < end)
  }
}
