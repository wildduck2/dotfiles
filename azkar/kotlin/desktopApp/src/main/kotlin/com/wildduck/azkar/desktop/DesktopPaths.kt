// Where Azkar keeps its files on each desktop.
package com.wildduck.azkar.desktop

import java.nio.file.Path
import kotlin.io.path.Path
import kotlin.io.path.div

enum class Os { Linux, Windows, MacOS }

fun osFrom(name: String): Os = when {
    name.startsWith("Windows", ignoreCase = true) -> Os.Windows
    name.startsWith("Mac", ignoreCase = true) -> Os.MacOS
    else -> Os.Linux
}

/**
 * config.json and azkar.json go where the desktop keeps settings, state.json where it keeps state that
 * nobody edits. On macOS these are the paths the Swift app already uses.
 */
class DesktopPaths(val os: Os, private val env: Map<String, String?>, private val home: Path) {
    val configDir: Path = when (os) {
        Os.Linux -> xdg("XDG_CONFIG_HOME", ".config")
        Os.Windows -> appData("APPDATA", "Roaming")
        Os.MacOS -> home / ".config"
    } / "azkar"

    val stateDir: Path = when (os) {
        Os.Linux -> xdg("XDG_STATE_HOME", ".local/state")
        Os.Windows -> appData("LOCALAPPDATA", "Local")
        Os.MacOS -> home / ".local/state"
    } / "azkar"

    /** Where a desktop entry for the menu belongs (Linux only). */
    val dataDir: Path = xdg("XDG_DATA_HOME", ".local/share")

    val configFile: Path get() = configDir / "config.json"
    val azkarFile: Path get() = configDir / "azkar.json"
    val stateFile: Path get() = stateDir / "state.json"

    // The XDG spec says a relative path is invalid and must be ignored.
    private fun xdg(name: String, fallback: String): Path =
        env[name]?.takeIf { it.isNotBlank() }?.let(::Path)?.takeIf { it.isAbsolute } ?: (home / fallback)

    private fun appData(name: String, fallback: String): Path =
        env[name]?.takeIf { it.isNotBlank() }?.let(::Path) ?: (home / "AppData" / fallback)

    companion object {
        fun current(): DesktopPaths = DesktopPaths(
            osFrom(System.getProperty("os.name") ?: ""),
            System.getenv(),
            Path(System.getProperty("user.home")),
        )
    }
}
