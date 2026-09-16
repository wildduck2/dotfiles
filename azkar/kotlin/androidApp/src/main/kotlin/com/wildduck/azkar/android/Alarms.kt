// The one alarm Azkar keeps set: Android wakes the app, the app shows a zikr and sets the next one.
package com.wildduck.azkar.android

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.wildduck.azkar.core.Config
import kotlin.time.Instant

/** Broadcast to [AlarmReceiver] when a reminder is due. */
const val ACTION_FIRE = "com.wildduck.azkar.FIRE"

/**
 * One alarm at a time. A phone can't keep a timer ticking the way a desktop does, so each reminder sets
 * the alarm for the next one — and the alarm that is already set is kept, so opening the app doesn't
 * push the next zikr back.
 */
class Alarms(private val context: Context) {
    private val manager = context.getSystemService(AlarmManager::class.java)
    private val prefs = azkarPrefs(context)

    /** Android 12 and up can refuse exact alarms; without them a reminder drifts by a few minutes. */
    val exact: Boolean
        get() = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || manager.canScheduleExactAlarms()

    /** When the next reminder is due, as far as the alarm got set. */
    val pending: Instant?
        get() = prefs.getLong(KEY_PENDING, 0L).takeIf { it > 0L }?.let { Instant.fromEpochMilliseconds(it) }

    /** Sets the alarm for the next reminder; `restart` counts the interval from now instead. */
    fun arm(config: Config, now: Instant, restart: Boolean = false): Instant {
        val at = nextAlarm(now, if (restart) null else pending, config)
        val millis = at.toEpochMilliseconds()
        val fire = fire()
        if (exact) {
            try {
                manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, fire)
            } catch (_: SecurityException) {
                // Exact alarms were taken away between the check and the call.
                manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, fire)
            }
        } else {
            manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, fire)
        }
        prefs.edit().putLong(KEY_PENDING, millis).apply()
        return at
    }

    fun cancel() {
        manager.cancel(fire())
        prefs.edit().remove(KEY_PENDING).apply()
    }

    private fun fire(): PendingIntent = PendingIntent.getBroadcast(
        context,
        0,
        Intent(context, AlarmReceiver::class.java).setAction(ACTION_FIRE),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
}
