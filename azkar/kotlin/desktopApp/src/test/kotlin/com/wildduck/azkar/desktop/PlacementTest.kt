package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.CardArea
import java.awt.Insets
import java.awt.Rectangle
import kotlin.test.Test
import kotlin.test.assertEquals

/** Where cards may go on a display: the screen, minus whatever the desktop keeps for itself. */
class PlacementTest {
    @Test
    fun theTaskbarAndTheMenuBarAreLeftAlone() {
        assertEquals(
            CardArea(left = 0, top = 28, right = 1920, bottom = 1016),
            cardArea(Rectangle(0, 0, 1920, 1080), Insets(28, 0, 64, 0)),
            "a bar at the top and one at the bottom",
        )
    }

    @Test
    fun aSecondDisplayIsWhereThatDisplayIs() {
        assertEquals(
            CardArea(left = 1920, top = -200, right = 3200, bottom = 784),
            cardArea(Rectangle(1920, -200, 1280, 1024), Insets(0, 0, 40, 0)),
            "a display above and to the right of the first one",
        )
    }

    @Test
    fun aSidebarOnTheRightMovesTheCardsIn() {
        assertEquals(
            CardArea(left = 0, top = 0, right = 1860, bottom = 1080),
            cardArea(Rectangle(0, 0, 1920, 1080), Insets(0, 0, 0, 60)),
            "cards line up against the dock, not under it",
        )
    }
}
