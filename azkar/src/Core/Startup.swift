// Starting at login, and whether the window opens when the app starts.
import Foundation

/// The LaunchAgent that starts the app at login, in the background, and restarts it if it crashes.
func launchAgentPlist(label: String, executable: String) -> Data {
  let plist: [String: Any] = [
    "Label": label,
    "ProgramArguments": [executable, "--background"],
    "RunAtLoad": true,
    "KeepAlive": ["SuccessfulExit": false],
    "ProcessType": "Interactive",
  ]
  return try! PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
}

/// Opened by hand (Finder, Spotlight, Dock): always. Started at login (`--background`): only if asked.
func opensWindowAtLaunch(arguments: [String], config: Config) -> Bool {
  !arguments.contains("--background") || config.showWindowAtLogin
}
