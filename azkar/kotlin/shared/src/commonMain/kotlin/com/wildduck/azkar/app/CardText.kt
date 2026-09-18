// The words on a card, wherever the card shows up: a window on a desktop, a notification on a phone.
package com.wildduck.azkar.app

import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr

/** The heading of a card, in Arabic. */
val Session.title: String
    get() = when (this) {
        Session.Sabah -> "أذكار الصباح"
        Session.Masaa -> "أذكار المساء"
        Session.General -> "ذِكْر"
    }

/** "أذكار الصباح · 7 من 25": which list this zikr came from, and where in it. A general zikr has no place. */
fun cardHeader(card: Card, separator: String = "  ·  "): String {
    val position = card.position
    val total = card.total
    return if (position != null && total != null) {
        card.session.title + separator + "$position من $total"
    } else {
        card.session.title
    }
}

/** The zikr as one piece of text: what to say, with its note under it. */
fun cardBody(zikr: Zikr): String =
    listOfNotNull(zikr.text, zikr.note?.takeIf { it.isNotBlank() }).joinToString("\n\n")

/** What counts a zikr where there is no global shortcut: the Count button on the reminder. */
const val COUNT_BUTTON = "زر العدّ"

/** What the last reminder of a plan says, since nothing is scheduled after it. */
const val KEEP_GOING = "Open Azkar to keep reminders coming"

/** A notification's body. The last one of a plan also says how to keep them coming. */
fun notificationBody(zikr: Zikr, last: Boolean = false): String =
    if (last) cardBody(zikr) + "\n\n" + KEEP_GOING else cardBody(zikr)
