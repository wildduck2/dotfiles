package com.wildduck.azkar.android

import com.wildduck.azkar.core.Config
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlin.time.Duration.Companion.minutes
import kotlin.time.Duration.Companion.seconds
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant

/** One alarm at a time: when the next reminder is due. */
class RemindersTest {
    private val config = Config(intervalMinutes = 3.0)
    private val now = LocalDateTime(2026, 9, 15, 6, 0).toInstant(TimeZone.UTC)

    @Test
    fun theFirstAlarmIsOneIntervalAway() {
        assertEquals(now + 3.minutes, nextAlarm(now, pending = null, config = config), "three minutes from now")
    }

    @Test
    fun anAlarmThatIsAlreadySetIsLeftAlone() {
        val pending = now + 1.minutes
        assertEquals(pending, nextAlarm(now, pending = pending, config = config), "opening the app doesn't delay it")
    }

    @Test
    fun anAlarmThatHasGoneIsSetAgain() {
        assertEquals(
            now + 3.minutes,
            nextAlarm(now, pending = now - 1.seconds, config = config),
            "a missed alarm (the phone was off) starts the wait again",
        )
    }

    @Test
    fun aShorterIntervalPullsTheNextReminderIn() {
        assertEquals(
            now + 1.minutes,
            nextAlarm(now, pending = now + 5.minutes, config = config.copy(intervalMinutes = 1.0)),
            "changing the interval to one minute shouldn't leave you waiting five",
        )
    }

    @Test
    fun withoutExactAlarmsTheScheduleSaysSo() {
        assertNull(alarmProblem(exact = true), "nothing to say")
        val problem = alarmProblem(exact = false)
        assertTrue(problem != null && "late" in problem, "reminders may be late: $problem")
    }
}
