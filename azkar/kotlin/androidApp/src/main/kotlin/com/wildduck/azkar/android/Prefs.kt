// The two things only a phone remembers, kept out of state.json: that file is shared with the other apps.
package com.wildduck.azkar.android

import android.content.Context
import android.content.SharedPreferences

const val KEY_PENDING = "pendingAlarm"
const val KEY_LAST_ID = "lastNotificationId"

fun azkarPrefs(context: Context): SharedPreferences =
    context.getSharedPreferences("azkar", Context.MODE_PRIVATE)
