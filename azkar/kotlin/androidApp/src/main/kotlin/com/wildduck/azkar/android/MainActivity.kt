// The window: the same pages as the desktop, plus the card a tapped reminder opens over them.
package com.wildduck.azkar.android

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.wildduck.azkar.app.COUNT_BUTTON
import com.wildduck.azkar.app.CardOnScreen
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.ProblemAction
import com.wildduck.azkar.app.ProblemKey
import com.wildduck.azkar.core.Config
import com.wildduck.azkar.ui.AzkarTheme
import com.wildduck.azkar.ui.AzkarWindow
import com.wildduck.azkar.ui.CardView
import com.wildduck.azkar.ui.ControllerActions
import com.wildduck.azkar.ui.cardWidth
import kotlin.time.Clock
import kotlin.time.Duration.Companion.seconds
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow

class MainActivity : ComponentActivity() {
    private val app: AzkarApp get() = AzkarApp.of(this)

    /** The reminder a notification was tapped for, shown as a card over the window. */
    private val opened = MutableStateFlow<Reminder?>(null)

    private var askedOnce = false
    private lateinit var askNotifications: ActivityResultLauncher<String>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Android 15 draws every app behind the status and navigation bars whether it asks to or not.
        enableEdgeToEdge()
        askNotifications = registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            notificationProblem(granted)
        }
        opened.value = intent.reminder()
        val actions = AndroidActions(app) { perform(it) }

        setContent {
            val ui by app.controller.ui.collectAsState()
            val reminder by opened.collectAsState()
            AzkarTheme {
                // The Today page counts down to the next reminder, so it has to tick.
                LaunchedEffect(Unit) {
                    while (true) {
                        app.status()
                        delay(1.seconds)
                    }
                }
                LaunchedEffect(ui.notice) {
                    if (ui.notice == null) return@LaunchedEffect
                    delay(4.seconds)
                    app.controller.setNotice(null)
                }
                BackHandler(enabled = reminder != null) { opened.value = null }

                Box(Modifier.fillMaxSize()) {
                    AzkarWindow(ui, Features.android, actions, Modifier.safeDrawingPadding())
                    reminder?.let { open ->
                        ReminderCard(
                            reminder = open,
                            fontSize = ui.config.fontSize,
                            onTap = { opened.value = app.tapped(open) },
                            onClose = {
                                app.notifier.cancel(open.id)
                                opened.value = null
                            },
                        )
                    }
                }
            }
        }
    }

    /** A reminder tapped while the app is already open (it runs as a single task). */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.reminder()?.let { opened.value = it }
    }

    override fun onResume() {
        super.onResume()
        app.controller.reload()
        app.arm()
        checkPermissions()
    }

    /** Whatever the phone has to be asked for before a reminder can arrive. */
    private fun checkPermissions() {
        val granted = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        if (!granted && !askedOnce) {
            // Android itself stops asking after the second refusal, and then says no straight away.
            askedOnce = true
            askNotifications.launch(Manifest.permission.POST_NOTIFICATIONS)
            return
        }
        notificationProblem(granted && app.notifier.allowed)
        app.controller.setProblem(
            ProblemKey.Alarms,
            alarmProblem(app.alarms.exact),
            ProblemAction.OpenAlarmSettings,
        )
    }

    private fun notificationProblem(allowed: Boolean) = app.controller.setProblem(
        ProblemKey.Notifications,
        if (allowed) null else "Azkar can't show a reminder until notifications are allowed.",
        ProblemAction.OpenNotificationSettings,
    )

    private fun perform(action: ProblemAction) {
        when (action) {
            ProblemAction.OpenNotificationSettings -> settings(
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, packageName),
            )
            ProblemAction.OpenAlarmSettings ->
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    settings(
                        Intent(
                            Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                            Uri.parse("package:$packageName"),
                        ),
                    )
                }
            // There is no folder to open and no keyboard to change here: say so instead.
            ProblemAction.ShowConfigFolder, ProblemAction.OpenShortcutSettings ->
                app.controller.setNotice("Azkar keeps its files inside the app on Android.")
            ProblemAction.TryAgain -> {
                app.controller.reload(force = true)
                app.arm()
                checkPermissions()
            }
        }
    }

    /** The app's own page in Settings, if the exact one isn't there on this phone. */
    private fun settings(intent: Intent) {
        runCatching { startActivity(intent) }.recoverCatching {
            startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")),
            )
        }
    }
}

/** A tapped reminder, as the card it would have been on a desktop. */
@Composable
private fun ReminderCard(reminder: Reminder, fontSize: Double, onTap: () -> Unit, onClose: () -> Unit) {
    val count = reminder.card.zikr.count
    Box(
        Modifier
            .fillMaxSize()
            .background(Color(0xCC000000))
            .clickable(onClick = onClose)
            .safeDrawingPadding()
            .padding(16.dp),
        contentAlignment = Alignment.Center,
    ) {
        CardView(
            card = CardOnScreen(
                id = reminder.id.toLong(),
                card = reminder.card,
                badge = tapBadge(count, reminder.done),
                fraction = tapFraction(count, reminder.done),
            ),
            fontSize = fontSize,
            hint = COUNT_BUTTON,
            onTap = onTap,
            onClose = onClose,
            modifier = Modifier.widthIn(max = cardWidth),
        )
    }
}

/** The parts of the window's work only a phone can do. */
private class AndroidActions(
    private val app: AzkarApp,
    private val settings: (ProblemAction) -> Unit,
) : ControllerActions(app.controller, { Clock.System.now() }) {
    override fun setConfig(config: Config) {
        controller.setConfig(config)
        // A new interval starts now, so a change can be felt straight away.
        app.arm(restart = true)
    }

    override fun setPaused(paused: Boolean) {
        controller.setPaused(paused)
        app.arm(restart = true)
    }

    override fun showNow() {
        if (!app.showNow()) controller.setNotice("There is nothing to show: azkar.json has no azkar in it.")
    }

    override fun dismissAll() = app.notifier.cancelAll()

    override fun perform(action: ProblemAction) = settings(action)
}
