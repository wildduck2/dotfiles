package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

class ClockTest {
    @Test
    fun parsing() {
        assertEquals(330, parseClock("05:30"), "parses HH:mm")
        assertEquals(330, parseClock("5:30"), "parses H:mm")
        assertEquals(0, parseClock("00:00"), "parses midnight")
        assertNull(parseClock("24:00"), "rejects hour 24")
        assertNull(parseClock("12:60"), "rejects minute 60")
        assertNull(parseClock("noon"), "rejects garbage")
        assertEquals(930, minuteOfDay(at(14, 15, 30)), "minute of day")
        assertEquals("2026-09-04", dayKey(at(4, 23, 59)), "day key is yyyy-MM-dd")
    }

    @Test
    fun timeWindows() {
        val morning = TimeWindow(start = 300, end = 660)
        assertTrue(300 in morning, "window includes its start")
        assertTrue(659 in morning, "window includes the minute before its end")
        assertFalse(660 in morning, "window excludes its end")
        assertFalse(299 in morning, "window excludes before start")

        val night = TimeWindow(start = 1410, end = 300) // 23:30 -> 05:00
        assertTrue(1425 in night, "overnight window includes 23:45")
        assertTrue(10 in night, "overnight window includes 00:10")
        assertFalse(300 in night, "overnight window excludes 05:00")
        assertFalse(720 in night, "overnight window excludes noon")
    }

    @Test
    fun formatting() {
        assertEquals("05:30", formatClock(330), "formats minutes as HH:mm")
        assertEquals("00:00", formatClock(0), "formats midnight")
        assertEquals("23:59", formatClock(1439), "formats the last minute")
    }
}
