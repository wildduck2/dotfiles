package com.wildduck.azkar.app

import com.wildduck.azkar.core.Config
import com.wildduck.azkar.core.AppState
import com.wildduck.azkar.core.Plan
import com.wildduck.azkar.core.firstIndex
import com.wildduck.azkar.core.instant
import com.wildduck.azkar.core.lib
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlinx.datetime.TimeZone

/** plan.json: what iOS has already been handed (apple/CoreTests/PlanFileTests.swift has the same cases). */
class PlanFileTest {
    // In the morning window, so the reminders carry their place in that day's list.
    private val plan = Plan.make(
        instant(14, 6, 0),
        TimeZone.UTC,
        Config(),
        lib,
        AppState(),
        limit = 3,
        random = firstIndex,
    )

    @Test
    fun aPlanComesBackAsItWent() {
        assertEquals(3, plan.size, "three reminders to write down")
        assertEquals(1, plan.first().card.position, "the first one is the first zikr of the morning")

        val text = PlanFile.encode(plan)
        assertEquals(plan, PlanFile.decode(text), "a plan comes back as it went")
        assertTrue("\"session\":\"sabah\"" in text, "every list is written by its own name")
        assertTrue("2026-09-14T06:03:00Z" in text, "and every time in UTC, to the second")
    }

    @Test
    fun anythingUnreadableIsSimplyNoPlan() {
        assertEquals(emptyList(), PlanFile.decode(null), "no file yet is no plan")
        assertEquals(emptyList(), PlanFile.decode("not json"), "a broken file is no plan either")
        assertEquals(emptyList(), PlanFile.decode("{}"), "nor is a file with nothing in it")
        assertEquals(
            emptyList(),
            PlanFile.decode(
                """{"reminders":[{"at":"never","session":"sabah","zikr":{"text":"s1","count":1},"state":{}}]}""",
            ),
            "a reminder with a time nobody can read is dropped",
        )
    }
}
