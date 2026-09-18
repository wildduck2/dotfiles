package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.UiState
import kotlin.test.Test
import kotlin.test.assertEquals

/** The lines of the tray menu, which is all most days of Azkar ever show. */
class TrayTest {
    @Test
    fun theStatusLineCountsInMinutes() {
        assertEquals(
            "Next zikr in 2 min",
            statusLine(UiState(nextIn = 150)),
            "minutes, not seconds: the desktop rebuilds the menu whenever this line changes",
        )
        assertEquals("Next zikr in under a minute", statusLine(UiState(nextIn = 42)), "nearly there")
        assertEquals(
            "Next zikr in 2 min  ·  last skipped: stack full",
            statusLine(UiState(nextIn = 150, lastSkip = "stack full")),
            "why the last reminder showed nothing",
        )
        assertEquals("Paused", statusLine(UiState(paused = true, lastSkip = "paused")), "paused says only that")
        assertEquals("Reminders are on", statusLine(UiState()), "before the first reminder is due")
    }

    @Test
    fun theProgressLine() {
        assertEquals(
            "Morning 3/12  ·  Evening 0/8",
            progressLine(UiState(sabahDone = 3, sabahTotal = 12, masaaTotal = 8)),
            "today's progress through both lists",
        )
    }

    @Test
    fun theTooltipSaysWhatIsWaiting() {
        assertEquals("Azkar  ·  Next zikr in 1 min", tooltip(UiState(nextIn = 90), cards = 0), "nothing waiting")
        assertEquals(
            "Azkar  ·  Next zikr in 1 min  ·  1 card waiting",
            tooltip(UiState(nextIn = 90), cards = 1),
            "one card",
        )
        assertEquals(
            "Azkar  ·  Paused  ·  3 cards waiting",
            tooltip(UiState(paused = true), cards = 3),
            "paused, with cards still on screen",
        )
    }
}
