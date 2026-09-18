// The cards on screen: what they show, and where they go.
package com.wildduck.azkar.app

import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.TapCounter
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/** One card as it is drawn: its zikr, how far its count has got, and the id its window is tracked by. */
data class CardOnScreen(val id: Long, val card: Card, val badge: String, val fraction: Double)

/** The part of a display cards may use, without the menu bar or taskbar. */
data class CardArea(val left: Int, val top: Int, val right: Int, val bottom: Int)

data class CardSpot(val x: Int, val y: Int)

private const val MARGIN = 16
private const val GAP = 10

/** Cards flow down from the top-right corner; if they run out of room they overlap at the bottom. */
fun cardPositions(area: CardArea, width: Int, heights: List<Int>): List<CardSpot> {
    val x = area.right - MARGIN - width
    var next = area.top + MARGIN
    return heights.map { height ->
        val y = minOf(next, area.bottom - MARGIN - height)
        next = y + height + GAP
        CardSpot(x, y)
    }
}

/** The cards waiting on screen, oldest first. `onComplete` runs when a card's count is reached (not on close). */
class CardStack(private val onComplete: (Card) -> Unit = {}) {
    private class Shown(val id: Long, val card: Card) {
        val counter = TapCounter(card.zikr.count)
    }

    private val shown = mutableListOf<Shown>()
    private var nextId = 1L

    private val _cards = MutableStateFlow<List<CardOnScreen>>(emptyList())
    val cards: StateFlow<List<CardOnScreen>> = _cards.asStateFlow()

    val count: Int get() = shown.size

    /** Adds a card and returns the id to tap or dismiss it by. */
    fun push(card: Card): Long {
        val fresh = Shown(nextId++, card)
        shown += fresh
        publish()
        return fresh.id
    }

    /** One repetition; the card leaves the screen once its count is reached. */
    fun tap(id: Long) {
        val card = shown.firstOrNull { it.id == id } ?: return
        if (!card.counter.tap()) {
            publish()
            return
        }
        shown -= card
        publish()
        onComplete(card.card)
    }

    /** The shortcut counts the card that has been waiting longest. */
    fun tapOldest() {
        shown.firstOrNull()?.let { tap(it.id) }
    }

    /** Closes a card, whatever is left of its count. */
    fun dismiss(id: Long) {
        if (shown.removeAll { it.id == id }) publish()
    }

    fun dismissOldest() {
        shown.firstOrNull()?.let { dismiss(it.id) }
    }

    fun dismissAll() {
        if (shown.isEmpty()) return
        shown.clear()
        publish()
    }

    private fun publish() {
        _cards.value = shown.map { CardOnScreen(it.id, it.card, it.counter.badge, it.counter.fraction) }
    }
}
