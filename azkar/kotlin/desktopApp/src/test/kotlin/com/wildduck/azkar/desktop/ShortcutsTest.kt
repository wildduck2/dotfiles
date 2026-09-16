package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.ShortcutMode
import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.Modifier
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ShortcutsTest {
    @Test
    fun whichBackendEachDesktopGets() {
        assertEquals(
            ShortcutBackend.Windows,
            pickBackend(Os.Windows, null, portalAvailable = false),
            "Windows has RegisterHotKey",
        )
        assertEquals(
            ShortcutBackend.X11,
            pickBackend(Os.Linux, "x11", portalAvailable = false),
            "X11 lets the app grab the key",
        )
        assertEquals(
            ShortcutBackend.X11,
            pickBackend(Os.Linux, null, portalAvailable = true),
            "so does a session that doesn't say what it is",
        )
        assertEquals(
            ShortcutBackend.Portal,
            pickBackend(Os.Linux, "Wayland", portalAvailable = true),
            "Wayland goes through the portal",
        )
        assertEquals(
            ShortcutBackend.None,
            pickBackend(Os.Linux, "wayland", portalAvailable = false),
            "and without a portal there is no global shortcut",
        )
        assertEquals(
            ShortcutBackend.None,
            pickBackend(Os.MacOS, null, portalAvailable = false),
            "the macOS app has its own",
        )
    }

    @Test
    fun withoutABackendTheAppSaysSo() {
        val shortcuts = shortcutsFor(ShortcutBackend.None, ShortcutEvents())
        assertEquals(ShortcutMode.None, shortcuts.mode, "nothing to record")
        val problem = shortcuts.bind(Hotkey(setOf(Modifier.Ctrl), "z"))
        assertTrue(problem!!.isNotEmpty(), "and it explains why: $problem")
        shortcuts.close()
    }

    @Test
    fun theKeyboardSettingsToOffer() {
        val linux = shortcutSettingsCommands(Os.Linux)
        assertEquals(
            listOf("gnome-control-center", "keyboard"),
            linux.first(),
            "GNOME first: that is where the portal's own shortcut dialog lives",
        )
        assertTrue(linux.any { "systemsettings" in it.first() }, "then KDE")
        assertEquals(emptyList(), shortcutSettingsCommands(Os.Windows), "on Windows the app holds the shortcut itself")
    }
}
