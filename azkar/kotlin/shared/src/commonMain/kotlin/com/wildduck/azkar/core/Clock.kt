// Clock times (minutes after midnight) and the daily time windows made from them.
package com.wildduck.azkar.core

import kotlinx.datetime.LocalDateTime

/** "HH:mm" (or "H:mm") -> minutes after midnight. */
fun parseClock(s: String): Int? {
    val parts = s.split(":")
    if (parts.size != 2 || parts[1].length != 2) return null
    val h = parts[0].toIntOrNull() ?: return null
    val m = parts[1].toIntOrNull() ?: return null
    if (h !in 0..23 || m !in 0..59) return null
    return h * 60 + m
}

/** Minutes after midnight -> "HH:mm". */
fun formatClock(minutes: Int): String =
    (minutes / 60).toString().padStart(2, '0') + ":" + (minutes % 60).toString().padStart(2, '0')

fun minuteOfDay(time: LocalDateTime): Int = time.hour * 60 + time.minute

/** "yyyy-MM-dd": the day that today's morning/evening progress belongs to. */
fun dayKey(time: LocalDateTime): String = time.date.toString()

/** [start, end) in minutes after midnight; wraps past midnight when end < start. */
data class TimeWindow(val start: Int, val end: Int) {
    operator fun contains(minuteOfDay: Int): Boolean =
        if (start <= end) minuteOfDay >= start && minuteOfDay < end else minuteOfDay >= start || minuteOfDay < end
}
