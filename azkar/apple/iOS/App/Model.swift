// Azkar without a screen: the files, the plan, today's progress and the things that need attention.
// Nothing here loops — iOS won't run an app every few minutes — so every entry point ends in
// `refresh()`: take the state from the reminders that have fired, plan the next ones, hand them over.
import Foundation
import Observation
import UserNotifications

/// Something the person can put right, and whether Settings is where to do it.
struct Problem: Identifiable {
  let text: String
  var opensSettings = false
  var id: String { text }
}

@MainActor
@Observable
final class Model {
  private(set) var config = Config()
  private(set) var library = Library(sabah: [], masaa: [], general: [])
  private(set) var state = AppState()
  private(set) var plan: [PlannedReminder] = []
  private(set) var notifications: UNAuthorizationStatus = .notDetermined
  private(set) var fileErrors: [String] = []
  /// Reminders iOS is actually holding, which is what was asked for unless something went wrong.
  private(set) var scheduled = 0
  /// The card on screen: a tapped notification, or "Show a zikr now".
  private(set) var card: Card?
  private(set) var counter = TapCounter(target: 1)

  private let files: Files
  /// Times of a window that was switched off, so switching it back on restores them.
  private var remembered: [WritableKeyPath<Config, TimeWindow?>: TimeWindow] = [:]

  init(files: Files = .shared) { self.files = files }

  // MARK: what the pages show

  /// Seconds until the next reminder, or nil while paused or when none is coming.
  func nextIn(at now: Date) -> Int? {
    guard !state.paused, let next = plan.first(where: { $0.fireAt > now }) else { return nil }
    return Int(next.fireAt.timeIntervalSince(now).rounded(.up))
  }

  var sabahDone: Int { isToday ? state.sabah : 0 }
  var masaaDone: Int { isToday ? state.masaa : 0 }
  private var isToday: Bool { state.day == dayKey(Date(), .current) }

  var problems: [Problem] {
    var list = fileErrors.map { Problem(text: $0) }
    switch notifications {
    case .denied:
      list.append(Problem(text: "Notifications are off, so no reminders can arrive.", opensSettings: true))
    case .provisional:
      list.append(Problem(text: "Reminders arrive quietly, in Notification Centre only.", opensSettings: true))
    default: break
    }
    return list
  }

  // MARK: the round trip

  /// Read the files, take the state from the reminders that have already fired, and plan the next ones.
  func refresh(now: Date = Date()) async {
    load()
    state = Plan.commit(plan, now: now, current: state)
    await replan(now: now)
  }

  private func load() {
    var errors: [String] = []
    do {
      config = try files.loadConfig()
    } catch {
      errors.append("config.json: \(message(error))")
    }
    do {
      library = try files.loadLibrary()
    } catch {
      errors.append("azkar.json: \(message(error))")
    }
    state = files.loadState()
    plan = files.loadPlan()
    fileErrors = errors
  }

  private func replan(now: Date = Date()) async {
    files.save(state: state)
    plan = Plan.make(
      now: now, calendar: .current, config: config, library: library, state: state, limit: Reminders.limit)
    files.save(plan: plan)
    notifications = await Reminders.authorize()
    await Reminders.schedule(plan, sound: config.sound)
    scheduled = await Reminders.pending()
  }

  // MARK: changing things

  /// Every settings control writes straight through: save the file, and re-plan if the reminders
  /// themselves change. Text size doesn't, so it doesn't cost 64 rewritten notifications.
  func save(_ newConfig: Config) async {
    let planned = changesPlan(config, newConfig)
    config = newConfig
    fileErrors.removeAll { $0.hasPrefix("config.json") }
    do {
      try files.save(config: newConfig)
    } catch {
      fileErrors.append("config.json: \(message(error))")
    }
    if planned { await replan() }
  }

  /// True unless the only differences are settings a scheduled reminder doesn't depend on.
  private func changesPlan(_ old: Config, _ new: Config) -> Bool {
    var stripped = new
    stripped.fontSize = old.fontSize
    stripped.maxStack = old.maxStack
    stripped.hotkey = old.hotkey
    stripped.showCount = old.showCount
    stripped.openAtLogin = old.openAtLogin
    stripped.showWindowAtLogin = old.showWindowAtLogin
    return stripped != old
  }

  func setPaused(_ paused: Bool) async {
    guard paused != state.paused else { return }
    state.paused = paused
    await replan()
  }

  /// Today's list starts again from its first zikr.
  func restart(_ session: Session) async {
    let today = dayKey(Date(), .current)
    if state.day != today {
      state = AppState(day: today, general: state.general, lastGeneral: state.lastGeneral, paused: state.paused)
    }
    if session == .sabah { state.sabah = 0 }
    if session == .masaa { state.masaa = 0 }
    await replan()
  }

  /// One zikr straight away, on screen; the reminders after it are planned from there.
  func showNow() async {
    guard
      let next = Picker.next(
        at: Date(), calendar: .current, config: config, library: library, state: &state,
        random: { Int.random(in: 0..<$0) })
    else { return }
    open(next)
    await replan()
  }

  // MARK: the card

  func open(_ card: Card) {
    self.card = card
    counter = TapCounter(target: card.zikr.count)
  }

  /// A tapped notification carries its own card, so opening it needs no guesswork.
  func open(notification userInfo: [AnyHashable: Any]) {
    guard let text = userInfo["azkar"] as? String, let reminder = PlanFile.decode(text).first else { return }
    open(reminder.card)
  }

  /// A tap on the card is one repetition; the last one closes it.
  func count() {
    if counter.tap() { close() }
  }

  func close() { card = nil }

  // MARK: the three daily windows

  func isEnabled(_ w: WritableKeyPath<Config, TimeWindow?>) -> Bool { config[keyPath: w] != nil }

  func setEnabled(_ w: WritableKeyPath<Config, TimeWindow?>, _ on: Bool) async {
    var new = config
    if on {
      if new[keyPath: w] == nil { new[keyPath: w] = remembered[w] ?? Config()[keyPath: w] }
    } else if let current = new[keyPath: w] {
      remembered[w] = current
      new[keyPath: w] = nil
    }
    await save(new)
  }

  func time(_ w: WritableKeyPath<Config, TimeWindow?>, start: Bool) -> Date {
    let window = config[keyPath: w] ?? remembered[w] ?? Config()[keyPath: w] ?? TimeWindow(start: 0, end: 0)
    let m = start ? window.start : window.end
    return Calendar.current.date(bySettingHour: m / 60, minute: m % 60, second: 0, of: Date()) ?? Date()
  }

  func setTime(_ w: WritableKeyPath<Config, TimeWindow?>, start: Bool, to date: Date) async {
    guard var window = config[keyPath: w] else { return }
    let m = minuteOfDay(date, .current)
    if start { window.start = m } else { window.end = m }
    var new = config
    new[keyPath: w] = window
    await save(new)
  }
}
