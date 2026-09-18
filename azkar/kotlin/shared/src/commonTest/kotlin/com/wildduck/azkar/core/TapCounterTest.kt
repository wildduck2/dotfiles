package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** Each click or shortcut press counts once; the card closes when the count is reached. */
class TapCounterTest {
    @Test
    fun counting() {
        val one = TapCounter(target = 1)
        assertEquals("", one.badge, "×1 cards show no badge")
        assertTrue(one.tap(), "a single tap completes a ×1 zikr")

        val three = TapCounter(target = 3)
        assertEquals("×3", three.badge, "untouched badge shows the target")
        assertFalse(three.tap(), "first of three taps does not complete")
        assertEquals("1/3", three.badge, "badge counts taps")
        assertFalse(three.tap(), "second of three taps does not complete")
        assertEquals("2/3", three.badge, "badge counts taps again")
        assertTrue(three.tap(), "third tap completes")
        assertTrue(three.isComplete, "complete after reaching the target")
        three.tap()
        assertEquals(3, three.done, "extra taps do not overshoot")

        val four = TapCounter(target = 4)
        four.tap()
        assertEquals(0.25, four.fraction, "fraction done")

        assertTrue(TapCounter(target = 0).tap(), "a target below 1 behaves like 1")
    }
}
