package com.wildduck.azkar.app

import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr
import kotlin.test.Test
import kotlin.test.assertEquals

class CardTextTest {
    @Test
    fun theHeadingSaysWhereInTodaysListTheZikrIs() {
        val card = Card(Zikr("s7"), Session.Sabah, position = 7, total = 25)
        assertEquals("أذكار الصباح  ·  7 من 25", cardHeader(card), "as the card draws it")
        assertEquals("أذكار الصباح · 7 من 25", cardHeader(card, " · "), "as a notification writes it")
        assertEquals(
            "ذِكْر",
            cardHeader(Card(Zikr("g1"), Session.General)),
            "a general zikr is not part of a list, so it has no place in one",
        )
    }

    @Test
    fun theNoteGoesUnderTheZikr() {
        assertEquals("text", cardBody(Zikr("text")), "just the zikr")
        assertEquals("text\n\nnote", cardBody(Zikr("text", note = "note")), "the note is part of what you read")
        assertEquals("text", cardBody(Zikr("text", note = "  ")), "an empty note is no note")
    }
}
