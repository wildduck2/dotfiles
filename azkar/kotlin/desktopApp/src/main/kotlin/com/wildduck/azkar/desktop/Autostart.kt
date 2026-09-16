// Starting Azkar when you log in: a desktop entry on Linux, a Run value on Windows.
package com.wildduck.azkar.desktop

import java.nio.file.Path
import kotlin.io.path.createDirectories
import kotlin.io.path.deleteIfExists
import kotlin.io.path.exists
import kotlin.io.path.readText
import kotlin.io.path.writeText

/** The file name both the autostart and the menu entry use. */
const val DESKTOP_ENTRY = "com.wildduck.azkar.desktop"

/** The desktop entry, as an autostart entry (`--background`) or as the app's place in the menu. */
fun desktopEntry(exec: String, background: Boolean): String {
    val command = if (" " in exec) "\"$exec\"" else exec
    val lines = mutableListOf(
        "[Desktop Entry]",
        "Type=Application",
        "Name=Azkar",
        "Comment=A zikr card every few minutes",
        "Exec=$command" + if (background) " --background" else "",
        "Icon=azkar",
        "Terminal=false",
        "Categories=Utility;",
        "StartupNotify=false",
    )
    if (background) lines += "X-GNOME-Autostart-enabled=true"
    return lines.joinToString("\n", postfix = "\n")
}

/** The value Windows runs at login. Quoted, because the path has spaces in it. */
fun windowsRunValue(exe: String): String = "\"$exe\" --background"

interface Autostart {
    val supported: Boolean get() = true

    fun isEnabled(): Boolean

    /** Null when it worked, otherwise what went wrong, for the settings page. */
    fun set(enabled: Boolean): String?

    /** Puts Azkar in the desktop's menu, if that's something the app does here. */
    fun installMenuEntry(): Path? = null
}

class LinuxAutostart(private val paths: DesktopPaths, private val command: String) : Autostart {
    // ~/.config/autostart is a sibling of ~/.config/azkar.
    private val entry: Path get() = paths.configDir.parent.resolve("autostart").resolve(DESKTOP_ENTRY)

    override fun isEnabled(): Boolean = entry.exists() && "X-GNOME-Autostart-enabled=false" !in entry.readText()

    override fun set(enabled: Boolean): String? = try {
        if (enabled) {
            entry.parent.createDirectories()
            entry.writeText(desktopEntry(command, background = true))
        } else {
            entry.deleteIfExists()
        }
        null
    } catch (e: Exception) {
        "Open at login: ${e.message ?: "the autostart entry could not be written"}"
    }

    /** So Azkar shows up in the launcher, as an installed .deb would. */
    override fun installMenuEntry(): Path? = try {
        val menu = paths.dataDir.resolve("applications").resolve(DESKTOP_ENTRY)
        menu.parent.createDirectories()
        val text = desktopEntry(command, background = false)
        if (!menu.exists() || menu.readText() != text) menu.writeText(text)
        menu
    } catch (_: Exception) {
        null
    }
}

class WindowsAutostart(private val command: String) : Autostart {
    override fun isEnabled(): Boolean = try {
        com.sun.jna.platform.win32.Advapi32Util.registryValueExists(
            com.sun.jna.platform.win32.WinReg.HKEY_CURRENT_USER,
            RUN_KEY,
            "Azkar",
        )
    } catch (_: Throwable) {
        false
    }

    override fun set(enabled: Boolean): String? = try {
        val key = com.sun.jna.platform.win32.WinReg.HKEY_CURRENT_USER
        if (enabled) {
            com.sun.jna.platform.win32.Advapi32Util.registrySetStringValue(
                key,
                RUN_KEY,
                "Azkar",
                windowsRunValue(command),
            )
        } else if (isEnabled()) {
            com.sun.jna.platform.win32.Advapi32Util.registryDeleteValue(key, RUN_KEY, "Azkar")
        }
        null
    } catch (e: Throwable) {
        "Open at login: ${e.message ?: "the registry could not be changed"}"
    }

    private companion object {
        const val RUN_KEY = "Software\\Microsoft\\Windows\\CurrentVersion\\Run"
    }
}

/** Nothing to do: the macOS app starts itself through its LaunchAgent. */
object NoAutostart : Autostart {
    override val supported = false

    override fun isEnabled() = false

    override fun set(enabled: Boolean) = "Open at login isn't set up by this build."
}

fun autostartFor(paths: DesktopPaths, command: String): Autostart = when (paths.os) {
    Os.Linux -> LinuxAutostart(paths, command)
    Os.Windows -> WindowsAutostart(command)
    Os.MacOS -> NoAutostart
}

/** The program to start at login: the packaged launcher when there is one. */
fun launcherCommand(): String =
    ProcessHandle.current().info().command().orElse(null)?.takeIf { "java" !in it.substringAfterLast('/') }
        ?: "azkar"
