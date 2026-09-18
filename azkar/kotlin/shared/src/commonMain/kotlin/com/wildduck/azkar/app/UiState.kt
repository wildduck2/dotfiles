// What every platform's UI shows, and what each platform can offer.
package com.wildduck.azkar.app

import com.wildduck.azkar.core.Config
import com.wildduck.azkar.core.KeyStyle
import com.wildduck.azkar.core.Library
import com.wildduck.azkar.core.TimeWindow

/** What this platform can do, so one settings page can serve all of them. */
data class Features(
    /** How shortcuts are written: ⌃⌥Z, Ctrl+Alt+Z, Win+Z. */
    val keyStyle: KeyStyle,
    /** The app takes a global shortcut of its own. */
    val shortcut: Boolean = true,
    /** Starting at login is offered. */
    val openAtLogin: Boolean = true,
    /** Reminders are cards on screen; on a phone they are notifications instead. */
    val cards: Boolean = true,
    /** A sound can play with a new reminder. */
    val sound: Boolean = true,
    /** The waiting cards are counted next to the tray icon. */
    val showCount: Boolean = true,
    /** The three files can be opened by hand; inside a phone app's storage they can't. */
    val files: Boolean = true,
    /** The app can be quit. On a phone the system decides when an app stops. */
    val quit: Boolean = true,
    /** A reminder carries a Count button. Without one — and without a shortcut — the card itself counts. */
    val countButton: Boolean = false,
) {
    companion object {
        val linux = Features(KeyStyle.Linux)
        val windows = Features(KeyStyle.Windows)
        val macOS = Features(KeyStyle.Apple)
        val android = phone(KeyStyle.Windows, countButton = true)
        val ios = phone(KeyStyle.Apple)

        /** A phone: notifications instead of cards, and no shortcut, login item, tray count, files or quitting. */
        private fun phone(keyStyle: KeyStyle, countButton: Boolean = false) = Features(
            keyStyle,
            shortcut = false,
            openAtLogin = false,
            cards = false,
            showCount = false,
            files = false,
            quit = false,
            countButton = countButton,
        )
    }
}

/** The things that can be wrong, in the order they are shown. One of each at a time. */
enum class ProblemKey { Config, Azkar, Shortcut, Login, Notifications, Alarms, Instance }

/** A button offered next to a problem, when something can be done about it. */
enum class ProblemAction(val label: String) {
    ShowConfigFolder("Show the folder"),
    OpenShortcutSettings("Open keyboard settings"),
    OpenNotificationSettings("Open notification settings"),
    OpenAlarmSettings("Allow exact alarms"),
    TryAgain("Try again"),
}

data class Problem(val key: ProblemKey, val text: String, val action: ProblemAction? = null)

/** Who holds the global shortcut. */
sealed interface ShortcutMode {
    /** The app itself, so it can be recorded in settings. */
    data object App : ShortcutMode

    /** The desktop (the Wayland portal): it can only be changed there, so say where. */
    data class SystemSettings(val hint: String) : ShortcutMode

    /** There are no global shortcuts on this platform. */
    data object None : ShortcutMode
}

data class ShortcutInfo(val display: String = "", val mode: ShortcutMode = ShortcutMode.App)

/** Everything the windows draw. */
data class UiState(
    val config: Config = Config(),
    val library: Library = Library(),
    val paused: Boolean = false,
    /** Seconds until the next reminder; null while paused or when none is coming. */
    val nextIn: Int? = null,
    /** Why the last reminder didn't show a card, if it didn't. */
    val lastSkip: String? = null,
    val onScreen: Int = 0,
    val sabahDone: Int = 0,
    val sabahTotal: Int = 0,
    val masaaDone: Int = 0,
    val masaaTotal: Int = 0,
    val shortcut: ShortcutInfo = ShortcutInfo(),
    val problems: List<Problem> = emptyList(),
    /** A short message about what just happened ("Saved"), shown for a moment. */
    val notice: String? = null,
)

/** The three daily windows, so one settings control serves all of them. */
enum class WindowKey(val label: String) {
    Sabah("Morning azkar"),
    Masaa("Evening azkar"),
    Quiet("Quiet hours"),
    ;

    fun of(config: Config): TimeWindow? = when (this) {
        Sabah -> config.sabah
        Masaa -> config.masaa
        Quiet -> config.quietHours
    }

    fun set(config: Config, window: TimeWindow?): Config = when (this) {
        Sabah -> config.copy(sabah = window)
        Masaa -> config.copy(masaa = window)
        Quiet -> config.copy(quietHours = window)
    }
}
