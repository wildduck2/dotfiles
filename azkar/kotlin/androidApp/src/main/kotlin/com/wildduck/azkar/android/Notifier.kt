// Posting the reminder: on a phone the notification is the card, Count button and all.
package com.wildduck.azkar.android

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.wildduck.azkar.core.Card

/** Broadcast to [AlarmReceiver] when the Count button is pressed. */
const val ACTION_COUNT = "com.wildduck.azkar.COUNT"

/** Sent to [MainActivity] when a reminder is tapped, so the zikr opens as a card. */
const val ACTION_OPEN = "com.wildduck.azkar.OPEN"

private const val FLAGS = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE

class Notifier(private val context: Context) {
    private val manager = NotificationManagerCompat.from(context)
    private val platform = context.getSystemService(NotificationManager::class.java)
    private val prefs = azkarPrefs(context)

    /** False while Android is holding reminders back, so the Today page can say so. */
    val allowed: Boolean get() = manager.areNotificationsEnabled()

    /** Both channels, once. A channel's sound can't be changed once Android has it, hence two. */
    fun createChannels() {
        manager.createNotificationChannel(newChannel(CHIME_CHANNEL, "Reminders", sound = true))
        manager.createNotificationChannel(newChannel(SILENT_CHANNEL, "Quiet reminders", sound = false))
    }

    /** Posts a reminder under an id of its own, and returns it so it can be counted. */
    fun post(card: Card, sound: Boolean): Reminder {
        val id = nextNotificationId(prefs.getInt(KEY_LAST_ID, 0))
        prefs.edit().putInt(KEY_LAST_ID, id).apply()
        return Reminder(id, card).also { show(it, sound) }
    }

    /** The same notification again, one repetition further on. */
    fun show(reminder: Reminder, sound: Boolean) {
        val zikr = reminder.card.zikr
        val body = notificationText(reminder.card)
        val notification = NotificationCompat.Builder(context, channel(sound))
            .setSmallIcon(R.drawable.ic_azkar)
            .setContentTitle(notificationTitle(reminder.card))
            .setContentText(body.lineSequence().first())
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setSubText(tapBadge(zikr.count, reminder.done).ifEmpty { null })
            .setGroup(GROUP)
            .setAutoCancel(true)
            // A reminder being counted shouldn't chime again with every press.
            .setOnlyAlertOnce(reminder.done > 0)
            .setContentIntent(open(reminder))
            .apply {
                tapProgress(zikr.count, reminder.done)?.let { setProgress(100, it, false) }
                if (hasCount(zikr)) addAction(0, "Count", count(reminder))
            }
            .build()
        try {
            manager.notify(reminder.id, notification)
        } catch (_: SecurityException) {
            // Notifications were switched off between the check and the post; the Today page says so.
        }
    }

    fun cancel(id: Int) = manager.cancel(id)

    fun cancelAll() = manager.cancelAll()

    /** The reminders on screen, so a tick keeps to maxStack the way the desktop counts its cards. */
    fun active(): Int = try {
        platform.activeNotifications.count { it.notification.group == GROUP }
    } catch (_: Exception) {
        // Some phones refuse this to a background process; a reminder more is better than none.
        0
    }

    private fun newChannel(id: String, name: String, sound: Boolean): NotificationChannel {
        val importance = if (sound) NotificationManager.IMPORTANCE_HIGH else NotificationManager.IMPORTANCE_DEFAULT
        return NotificationChannel(id, name, importance).apply {
            description = "A zikr every few minutes."
            if (!sound) {
                setSound(null, null)
                enableVibration(false)
            }
        }
    }

    /** Tapping the reminder opens the same zikr as a card, in the app. */
    private fun open(reminder: Reminder): PendingIntent = PendingIntent.getActivity(
        context,
        reminder.id,
        Intent(context, MainActivity::class.java)
            .setAction(ACTION_OPEN)
            .putReminder(reminder),
        FLAGS,
    )

    /** The Count button: the receiver needs the whole zikr, because the app may not be running. */
    private fun count(reminder: Reminder): PendingIntent = PendingIntent.getBroadcast(
        context,
        reminder.id,
        Intent(context, AlarmReceiver::class.java)
            .setAction(ACTION_COUNT)
            .putReminder(reminder),
        FLAGS,
    )
}
