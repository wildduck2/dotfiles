import Foundation

/// The reminders an iPhone schedules ahead as notifications (kotlin/shared PlanTest has the same cases).
func planTests() {
  func plan(
    _ now: Date, config: Config = Config(), library: Library = lib, state: AppState = AppState(), limit: Int = 64
  ) -> [PlannedReminder] {
    Plan.make(now: now, calendar: cal, config: config, library: library, state: state, limit: limit, random: firstIndex)
  }

  do {
    let p = plan(at(14, 12, 0))
    eq(p.first?.fireAt, at(14, 12, 3), "the first reminder is one interval after now")
    eq(p.dropFirst().first?.fireAt, at(14, 12, 6), "reminders are one interval apart")
    eq(p.count, 64, "up to 64 reminders")
  }

  do {
    var cfg = Config()
    cfg.maxStack = 1
    eq(plan(at(14, 12, 0), config: cfg).count, 64, "maxStack does not limit the plan")
    eq(plan(at(14, 12, 0), limit: 5).count, 5, "stops at the limit")
  }

  do {
    var cfg = Config()
    cfg.intervalMinutes = 60
    cfg.quietHours = nil
    let p = plan(at(14, 12, 0), config: cfg)
    eq(p.count, 48, "stops at the horizon")
    eq(p.last?.fireAt, at(16, 12, 0), "a reminder exactly at the horizon is included")
  }

  do {
    var cfg = Config()
    cfg.intervalMinutes = 30
    eq(plan(at(14, 23, 0), config: cfg).first?.fireAt, at(15, 5, 0), "quiet hours are skipped")
  }

  do {
    let p = plan(at(14, 5, 57))
    eq(p.prefix(4).map(\.card.zikr.text), ["s1", "s2", "s3", "g1"], "the morning list continues through the plan")
    eq(p.first?.state.sabah, 1, "each reminder carries the state after its card")
    eq(p.dropFirst(2).first?.state.sabah, 3, "the state after the third card")
    let resumed = plan(at(14, 6, 0), state: AppState(day: "2026-09-14", sabah: 2))
    eq(resumed.first?.card.zikr.text, "s3", "the plan starts from the given state")
  }

  do {
    var cfg = Config()
    cfg.intervalMinutes = 60
    cfg.quietHours = nil
    let p = plan(at(14, 9, 30), config: cfg)
    eq(
      p.first { $0.fireAt == at(15, 5, 30) }?.card.zikr.text, "s1",
      "a new day restarts the morning list inside the plan")
  }

  do {
    var paused = AppState()
    paused.paused = true
    eq(plan(at(14, 12, 0), state: paused).count, 0, "a paused state plans nothing")
    let empty = Library(sabah: [], masaa: [], general: [])
    eq(plan(at(14, 12, 0), library: empty).count, 0, "nothing to show plans nothing")
    var cfg = Config()
    cfg.intervalMinutes = 0
    eq(plan(at(14, 12, 0), config: cfg).count, 0, "a zero interval plans nothing")
  }

  // Committing: the app keeps the state of the reminders that have fired, then makes a new plan.
  do {
    let start = AppState(day: "2026-09-14")
    let p = plan(at(14, 6, 0), state: start)  // 06:03 s1, 06:06 s2, 06:09 s3, …
    eq(Plan.commit(p, now: at(14, 6, 2), current: start), start, "before any reminder fires, the state stays as it is")
    eq(
      Plan.commit(p, now: at(14, 6, 7), current: start), p[1].state,
      "commit keeps the state after the last reminder that fired")
    eq(Plan.commit(p, now: at(14, 6, 9), current: start), p[2].state, "a reminder firing exactly now counts as fired")
    eq(
      Plan.commit(p, now: at(20, 0, 0), current: start), p.last?.state,
      "after the whole plan, the last reminder's state")
    eq(Plan.commit([], now: at(14, 6, 7), current: start), start, "an empty plan keeps the current state")
  }
}
