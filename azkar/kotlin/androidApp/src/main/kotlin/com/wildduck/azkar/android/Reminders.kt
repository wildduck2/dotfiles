// One alarm at a time: when the next reminder is due, and what to say when the phone won't be exact about it.
package com.wildduck.azkar.android

import com.wildduck.azkar.core.Config
import kotlin.time.Duration.Companion.seconds
import kotlin.time.Instant

/**
 * The time to set the alarm for. An alarm that is already set is left alone — opening the app shouldn't
 * push the next reminder back — unless it is further away than the interval now allows, or already gone.
 */
fun nextAlarm(now: Instant, pending: Instant?, config: Config): Instant {
    val due = now + (config.intervalMinutes * 60).seconds
    return if (pending != null && pending > now && pending <= due) pending else due
}

/** What the Schedule page says when Android won't wake the app on the dot. */
fun alarmProblem(exact: Boolean): String? =
    if (exact) null else "Reminders may arrive a few minutes late until exact alarms are allowed."
