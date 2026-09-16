package com.wildduck.azkar.app

import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr
import kotlin.test.Test
import kotlin.test.assertEquals

private fun card(text: String, count: Int = 1) = Card(Zikr(text, count), Session.General)

class CardStackTest {
    @Test
    fun tappingACardUntilItCloses() {
        var completed = 0
        val stack = CardStack { completed += 1 }
        val once = stack.push(card("a"))
        stack.push(card("b", 3))
        assertEquals(2, stack.count, "two cards on screen")

        stack.tap(once)
        assertEquals(1, completed, "a card with no count is done in one tap")
        assertEquals(listOf("b"), stack.cards.value.map { it.card.zikr.text }, "and leaves the screen")

        assertEquals("×3", stack.cards.value.first().badge, "a counted card shows its count")
        stack.tapOldest()
        stack.tapOldest()
        assertEquals("2/3", stack.cards.value.first().badge, "the badge counts the taps")
        stack.tapOldest()
        assertEquals(0, stack.count, "the last tap closes the card")
        assertEquals(2, completed, "both cards were finished")
    }

    @Test
    fun dismissingCardsDoesNotFinishThem() {
        var completed = 0
        val stack = CardStack { completed += 1 }
        val first = stack.push(card("a", 3))
        stack.push(card("b"))
        stack.push(card("c"))

        stack.dismiss(first)
        assertEquals(listOf("b", "c"), stack.cards.value.map { it.card.zikr.text }, "the closed card is gone")
        stack.dismissOldest()
        assertEquals(listOf("c"), stack.cards.value.map { it.card.zikr.text }, "the oldest goes first")
        stack.dismissAll()
        assertEquals(0, stack.count, "and everything can go at once")
        assertEquals(0, completed, "closing a card never counts as finishing it")
    }

    @Test
    fun cardsFlowDownFromTheTopRightCorner() {
        val area = CardArea(left = 0, top = 0, right = 1000, bottom = 600)
        assertEquals(
            listOf(CardSpot(544, 16), CardSpot(544, 126)),
            cardPositions(area, width = 440, heights = listOf(100, 120)),
            "16 from the corner, then 10 between the cards",
        )
        assertEquals(
            listOf(CardSpot(544, 16), CardSpot(544, 84)),
            cardPositions(CardArea(0, 0, 1000, 300), width = 440, heights = listOf(200, 200)),
            "when there is no room left they overlap at the bottom",
        )
        assertEquals(
            listOf(CardSpot(1244, 116)),
            cardPositions(CardArea(700, 100, 1700, 700), width = 440, heights = listOf(100)),
            "a display that does not start at the origin",
        )
    }
}
