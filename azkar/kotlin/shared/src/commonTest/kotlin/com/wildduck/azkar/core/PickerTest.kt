package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertNull

class PickerTest {
    @Test
    fun morningList() {
        val p = Picks()
        val c1 = p.pick(at(14, 6, 0))
        assertEquals("s1", c1?.zikr?.text, "sabah window starts at the first morning zikr")
        assertEquals(Session.Sabah, c1?.session, "session is sabah")
        assertEquals(1, c1?.position, "sabah position 1")
        assertEquals(3, c1?.total, "sabah total")
        assertEquals("s2", p.pick(at(14, 6, 3))?.zikr?.text, "second morning zikr")
        assertEquals("s3", p.pick(at(14, 6, 6))?.zikr?.text, "third morning zikr")
        val after = p.pick(at(14, 6, 9))
        assertEquals(Session.General, after?.session, "finished sabah falls back to general")
        assertNull(after?.position, "general cards have no position")

        // next day restarts the morning list
        assertEquals("s1", p.pick(at(15, 6, 0))?.zikr?.text, "a new day restarts sabah")
    }

    @Test
    fun eveningList() {
        val p = Picks()
        assertEquals("m1", p.pick(at(14, 16, 0))?.zikr?.text, "masaa window starts at the first evening zikr")
        assertEquals(Session.Masaa, p.pick(at(14, 16, 3))?.session, "session is masaa")
    }

    @Test
    fun sequentialGeneralWrapsAround() {
        val p = Picks()
        val cfg = Config(order = Order.Sequential)
        val texts = (0 until 4).mapNotNull { i -> p.pick(at(14, 13, i), cfg)?.zikr?.text }
        assertEquals(listOf("g1", "g2", "g3", "g1"), texts, "sequential general wraps around")
    }

    @Test
    fun randomNeverRepeats() {
        val p = Picks()
        // A random source that always says 0 must still never show the same zikr twice in a row.
        val texts = (0 until 4).mapNotNull { i -> p.pick(at(14, 13, i))?.zikr?.text }
        for ((a, b) in texts.zipWithNext()) assertNotEquals(a, b, "random never repeats consecutively ($texts)")
    }

    @Test
    fun disabledSabahWindow() {
        val card = Picks().pick(at(14, 6, 0), Config(sabah = null))
        assertEquals(Session.General, card?.session, "disabled sabah window is skipped")
    }

    @Test
    fun generalBetweenWindows() {
        // Between the morning and evening windows, and after them, the general azkar show.
        val p = Picks()
        for ((h, m) in listOf(11 to 0, 13 to 0, 15 to 29, 21 to 0)) {
            val card = p.pick(at(14, h, m))
            assertEquals(Session.General, card?.session, "$h:$m is outside both windows, so a general zikr")
        }
        assertEquals(0, p.state.sabah, "general cards don't use up the morning list")
        assertEquals(0, p.state.masaa, "general cards don't use up the evening list")
        assertEquals(Session.Masaa, p.pick(at(14, 15, 30))?.session, "the evening list starts at 15:30")
    }

    @Test
    fun onlyTimedListsKeepCounts() {
        // General azkar are one tap each; only the morning/evening lists keep their counts.
        val counted = Library(
            sabah = listOf(Zikr("s", 3)),
            masaa = listOf(Zikr("m", 4)),
            general = listOf(Zikr("g", 100)),
        )
        val p = Picks()
        assertEquals(1, p.pick(at(14, 13, 0), library = counted)?.zikr?.count, "a ×100 general zikr is one tap")
        assertEquals(3, p.pick(at(14, 6, 0), library = counted)?.zikr?.count, "morning azkar keep their count")
        assertEquals(
            1,
            p.pick(at(14, 6, 3), library = counted)?.zikr?.count,
            "general after the morning list is one tap",
        )
        assertEquals(4, p.pick(at(14, 16, 0), library = counted)?.zikr?.count, "evening azkar keep their count")
        assertEquals(
            100,
            p.pick(at(14, 13, 3), Config(repeatGeneral = true), counted)?.zikr?.count,
            "repeatGeneral keeps the full count",
        )
    }

    @Test
    fun nothingToShow() {
        assertNull(Picks().pick(at(14, 13, 0), library = Library()), "nothing to show")
    }
}
