// The heartbeat: a card every few minutes, the files watched, and the status line kept fresh.
package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.AzkarController
import com.wildduck.azkar.app.CardStack
import com.wildduck.azkar.app.Fired
import com.wildduck.azkar.core.Card
import kotlin.time.Clock
import kotlin.time.Duration.Companion.seconds
import kotlin.time.Instant

/** The first card comes right after launch, so a fresh install shows what Azkar does. */
private val FIRST = 5.seconds

/**
 * Ticked once a second by the app. What to show is decided by [AzkarController.fire], the same call the
 * phone's alarm makes; the loop only keeps the clock. `locked` keeps cards off a locked screen, and
 * `onCard` is where the chime goes.
 */
class Loop(
    private val controller: AzkarController,
    private val stack: CardStack,
    private val now: () -> Instant = { Clock.System.now() },
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
        // Asked for by hand, so nothing stands in its way: not the quiet hours, not a full screen.
        val card = controller.pick(at)
        card?.let { push(it) }
        postpone(at)
        controller.setStatus(now = at, nextFire = nextFire, lastSkip = lastSkip, onScreen = stack.count)
        return card != null
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
        when (val fired = controller.fire(now = at, onScreen = stack.count, locked = locked())) {
            is Fired.Show -> {
                lastSkip = null
                push(fired.card)
            }
            is Fired.Skip -> lastSkip = fired.reason
        }
    }

    private fun push(card: Card) {
        stack.push(card)
        onCard(card)
    }

    private fun postpone(from: Instant) {
        nextFire = from + (controller.ui.value.config.intervalMinutes * 60).seconds
    }
}
