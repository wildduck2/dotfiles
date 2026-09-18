package com.wildduck.azkar.android

import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

/** A notification carries its own zikr: the app is usually not running when one is tapped. */
class CardsTest {
    @Test
    fun aCardComesBackAsItWent() {
        val card = Card(
            Zikr("سبحان الله وبحمده", count = 3, note = "ثلاثًا بعد الفجر"),
            Session.Sabah,
            position = 7,
            total = 25,
        )
        assertEquals(card, cardFields(card).card())
    }

    @Test
    fun aGeneralZikrHasNoPlaceInAList() {
        val card = Card(Zikr("لا إله إلا الله"), Session.General)
        val fields = cardFields(card)
        assertEquals(0, fields.position, "nothing an Int extra can carry as null")
        assertEquals(0, fields.total)
        assertEquals(card, fields.card(), "and it comes back with no position at all")
        assertNull(fields.card()?.position)
    }

    @Test
    fun aListThisAzkarDoesNotKnowIsNoCardAtAll() {
        val fields = cardFields(Card(Zikr("الحمد لله"), Session.Masaa)).copy(session = "Ramadan")
        assertNull(fields.card(), "an old notification after an update shouldn't crash the app")
    }
}
