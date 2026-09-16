// The heartbeat: a card every few minutes, the files watched, and the status line kept fresh.
package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.AzkarController
import com.wildduck.azkar.app.CardStack
import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.TickDecision
import com.wildduck.azkar.core.decideTick
import com.wildduck.azkar.core.minuteOfDay
import kotlin.time.Clock
import kotlin.time.Duration.Companion.seconds
import kotlin.time.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

/** The first card comes right after launch, so a fresh install shows what Azkar does. */
private val FIRST = 5.seconds

/**
 * Ticked once a second by the app. Everything it decides comes from the core: [decideTick] for whether a
 * reminder is due, [AzkarController.pick] for which zikr, and the config for how long to wait.
 * `locked` keeps cards off a locked screen, and `onCard` is where the chime goes.
 */
class Loop(
    private val controller: AzkarController,
    private val stack: CardStack,
    private val now: () -> Instant = { Clock.System.now() },
    private val timeZone: () -> TimeZone = { TimeZone.currentSystemDefault() },
    private val locked: () -> Boolean = { false },
    private val onCard: (Card) -> Unit = {},
) {
    /** When the next reminder is due. */
    var nextFire: Instant = now() + FIRST
        private set

    private var ticks = 0
    private var lastSkip: String? = null

    fun tick() {
        ticks += 1
        // Every other second is often enough to notice an edit, and half the work.
        if (ticks % 2 == 0) controller.reload()
        val at = now()
        if (at >= nextFire) fire(at)
        controller.setStatus(now = at, nextFire = nextFire, lastSkip = lastSkip, onScreen = stack.count)
    }

    /** A card now, whatever the clock says; false when there is nothing to show. */
    fun showNow(): Boolean {
        val at = now()
        val shown = show(at)
        postpone(at)
        controller.setStatus(now = at, nextFire = nextFire, lastSkip = lastSkip, onScreen = stack.count)
        return shown
    }

    /** Switching reminders off, or back on with a whole interval to wait. */
    fun setPaused(paused: Boolean) {
        controller.setPaused(paused)
        val at = now()
        if (!paused) postpone(at)
        controller.setStatus(now = at, nextFire = nextFire, lastSkip = lastSkip, onScreen = stack.count)
    }

    private fun fire(at: Instant) {
        postpone(at)
        val config = controller.ui.value.config
        val quiet = config.quietHours?.contains(minuteOfDay(at.toLocalDateTime(timeZone()))) ?: false
        val decision = decideTick(
            paused = controller.state.paused,
            locked = locked(),
            quiet = quiet,
            stackCount = stack.count,
            maxStack = config.maxStack,
        )
        when (decision) {
            TickDecision.Show -> {
                lastSkip = null
                show(at)
            }
            is TickDecision.Skip -> lastSkip = decision.reason
        }
    }

    private fun show(at: Instant): Boolean {
        val card = controller.pick(at) ?: return false
        stack.push(card)
        onCard(card)
        return true
    }

    private fun postpone(from: Instant) {
        nextFire = from + (controller.ui.value.config.intervalMinutes * 60).seconds
    }
}
