func clockTests() {
  // parsing
  eq(parseClock("05:30"), 330, "parses HH:mm")
  eq(parseClock("5:30"), 330, "parses H:mm")
  eq(parseClock("00:00"), 0, "parses midnight")
  eq(parseClock("24:00"), nil, "rejects hour 24")
  eq(parseClock("12:60"), nil, "rejects minute 60")
  eq(parseClock("noon"), nil, "rejects garbage")
  eq(minuteOfDay(at(14, 15, 30), cal), 930, "minute of day")
  eq(dayKey(at(4, 23, 59), cal), "2026-09-04", "day key is yyyy-MM-dd")

  // time windows
  let morning = TimeWindow(start: 300, end: 660)
  check(morning.contains(minuteOfDay: 300), "window includes its start")
  check(morning.contains(minuteOfDay: 659), "window includes the minute before its end")
  check(!morning.contains(minuteOfDay: 660), "window excludes its end")
  check(!morning.contains(minuteOfDay: 299), "window excludes before start")

  let night = TimeWindow(start: 1410, end: 300)  // 23:30 -> 05:00
  check(night.contains(minuteOfDay: 1425), "overnight window includes 23:45")
  check(night.contains(minuteOfDay: 10), "overnight window includes 00:10")
  check(!night.contains(minuteOfDay: 300), "overnight window excludes 05:00")
  check(!night.contains(minuteOfDay: 720), "overnight window excludes noon")

  // formatting
  eq(formatClock(330), "05:30", "formats minutes as HH:mm")
  eq(formatClock(0), "00:00", "formats midnight")
  eq(formatClock(1439), "23:59", "formats the last minute")
}
