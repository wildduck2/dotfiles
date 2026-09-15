import Foundation

/// Starting at login (the LaunchAgent), and whether the window opens when the app starts.
func startupTests() {
  let exe = "/Apps/Azkar.app/Contents/MacOS/Azkar"
  let data = launchAgentPlist(label: "com.example.azkar", executable: exe)
  if let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
    eq(plist["Label"] as? String, "com.example.azkar", "launch agent label")
    eq(plist["ProgramArguments"] as? [String], [exe, "--background"], "login starts the app in the background")
    eq(plist["RunAtLoad"] as? Bool, true, "runs at login")
    eq((plist["KeepAlive"] as? [String: Bool])?["SuccessfulExit"], false, "restarted only if it crashes")
    eq(plist["ProcessType"] as? String, "Interactive", "interactive process")
  } else {
    failed += 1
    print("FAIL launch agent plist doesn't parse")
  }

  var c = Config()
  check(opensWindowAtLaunch(arguments: ["Azkar"], config: c), "opened by hand: the window shows")
  check(!opensWindowAtLaunch(arguments: ["Azkar", "--background"], config: c), "at login: menu bar only")
  c.showWindowAtLogin = true
  check(opensWindowAtLaunch(arguments: ["Azkar", "--background"], config: c), "at login, if asked: the window shows")
}
