// The files on a phone: config.json, state.json and plan.json in the app's own storage.
// azkar.json ships inside the app — there is no ~/.config to read from here.
import Foundation

struct Files {
  let directory: URL

  /// Application Support inside Azkar's container. Nothing else on the phone can see it.
  static let shared = Files(
    directory: FileManager.default
      .urls(for: .applicationSupportDirectory, in: .userDomainMask)
      .first?
      .appendingPathComponent("Azkar", isDirectory: true)
      ?? URL(fileURLWithPath: NSTemporaryDirectory()))

  var configFile: URL { directory.appendingPathComponent("config.json") }
  var stateFile: URL { directory.appendingPathComponent("state.json") }
  var planFile: URL { directory.appendingPathComponent("plan.json") }

  /// The settings, or the defaults before anything has been changed. Throws only for a file that
  /// is there and unreadable, which is worth telling the person about.
  func loadConfig() throws -> Config {
    guard let data = read(configFile) else { return Config() }
    return try Config.decode(data)
  }

  func save(config: Config) throws { try write(config.encode(), to: configFile) }

  /// The three lists, from the copy that ships with the app.
  func loadLibrary() throws -> Library {
    guard let url = Bundle.main.url(forResource: "azkar", withExtension: "json"), let data = read(url) else {
      throw ConfigError("azkar.json is missing from the app")
    }
    return try Library.decode(data)
  }

  /// Today's progress. A broken file is simply a fresh start.
  func loadState() -> AppState {
    read(stateFile).flatMap { try? JSONDecoder().decode(AppState.self, from: $0) } ?? AppState()
  }

  func save(state: AppState) { try? write(JSONEncoder().encode(state), to: stateFile) }

  /// The reminders already handed to iOS, so a later launch knows which of them have fired.
  func loadPlan() -> [PlannedReminder] {
    PlanFile.decode(read(planFile).flatMap { String(data: $0, encoding: .utf8) })
  }

  func save(plan: [PlannedReminder]) { try? write(Data(PlanFile.encode(plan).utf8), to: planFile) }

  private func read(_ url: URL) -> Data? { try? Data(contentsOf: url) }

  private func write(_ data: Data, to url: URL) throws {
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try data.write(to: url, options: .atomic)
  }
}
