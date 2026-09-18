// The app itself: one controller, the plan it hands to iOS, and the card a tapped reminder opens.
package com.wildduck.azkar.ios

import com.wildduck.azkar.app.AzkarController
import com.wildduck.azkar.app.CardStack
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.PlanFile
import com.wildduck.azkar.app.ProblemAction
import com.wildduck.azkar.app.ProblemKey
import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Config
import com.wildduck.azkar.core.Plan
import com.wildduck.azkar.core.PlannedReminder
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.ui.AzkarActions
import com.wildduck.azkar.ui.ControllerActions
import kotlin.time.Clock
import kotlin.time.Instant
import kotlinx.cinterop.ExperimentalForeignApi
import platform.BackgroundTasks.BGAppRefreshTaskRequest
import platform.BackgroundTasks.BGTaskScheduler
import platform.Foundation.NSDate
import platform.Foundation.NSNotificationCenter
import platform.Foundation.NSOperationQueue
import platform.Foundation.NSURL
import platform.Foundation.dateWithTimeIntervalSinceNow
import platform.UIKit.UIApplication
import platform.UIKit.UIApplicationDidBecomeActiveNotification
import platform.UIKit.UIApplicationDidEnterBackgroundNotification
import platform.UIKit.UIApplicationOpenSettingsURLString
import platform.UserNotifications.UNUserNotificationCenter

/** The background slice this app asks for, also named in iosApp/project.yml. */
private const val REFRESH_TASK = "com.wildduck.azkar.kmp.refresh"

/**
 * Nothing here loops — iOS won't run an app every few minutes — so everything ends in [refresh]: take the
 * state from the reminders that have already fired, plan the next ones, and hand them over.
 */
class IosApp(private val storage: IosStorage = IosStorage()) {
    val controller = AzkarController(storage, Features.ios)

    /** The cards tapped reminders have opened. */
    val stack = CardStack()

    val actions: AzkarActions = IosActions(this)

    private var plan: List<PlannedReminder> = emptyList()
    private val delegate = NotificationDelegate { card ->
        stack.push(card)
        refresh()
    }

    /** Called as the app finishes launching: a background task can only be registered before that. */
    fun start() {
        UNUserNotificationCenter.currentNotificationCenter().setDelegate(delegate)
        BGTaskScheduler.sharedScheduler.registerForTaskWithIdentifier(REFRESH_TASK, null) { task ->
            askForBackgroundTime()
            refresh()
            task?.setTaskCompletedWithSuccess(true)
        }
        val notifications = NSNotificationCenter.defaultCenter
        notifications.addObserverForName(UIApplicationDidBecomeActiveNotification, null, NSOperationQueue.mainQueue) {
            refresh()
        }
        notifications.addObserverForName(
            UIApplicationDidEnterBackgroundNotification,
            null,
            NSOperationQueue.mainQueue,
        ) {
            askForBackgroundTime()
        }
        refresh()
    }

    /** Read the files, take the state from the reminders that have fired, and plan the next ones. */
    fun refresh(now: Instant = Clock.System.now()) {
        controller.reload()
        plan = PlanFile.decode(storage.readPlan())
        controller.commit(plan, now)
        replan(now)
    }

    /** The next reminders, written down and handed to iOS. */
    fun replan(now: Instant = Clock.System.now()) {
        plan = controller.plan(now, Reminders.LIMIT)
        storage.writePlan(PlanFile.encode(plan))
        val sound = controller.ui.value.config.sound
        Reminders.authorize { granted ->
            // The answer comes back on iOS's own queue; the window is drawn on the main one.
            NSOperationQueue.mainQueue.addOperationWithBlock {
                controller.setProblem(
                    ProblemKey.Notifications,
                    if (granted) null else "Azkar can't show a reminder until notifications are allowed.",
                    ProblemAction.OpenNotificationSettings,
                )
                if (granted) Reminders.schedule(plan, sound)
            }
        }
        status(now)
    }

    /** The Today page's button: a zikr now, whatever the interval says. */
    fun showNow(now: Instant = Clock.System.now()): Boolean {
        val card = controller.pick(now) ?: return false
        stack.push(card)
        replan(now)
        return true
    }

    /** What the Today page says about the next reminder. */
    fun status(now: Instant = Clock.System.now()) {
        controller.setStatus(now, plan.firstOrNull { it.fireAt > now }?.fireAt, onScreen = stack.count)
    }

    /** The buttons offered next to a problem. */
    fun perform(action: ProblemAction) {
        when (action) {
            ProblemAction.OpenNotificationSettings -> openSettings()
            ProblemAction.TryAgain -> {
                controller.reload(force = true)
                refresh()
            }
            // There is no folder to open, no keyboard to change and no alarm to allow here: say so instead.
            else -> controller.setNotice("Azkar keeps its files inside the app on iPhone.")
        }
    }

    /** Azkar's own page in Settings, where notifications can be switched back on. */
    @OptIn(ExperimentalForeignApi::class)
    private fun openSettings() {
        val url = NSURL(string = UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication.openURL(url, emptyMap<Any?, Any>(), null)
    }

    /** Ask for the next slice. iOS decides when — or whether — it comes. */
    @OptIn(ExperimentalForeignApi::class)
    private fun askForBackgroundTime() {
        val request = BGAppRefreshTaskRequest(REFRESH_TASK)
        request.earliestBeginDate = NSDate.dateWithTimeIntervalSinceNow(3600.0)
        BGTaskScheduler.sharedScheduler.submitTaskRequest(request, null)
    }
}

/** The parts of the window's work only a phone can do. */
private class IosActions(private val app: IosApp) : ControllerActions(app.controller, { Clock.System.now() }) {
    override fun setConfig(config: Config) {
        val before = controller.ui.value.config
        controller.setConfig(config)
        if (Plan.changedBy(before, config)) app.replan()
    }

    override fun setPaused(paused: Boolean) {
        controller.setPaused(paused)
        app.replan()
    }

    override fun restart(session: Session) {
        controller.restart(session, Clock.System.now())
        app.replan()
    }

    override fun showNow() {
        if (!app.showNow()) controller.setNotice("There is nothing to show: azkar.json has no azkar in it.")
    }

    override fun dismissAll() = app.stack.dismissAll()

    override fun perform(action: ProblemAction) = app.perform(action)
}
