// The reminders iOS delivers while Azkar isn't running: one notification per planned card.
package com.wildduck.azkar.ios

import com.wildduck.azkar.app.PlanFile
import com.wildduck.azkar.app.cardHeader
import com.wildduck.azkar.app.notificationBody
import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.PlannedReminder
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import platform.Foundation.NSDateComponents
import platform.UserNotifications.UNAuthorizationOptionAlert
import platform.UserNotifications.UNAuthorizationOptionSound
import platform.UserNotifications.UNCalendarNotificationTrigger
import platform.UserNotifications.UNMutableNotificationContent
import platform.UserNotifications.UNNotificationRequest
import platform.UserNotifications.UNNotificationSound
import platform.UserNotifications.UNUserNotificationCenter

/** The key a notification carries its own reminder under, so a tap needs no guesswork. */
private const val KEY = "azkar"

object Reminders {
    /** iOS keeps at most 64 pending notifications per app, which is how long a plan is. */
    const val LIMIT = 64

    private val center get() = UNUserNotificationCenter.currentNotificationCenter()

    /** Asks the first time; after that iOS answers with what was said then. */
    fun authorize(onAnswer: (Boolean) -> Unit) {
        center.requestAuthorizationWithOptions(UNAuthorizationOptionAlert or UNAuthorizationOptionSound) {
            granted, _ ->
            onAnswer(granted)
        }
    }

    /**
     * Replaces everything still pending with this plan. Delivered notifications are left alone: those are the
     * azkar waiting to be opened.
     */
    fun schedule(
        plan: List<PlannedReminder>,
        sound: Boolean,
        timeZone: TimeZone = TimeZone.currentSystemDefault(),
    ) {
        center.removeAllPendingNotificationRequests()
        plan.forEachIndexed { i, reminder ->
            val content = UNMutableNotificationContent().apply {
                setTitle(cardHeader(reminder.card))
                setBody(notificationBody(reminder.card.zikr, last = i == plan.size - 1))
                // One thread per list, so the morning azkar stack together and the evening ones apart.
                setThreadIdentifier(reminder.card.session.name.lowercase())
                if (sound) setSound(UNNotificationSound.defaultSound)
                setUserInfo(mapOf(KEY to PlanFile.encode(listOf(reminder))))
            }
            val at = reminder.fireAt.toLocalDateTime(timeZone)
            val parts = NSDateComponents().apply {
                year = at.year.toLong()
                month = (at.month.ordinal + 1).toLong()
                day = at.day.toLong()
                hour = at.hour.toLong()
                minute = at.minute.toLong()
                second = at.second.toLong()
            }
            center.addNotificationRequest(
                UNNotificationRequest.requestWithIdentifier(
                    identifier = "azkar-$i",
                    content = content,
                    trigger = UNCalendarNotificationTrigger.triggerWithDateMatchingComponents(parts, false),
                ),
                null,
            )
        }
    }

    /** The card a delivered notification was made from. */
    fun card(userInfo: Map<Any?, *>?): Card? {
        val text = userInfo?.get(KEY) as? String ?: return null
        return PlanFile.decode(text).firstOrNull()?.card
    }
}
