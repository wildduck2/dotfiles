package com.wildduck.azkar.app

import com.wildduck.azkar.core.AppState
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** state.json, in the shape the macOS app writes it. */
class StateFileTest {
    @Test
    fun readsWhatTheMacAppWrites() {
        val text = """{"paused":false,"day":"2026-09-15","masaa":23,"general":0,"lastGeneral":13,"sabah":11}"""
        val s = StateFile.decode(text)
        assertEquals("2026-09-15", s.day, "the day the progress belongs to")
        assertEquals(11, s.sabah, "morning progress")
        assertEquals(23, s.masaa, "evening progress")
        assertEquals(13, s.lastGeneral, "the general zikr shown last")
        assertEquals(false, s.paused, "not paused")
    }

    @Test
    fun anythingUnreadableStartsFresh() {
        assertEquals(AppState(), StateFile.decode(null), "no state file yet")
        assertEquals(AppState(), StateFile.decode("not json"), "an unreadable state file starts from a fresh state")
        assertEquals(AppState(), StateFile.decode("""{"sabah": null}"""), "a null count is no progress")
        assertEquals(AppState(paused = true), StateFile.decode("""{"paused": true}"""), "only the pause flag")
    }

    @Test
    fun roundTrip() {
        val s = AppState(day = "2026-09-16", sabah = 2, masaa = 3, general = 4, lastGeneral = 1, paused = true)
        assertEquals(s, StateFile.decode(StateFile.encode(s)), "state round-trips")
        assertTrue(
            "lastGeneral" !in StateFile.encode(AppState()),
            "a state with no last general leaves the key out, as Swift does",
        )
    }
}
