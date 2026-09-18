// Android's knock on the door: a reminder is due, Count was pressed, or the phone has just started.
package com.wildduck.azkar.android

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val app = AzkarApp.of(context)
        when (intent.action) {
            ACTION_FIRE -> app.reminder()
            ACTION_COUNT -> intent.reminder()?.let { app.tapped(it) }
            // A reboot or an update clears the alarm, so set it again for the time it was already due.
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> app.arm()
        }
    }
}
