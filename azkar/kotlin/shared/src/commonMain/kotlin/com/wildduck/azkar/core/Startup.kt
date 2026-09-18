// Whether the window opens when the app starts. (The macOS LaunchAgent plist stays in Swift.)
package com.wildduck.azkar.core

/** Opened by hand: always. Started at login (`--background`): only if asked. */
fun opensWindowAtLaunch(arguments: List<String>, config: Config): Boolean =
    "--background" !in arguments || config.showWindowAtLogin
