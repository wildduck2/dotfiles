package com.wildduck.azkar.android

import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** What a reminder looks like on a phone, where there is no card on screen to count. */
class NotificationsTest {
    private val card = Card(Zikr("سبحان الله", count = 3, note = "ثلاثًا"), Session.Sabah, position = 7, total = 25)

    @Test
    fun theCardAndTheNotificationCountTheSame() {
        assertEquals(0.0, tapFraction(3, 0), 1e-9, "nothing said yet")
        assertEquals(1.0 / 3, tapFraction(3, 1), 1e-9)
        assertEquals(1.0, tapFraction(3, 3), 1e-9, "and full once it is said")
    }

    @Test
    fun theChannelFollowsTheSoundSetting() {
        assertEquals(CHIME_CHANNEL, channel(sound = true), "a chime with the reminder")
        assertEquals(
            SILENT_CHANNEL,
            channel(sound = false),
            "a channel's sound can't be changed once it exists, so there is one of each",
        )
    }

    @Test
    fun whatTheNotificationSays() {
        assertEquals("أذكار الصباح · 7 من 25", notificationTitle(card), "the list and the place in it")
        assertEquals("سبحان الله\n\nثلاثًا", notificationText(card), "the zikr, with its note under it")
    }

    @Test
    fun onlyAZikrSaidMoreThanOnceNeedsCounting() {
        assertTrue(hasCount(Zikr("x", count = 3)), "×3 gets a Count button")
        assertTrue(!hasCount(Zikr("x")), "a zikr said once is only read")
    }

    @Test
    fun theBadgeAndTheProgressBar() {
        assertEquals("×3", tapBadge(target = 3, done = 0), "before the first tap")
        assertEquals("1/3", tapBadge(target = 3, done = 1), "after it")
        assertEquals("", tapBadge(target = 1, done = 0), "nothing to count")
        assertEquals(0, tapProgress(target = 3, done = 0), "the bar starts empty")
        assertEquals(33, tapProgress(target = 3, done = 1), "a third of the way")
        assertEquals(100, tapProgress(target = 3, done = 3), "full")
        assertNull(tapProgress(target = 1, done = 0), "no bar for a zikr said once")
    }

    @Test
    fun countingFinishesAtTheTarget() {
        assertTrue(!counted(target = 3, done = 2), "two of three")
        assertTrue(counted(target = 3, done = 3), "and the notification goes away")
        assertTrue(counted(target = 1, done = 1), "one tap is the whole of a zikr said once")
    }

    @Test
    fun everyReminderGetsAnIdOfItsOwn() {
        assertEquals(1, nextNotificationId(0), "the first one")
        assertEquals(2, nextNotificationId(1), "then the next")
        assertEquals(1, nextNotificationId(LAST_ID), "and they roll round, long after the first is gone")
    }
}
