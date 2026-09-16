// The app itself, without a screen: the files, today's progress, and everything the windows show.
package com.wildduck.azkar.app

import com.wildduck.azkar.core.AppState
import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Config
import com.wildduck.azkar.core.ConfigError
import com.wildduck.azkar.core.Library
import com.wildduck.azkar.core.Picker
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.TimeWindow
import com.wildduck.azkar.core.TickDecision
import com.wildduck.azkar.core.dayKey
import com.wildduck.azkar.core.decideTick
import com.wildduck.azkar.core.minuteOfDay
import kotlin.math.min
import kotlin.random.Random
import kotlin.time.Instant
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

/**
 * Holds the three files and the progress through today's lists, and publishes [ui] for the windows to draw.
 * Everything a platform does for itself — showing cards, scheduling, shortcuts — it reports back through the
 * `set…` methods, so the settings page and the tray menu look the same everywhere.
 */
class AzkarController(
    private val storage: Storage,
    val features: Features,
    private val timeZone: () -> TimeZone = { TimeZone.currentSystemDefault() },
) {
    private val _ui = MutableStateFlow(UiState())
    val ui: StateFlow<UiState> = _ui.asStateFlow()

    /** Today's progress, as it was last saved. */
    var state: AppState = AppState()
        private set

    private var stamp: Any? = null
    private val problems = linkedMapOf<ProblemKey, Problem>()
    private val remembered = mutableMapOf<WindowKey, TimeWindow>()

    init {
        state = StateFile.decode(storage.readState())
        _ui.value = _ui.value.copy(paused = state.paused)
        reload(force = true)
    }

    /** Re-reads config.json and azkar.json if they have changed; true if they were read. */
    fun reload(force: Boolean = false): Boolean {
        val mark = storage.stamp()
        if (!force && mark == stamp) return false
        stamp = mark

        val configText = storage.readConfig()
        if (configText == null) {
            // No config.json yet: everything at its default.
            useConfig(Config())
            setProblem(ProblemKey.Config, null)
        } else {
            try {
                useConfig(Config.decode(configText))
                setProblem(ProblemKey.Config, null)
            } catch (e: ConfigError) {
                // Keep the settings that were working until the file is fixed.
                setProblem(ProblemKey.Config, "config.json: ${e.message}", ProblemAction.ShowConfigFolder)
            }
        }

        val azkarText = storage.readAzkar()
        if (azkarText == null) {
            setProblem(ProblemKey.Azkar, "azkar.json is missing", ProblemAction.ShowConfigFolder)
        } else {
            try {
                _ui.value = _ui.value.copy(library = Library.decode(azkarText))
                setProblem(ProblemKey.Azkar, null)
            } catch (e: ConfigError) {
                setProblem(ProblemKey.Azkar, "azkar.json: ${e.message}", ProblemAction.ShowConfigFolder)
            }
        }
        return true
    }

    /** Saves the settings to config.json. */
    fun setConfig(config: Config) {
        storage.writeConfig(config.encode())
        // Our own write is not a change to reload.
        stamp = storage.stamp()
        useConfig(config)
    }

    /** The times a switched-off window had, so switching it back on doesn't start from nothing. */
    fun rememberedWindow(key: WindowKey): TimeWindow = remembered[key] ?: checkNotNull(key.of(Config()))

    /** The next card, with today's progress moved on and saved. Null when there is nothing to show. */
    fun pick(now: Instant, random: (Int) -> Int = { Random.nextInt(it) }): Card? {
        val ui = _ui.value
        val pick = Picker.next(now.toLocalDateTime(timeZone()), ui.config, ui.library, state, random)
        save(pick.state)
        return pick.card
    }

    /**
     * One reminder: the next card, or why there isn't one. The desktop passes the cards already on screen and
     * whether the screen is locked; a phone passes the notifications it has posted.
     */
    fun fire(
        now: Instant,
        onScreen: Int,
        locked: Boolean = false,
        random: (Int) -> Int = { Random.nextInt(it) },
    ): Fired {
        val config = _ui.value.config
        val quiet = config.quietHours?.contains(minuteOfDay(now.toLocalDateTime(timeZone()))) ?: false
        val decision = decideTick(
            paused = state.paused,
            locked = locked,
            quiet = quiet,
            stackCount = onScreen,
            maxStack = config.maxStack,
        )
        return when (decision) {
            TickDecision.Show -> pick(now, random)?.let { Fired.Show(it) } ?: Fired.Skip("nothing to show")
            is TickDecision.Skip -> Fired.Skip(decision.reason)
        }
    }

    fun setPaused(paused: Boolean) = save(state.copy(paused = paused))

    /** Starts one of today's lists again. */
    fun restart(session: Session, now: Instant) {
        val fresh = today(now)
        save(
            when (session) {
                Session.Sabah -> fresh.copy(sabah = 0)
                Session.Masaa -> fresh.copy(masaa = 0)
                Session.General -> fresh.copy(general = 0, lastGeneral = null)
            },
        )
    }

    /** What the app is doing right now, for the today page and the tray menu. */
    fun setStatus(now: Instant, nextFire: Instant?, lastSkip: String? = null, onScreen: Int = 0) {
        val ui = _ui.value
        val progress = today(now)
        _ui.value = ui.copy(
            nextIn = if (state.paused || nextFire == null) {
                null
            } else {
                ((nextFire - now).inWholeSeconds).coerceAtLeast(0).toInt()
            },
            lastSkip = lastSkip,
            onScreen = onScreen,
            sabahDone = min(progress.sabah, ui.library.sabah.size),
            sabahTotal = ui.library.sabah.size,
            masaaDone = min(progress.masaa, ui.library.masaa.size),
            masaaTotal = ui.library.masaa.size,
        )
    }

    /** Shows a problem, or clears it when `text` is null. */
    fun setProblem(key: ProblemKey, text: String?, action: ProblemAction? = null) {
        if (text == null) problems.remove(key) else problems[key] = Problem(key, text, action)
        _ui.value = _ui.value.copy(problems = ProblemKey.entries.mapNotNull { problems[it] })
    }

    fun setShortcut(shortcut: ShortcutInfo) {
        _ui.value = _ui.value.copy(shortcut = shortcut)
    }

    fun setNotice(notice: String?) {
        _ui.value = _ui.value.copy(notice = notice)
    }

    private fun useConfig(config: Config) {
        for (key in WindowKey.entries) key.of(config)?.let { remembered[key] = it }
        _ui.value = _ui.value.copy(config = config)
    }

    /** The saved progress if it is today's, or a fresh day. */
    private fun today(now: Instant): AppState {
        val day = dayKey(now.toLocalDateTime(timeZone()))
        return if (state.day == day) state else state.copy(day = day, sabah = 0, masaa = 0)
    }

    private fun save(next: AppState) {
        state = next
        storage.writeState(StateFile.encode(next))
        _ui.value = _ui.value.copy(paused = next.paused)
    }
}
