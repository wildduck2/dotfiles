// What a reminder looks like on a phone: there is no card on screen here, so the notification is the card.
package com.wildduck.azkar.android

import com.wildduck.azkar.app.cardBody
import com.wildduck.azkar.app.cardHeader
import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.TapCounter
import com.wildduck.azkar.core.Zikr
import kotlin.math.roundToInt

/**
 * Two channels, because a channel's sound can't be changed after it is created: the reminder goes to the
 * chiming one or the silent one, depending on the `sound` setting.
 */
const val CHIME_CHANNEL = "azkar.chime"
const val SILENT_CHANNEL = "azkar.silent"

/** Android bundles the reminders together under this group. */
const val GROUP = "com.wildduck.azkar.reminders"

/** Notification ids roll round, so a new reminder never lands on one that is still on screen. */
const val LAST_ID = 9999

fun channel(sound: Boolean): String = if (sound) CHIME_CHANNEL else SILENT_CHANNEL

fun nextNotificationId(previous: Int): Int = if (previous in 1 until LAST_ID) previous + 1 else 1

/** "أذكار الصباح · 7 من 25" — one line, because a notification title is one line. */
fun notificationTitle(card: Card): String = cardHeader(card, " · ")

fun notificationText(card: Card): String = cardBody(card.zikr)

/** A zikr said more than once gets a Count button; one said once is only read and swiped away. */
fun hasCount(zikr: Zikr): Boolean = zikr.count > 1

/** The same badge the cards show: "×3" before the first tap, then "1/3". */
fun tapBadge(target: Int, done: Int): String = counter(target, done).badge

/** How full the notification's progress bar is, or null for a zikr said once. */
fun tapProgress(target: Int, done: Int): Int? =
    if (target <= 1) null else (counter(target, done).fraction * 100).roundToInt()

/** Whether that many taps finish the zikr, so the notification can go away. */
fun counted(target: Int, done: Int): Boolean = counter(target, done).isComplete

// The counting rules live in the core, in one place, so a phone counts exactly as a card does.
private fun counter(target: Int, done: Int): TapCounter = TapCounter(target).also { counter ->
    repeat(done) { counter.tap() }
}

/** How far the count has got, for the card a tapped reminder opens. */
fun tapFraction(target: Int, done: Int): Double = counter(target, done).fraction
