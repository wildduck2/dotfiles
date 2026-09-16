// Taking a global shortcut, in whatever way this desktop allows it.
package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.ShortcutInfo
import com.wildduck.azkar.app.ShortcutMode
import com.wildduck.azkar.core.Hotkey

/** What a backend tells the app while it runs. */
class ShortcutEvents(
    /** The shortcut was pressed. Called from a background thread. */
    val onPress: () -> Unit = {},
    /** How the shortcut should be shown now (the portal names its own trigger). */
    val onInfo: (ShortcutInfo) -> Unit = {},
    /** Something went wrong, or is fine again (null). */
    val onProblem: (String?) -> Unit = {},
)

interface Shortcuts : AutoCloseable {
    /** Who owns the binding, for the settings page. */
    val mode: ShortcutMode

    /** Takes (or re-takes) the shortcut; null when it worked, otherwise what to show. */
    fun bind(hotkey: Hotkey): String?

    override fun close() {}
}

/** Nothing here can take a global shortcut; `reason` says why. */
class NoShortcuts(private val reason: String) : Shortcuts {
    override val mode = ShortcutMode.None

    override fun bind(hotkey: Hotkey): String = reason
}

enum class ShortcutBackend { Windows, X11, Portal, None }

/**
 * X11 lets an app grab keys itself; Wayland doesn't, so the shortcut goes through the desktop's portal.
 * On macOS the app in `apple/` does this, with its own Carbon hotkey.
 */
fun pickBackend(os: Os, sessionType: String?, portalAvailable: Boolean): ShortcutBackend = when {
    os == Os.Windows -> ShortcutBackend.Windows
    os == Os.MacOS -> ShortcutBackend.None
    sessionType.equals("wayland", ignoreCase = true) ->
        if (portalAvailable) ShortcutBackend.Portal else ShortcutBackend.None
    else -> ShortcutBackend.X11
}

/** The backend for this machine, ready to bind. */
fun shortcutsFor(backend: ShortcutBackend, events: ShortcutEvents): Shortcuts = when (backend) {
    ShortcutBackend.Windows -> WindowsShortcut(events)
    ShortcutBackend.X11 -> X11Shortcut(events)
    ShortcutBackend.Portal -> PortalShortcut(events)
    ShortcutBackend.None -> NoShortcuts(
        "This desktop doesn't let an app take a global shortcut; click a card to count it.",
    )
}
