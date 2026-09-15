package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.time.Instant
import kotlinx.datetime.TimeZone

/** The reminders an iPhone schedules ahead as notifications (apple/CoreTests/PlanTests.swift has the same cases). */
class PlanTest {
    private fun plan(
        now: Instant,
        config: Config = Config(),
        library: Library = lib,
        state: AppState = AppState(),
        limit: Int = 64,
    ): List<PlannedReminder> = Plan.make(now, TimeZone.UTC, config, library, state, limit, random = firstIndex)

    @Test
    fun spacing() {
        val p = plan(instant(14, 12, 0))
        assertEquals(instant(14, 12, 3), p.first().fireAt, "the first reminder is one interval after now")
        assertEquals(instant(14, 12, 6), p[1].fireAt, "reminders are one interval apart")
        assertEquals(64, p.size, "up to 64 reminders")
    }

    @Test
    fun limits() {
        assertEquals(64, plan(instant(14, 12, 0), Config(maxStack = 1)).size, "maxStack does not limit the plan")
        assertEquals(5, plan(instant(14, 12, 0), limit = 5).size, "stops at the limit")
        val hourly = plan(instant(14, 12, 0), Config(intervalMinutes = 60.0, quietHours = null))
        assertEquals(48, hourly.size, "stops at the horizon")
        assertEquals(instant(16, 12, 0), hourly.last().fireAt, "a reminder exactly at the horizon is included")
    }

    @Test
    fun quietHours() {
        val p = plan(instant(14, 23, 0), Config(intervalMinutes = 30.0))
        assertEquals(instant(15, 5, 0), p.first().fireAt, "quiet hours are skipped")
    }

    @Test
    fun stateThroughThePlan() {
        val p = plan(instant(14, 5, 57))
        assertEquals(
            listOf("s1", "s2", "s3", "g1"),
            p.take(4).map { it.card.zikr.text },
            "the morning list continues through the plan",
        )
        assertEquals(1, p[0].state.sabah, "each reminder carries the state after its card")
        assertEquals(3, p[2].state.sabah, "the state after the third card")
        val resumed = plan(instant(14, 6, 0), state = AppState(day = "2026-09-14", sabah = 2))
        assertEquals("s3", resumed.first().card.zikr.text, "the plan starts from the given state")

        val hourly = plan(instant(14, 9, 30), Config(intervalMinutes = 60.0, quietHours = null))
        assertEquals(
            "s1",
            hourly.firstOrNull { it.fireAt == instant(15, 5, 30) }?.card?.zikr?.text,
            "a new day restarts the morning list inside the plan",
        )
    }

    @Test
    fun emptyPlans() {
        assertEquals(0, plan(instant(14, 12, 0), state = AppState(paused = true)).size, "a paused state plans nothing")
        assertEquals(0, plan(instant(14, 12, 0), library = Library()).size, "nothing to show plans nothing")
        assertEquals(0, plan(instant(14, 12, 0), Config(intervalMinutes = 0.0)).size, "a zero interval plans nothing")
    }

    @Test
    fun commit() {
        val start = AppState(day = "2026-09-14")
        val p = plan(instant(14, 6, 0), state = start) // 06:03 s1, 06:06 s2, 06:09 s3, …
        assertEquals(
            start,
            Plan.commit(p, instant(14, 6, 2), start),
            "before any reminder fires, the state stays as it is",
        )
        assertEquals(
            p[1].state,
            Plan.commit(p, instant(14, 6, 7), start),
            "commit keeps the state after the last reminder that fired",
        )
        assertEquals(p[2].state, Plan.commit(p, instant(14, 6, 9), start), "a reminder firing exactly now counts as fired")
        assertEquals(
            p.last().state,
            Plan.commit(p, instant(20, 0, 0), start),
            "after the whole plan, the last reminder's state",
        )
        assertEquals(start, Plan.commit(emptyList(), instant(14, 6, 7), start), "an empty plan keeps the current state")
    }
}
