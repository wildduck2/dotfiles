// The app itself: one controller, one alarm, and the notifications a reminder is made of.
package com.wildduck.azkar.android

import android.app.Application
import android.content.Context
import com.wildduck.azkar.app.AzkarController
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.Fired
import com.wildduck.azkar.app.ProblemKey
import kotlin.time.Clock
import kotlin.time.Instant

/**
 * Held by the process, whichever woke it — the launcher, the alarm or a Count press. Everything that
 * decides anything is in the shared controller; this does only the parts Android has to do itself.
 */
class AzkarApp : Application() {
    lateinit var controller: AzkarController
        private set
    lateinit var notifier: Notifier
        private set
    lateinit var alarms: Alarms
        private set

    /** Why the last reminder showed nothing, for the Today page. */
    var lastSkip: String? = null
        private set

    override fun onCreate() {
        super.onCreate()
        notifier = Notifier(this).also { it.createChannels() }
        alarms = Alarms(this)
        var report: (String) -> Unit = {}
        controller = AzkarController(AndroidStorage(this, onProblem = { report(it) }), Features.android)
        report = { controller.setProblem(ProblemKey.Config, it) }
    }

    /** One reminder, the way the interval asks for it. */
    fun reminder(now: Instant = Clock.System.now()) {
        controller.reload()
        when (val fired = controller.fire(now, onScreen = notifier.active())) {
            is Fired.Show -> {
                lastSkip = null
                notifier.post(fired.card, sound = controller.ui.value.config.sound)
            }
            is Fired.Skip -> lastSkip = fired.reason
        }
        arm(now, restart = true)
    }

    /** The Today page's button: a zikr now, whatever the interval and the quiet hours say. */
    fun showNow(now: Instant = Clock.System.now()): Boolean {
        val card = controller.pick(now) ?: return false
        lastSkip = null
        notifier.post(card, sound = controller.ui.value.config.sound)
        arm(now, restart = true)
        return true
    }

    /** One repetition: the reminder one press further on, or null once its count is reached. */
    fun tapped(reminder: Reminder): Reminder? {
        val next = reminder.copy(done = reminder.done + 1)
        if (counted(next.card.zikr.count, next.done)) {
            notifier.cancel(next.id)
            return null
        }
        notifier.show(next, sound = controller.ui.value.config.sound)
        return next
    }

    /** Keeps the alarm in step with the settings: none at all while reminders are paused. */
    fun arm(now: Instant = Clock.System.now(), restart: Boolean = false) {
        if (controller.state.paused) alarms.cancel() else alarms.arm(controller.ui.value.config, now, restart)
        status(now)
    }

    /** What the window says about the next reminder. */
    fun status(now: Instant = Clock.System.now()) {
        controller.setStatus(now, alarms.pending, lastSkip, onScreen = notifier.active())
    }

    companion object {
        fun of(context: Context): AzkarApp = context.applicationContext as AzkarApp
    }
}
