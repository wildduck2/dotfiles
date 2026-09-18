// A reminder as its notification carries it: the app is usually not running when one is tapped.
package com.wildduck.azkar.android

import android.content.Intent
import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr

/** A posted reminder: the notification it is, the zikr it shows, and how many times that has been said. */
data class Reminder(val id: Int, val card: Card, val done: Int = 0)

/** A card flattened into the plain values an Intent can carry. */
data class CardFields(
    val session: String,
    val text: String,
    val note: String?,
    val count: Int,
    /** 0 stands for "not in one of today's lists": an extra can't be an Int and absent at once. */
    val position: Int,
    val total: Int,
)

fun cardFields(card: Card): CardFields = CardFields(
    session = card.session.name,
    text = card.zikr.text,
    note = card.zikr.note,
    count = card.zikr.count,
    position = card.position ?: 0,
    total = card.total ?: 0,
)

/** The card again, or null when the notification is older than the lists this Azkar knows. */
fun CardFields.card(): Card? {
    val list = Session.entries.firstOrNull { it.name == session } ?: return null
    return Card(
        Zikr(text = text, count = count, note = note),
        list,
        position = position.takeIf { it > 0 },
        total = total.takeIf { it > 0 },
    )
}

private const val EXTRA_ID = "com.wildduck.azkar.id"
private const val EXTRA_DONE = "com.wildduck.azkar.done"
private const val EXTRA_SESSION = "com.wildduck.azkar.session"
private const val EXTRA_TEXT = "com.wildduck.azkar.text"
private const val EXTRA_NOTE = "com.wildduck.azkar.note"
private const val EXTRA_COUNT = "com.wildduck.azkar.count"
private const val EXTRA_POSITION = "com.wildduck.azkar.position"
private const val EXTRA_TOTAL = "com.wildduck.azkar.total"

fun Intent.putReminder(reminder: Reminder): Intent = apply {
    val fields = cardFields(reminder.card)
    putExtra(EXTRA_ID, reminder.id)
    putExtra(EXTRA_DONE, reminder.done)
    putExtra(EXTRA_SESSION, fields.session)
    putExtra(EXTRA_TEXT, fields.text)
    putExtra(EXTRA_NOTE, fields.note)
    putExtra(EXTRA_COUNT, fields.count)
    putExtra(EXTRA_POSITION, fields.position)
    putExtra(EXTRA_TOTAL, fields.total)
}

/** The reminder this Intent carries, or null when it carries none (the launcher's own, say). */
fun Intent.reminder(): Reminder? {
    val id = getIntExtra(EXTRA_ID, 0).takeIf { it > 0 } ?: return null
    val card = CardFields(
        session = getStringExtra(EXTRA_SESSION) ?: return null,
        text = getStringExtra(EXTRA_TEXT) ?: return null,
        note = getStringExtra(EXTRA_NOTE),
        count = getIntExtra(EXTRA_COUNT, 1),
        position = getIntExtra(EXTRA_POSITION, 0),
        total = getIntExtra(EXTRA_TOTAL, 0),
    ).card() ?: return null
    return Reminder(id, card, done = getIntExtra(EXTRA_DONE, 0))
}
