// The reminders ahead, for phones that can't run code every few minutes: iOS schedules them as notifications.
package com.wildduck.azkar.core

import kotlin.random.Random
import kotlin.time.Duration
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.minutes
import kotlin.time.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

/** One scheduled reminder, and the state after its card, which the app keeps once the reminder has fired. */
data class PlannedReminder(val fireAt: Instant, val card: Card, val state: AppState)

object Plan {
    /**
     * One reminder per interval after `now` (the first at `now + interval`), until `limit` reminders or `horizon`.
     * Ticks in quiet hours are skipped. Paused: none. `maxStack` doesn't apply, since nothing stacks up.
     */
    fun make(
        now: Instant,
        timeZone: TimeZone,
        config: Config,
        library: Library,
        state: AppState,
        limit: Int = 64,
        horizon: Duration = 48.hours,
        random: (Int) -> Int = { Random.nextInt(it) },
    ): List<PlannedReminder> {
        if (state.paused || config.intervalMinutes <= 0) return emptyList()
        val interval = config.intervalMinutes.minutes
        val plan = mutableListOf<PlannedReminder>()
        var st = state
        var step = 1
        while (plan.size < limit) {
            val offset = interval * step
            step += 1
            if (offset > horizon) break
            val fireAt = now + offset
            val local = fireAt.toLocalDateTime(timeZone)
            if (config.quietHours?.contains(minuteOfDay(local)) == true) continue
            val pick = Picker.next(local, config, library, st, random)
            st = pick.state
            val card = pick.card ?: continue
            plan += PlannedReminder(fireAt, card, st)
        }
        return plan
    }

    /** The state after the last reminder that has fired by `now`, or `current` if none has. */
    fun commit(plan: List<PlannedReminder>, now: Instant, current: AppState): AppState =
        plan.lastOrNull { it.fireAt <= now }?.state ?: current
}
