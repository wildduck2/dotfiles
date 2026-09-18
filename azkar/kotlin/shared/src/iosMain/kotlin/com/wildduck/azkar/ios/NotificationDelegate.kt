// What happens when a reminder arrives or is tapped.
package com.wildduck.azkar.ios

import com.wildduck.azkar.core.Card
import platform.UserNotifications.UNNotification
import platform.UserNotifications.UNNotificationPresentationOptions
import platform.UserNotifications.UNNotificationResponse
import platform.UserNotifications.UNUserNotificationCenter
import platform.UserNotifications.UNUserNotificationCenterDelegateProtocol
import platform.darwin.NSObject

/** Opens the zikr a notification carries, whether it was tapped or arrived while the app is open. */
class NotificationDelegate(
    private val onOpen: (Card) -> Unit,
) : NSObject(), UNUserNotificationCenterDelegateProtocol {
    override fun userNotificationCenter(
        center: UNUserNotificationCenter,
        didReceiveNotificationResponse: UNNotificationResponse,
        withCompletionHandler: () -> Unit,
    ) {
        Reminders.card(didReceiveNotificationResponse.notification.request.content.userInfo)?.let(onOpen)
        withCompletionHandler()
    }

    /** A reminder that arrives while Azkar is open shows its card instead of a banner over it. */
    override fun userNotificationCenter(
        center: UNUserNotificationCenter,
        willPresentNotification: UNNotification,
        withCompletionHandler: (UNNotificationPresentationOptions) -> Unit,
    ) {
        Reminders.card(willPresentNotification.request.content.userInfo)?.let(onOpen)
        withCompletionHandler(0u)
    }
}
