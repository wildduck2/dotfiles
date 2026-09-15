import Foundation

/// "Open at login" writes or removes the LaunchAgent plist.
func loginItemTests() {
  let dir = FileManager.default.temporaryDirectory.appendingPathComponent("azkar-login-\(UUID().uuidString)")
  defer { try? FileManager.default.removeItem(at: dir) }
  let url = dir.appendingPathComponent("LaunchAgents/com.example.azkar.plist")
  let exe = "/Apps/Azkar.app/Contents/MacOS/Azkar"
  let item = LoginItem(label: "com.example.azkar", url: url, executable: exe)

  check(!item.isEnabled, "off before anything is written")
  eq(item.set(enabled: true), nil, "switching on works")
  eq(try? Data(contentsOf: url), launchAgentPlist(label: "com.example.azkar", executable: exe), "writes the agent")
  check(item.isEnabled, "and reads as on")
  eq(item.set(enabled: true), nil, "switching on again is fine")
  eq(item.set(enabled: false), nil, "switching off works")
  check(!FileManager.default.fileExists(atPath: url.path), "removes the agent")
  check(!item.isEnabled, "and reads as off")
  eq(item.set(enabled: false), nil, "switching off again is fine")
}
