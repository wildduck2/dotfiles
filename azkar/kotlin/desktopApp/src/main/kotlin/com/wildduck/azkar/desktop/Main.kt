// The Windows and Linux app. (On macOS this is only for development; the Mac app is apple/.)
package com.wildduck.azkar.desktop

import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.WindowPosition
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import com.wildduck.azkar.app.AzkarController
import com.wildduck.azkar.app.CardStack
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.ProblemAction
import com.wildduck.azkar.app.ProblemKey
import com.wildduck.azkar.app.ShortcutInfo
import com.wildduck.azkar.app.ShortcutMode
import com.wildduck.azkar.core.opensWindowAtLaunch
import com.wildduck.azkar.ui.AzkarTheme
import com.wildduck.azkar.ui.AzkarWindow
import com.wildduck.azkar.ui.ControllerActions
import javax.swing.SwingUtilities
import kotlin.time.Clock
import kotlin.time.Duration.Companion.seconds
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.withContext

fun main(args: Array<String>) {
    val paths = DesktopPaths.current()
    val instance = SingleInstance.claim(paths.stateDir)
    if (instance == null) {
        // Azkar is already running: it has been asked to open its window, and we step aside.
        println("Azkar is already running.")
        return
    }

    // The storage is built before the controller that reports its problems, so it calls back through this.
    var report: (String) -> Unit = {}
    val storage = FileStorage(paths, onProblem = { report(it) }, bundledAzkar = { Bundled.azkar() })
    val features = if (paths.os == Os.Windows) Features.windows else Features.linux
    val controller = AzkarController(storage, features)
    report = { controller.setProblem(ProblemKey.Config, it, ProblemAction.ShowConfigFolder) }

    val sound: () -> Boolean = { controller.ui.value.config.sound }
    val stack = CardStack(onComplete = { if (sound()) Chime.done() })
    val loop = Loop(controller, stack, onCard = { if (sound()) Chime.card() })

    // Another launch of Azkar (from the menu, or clicking the app again) asks this one for its window.
    val openRequest = MutableStateFlow(false)
    instance.onOpenRequest { openRequest.value = true }

    var mode: ShortcutMode = ShortcutMode.App
    val shortcuts = shortcutsFor(
        pickBackend(paths.os, System.getenv("XDG_SESSION_TYPE"), portalAvailable()),
        ShortcutEvents(
            // The shortcut arrives on a thread of its own; the cards belong to the UI thread.
            onPress = { SwingUtilities.invokeLater { stack.tapOldest() } },
            onInfo = { controller.setShortcut(it) },
            onProblem = { controller.setProblem(ProblemKey.Shortcut, it, it?.let { shortcutFix(mode) }) },
        ),
    )
    mode = shortcuts.mode
    if (mode == ShortcutMode.None) controller.setShortcut(ShortcutInfo("", ShortcutMode.None))

    val autostart = autostartFor(paths, launcherCommand())
    val windowAtLaunch = opensWindowAtLaunch(args.toList(), controller.ui.value.config)

    try {
        application {
            val ui by controller.ui.collectAsState()
            val cards by stack.cards.collectAsState()
            var windowOpen by remember { mutableStateOf(windowAtLaunch) }
            var attempt by remember { mutableStateOf(0) }
            val mainWindow = rememberWindowState(
                size = DpSize(860.dp, 660.dp),
                position = WindowPosition(Alignment.Center),
            )

            // The heartbeat: one tick a second, for as long as Azkar runs.
            LaunchedEffect(Unit) {
                while (true) {
                    delay(1.seconds)
                    loop.tick()
                }
            }
            LaunchedEffect(Unit) {
                openRequest.collect {
                    if (!it) return@collect
                    openRequest.value = false
                    windowOpen = true
                }
            }
            // Taking the shortcut can wait on the desktop (the portal asks the user), so never on the UI thread.
            LaunchedEffect(ui.config.hotkey, attempt) {
                if (mode == ShortcutMode.App) {
                    controller.setShortcut(ShortcutInfo(ui.config.hotkey.display(features.keyStyle), mode))
                }
                val problem = withContext(Dispatchers.IO) { shortcuts.bind(ui.config.hotkey) }
                controller.setProblem(ProblemKey.Shortcut, problem, problem?.let { shortcutFix(mode) })
            }
            LaunchedEffect(ui.config.openAtLogin) {
                if (!autostart.supported) return@LaunchedEffect
                val problem = withContext(Dispatchers.IO) { autostart.set(ui.config.openAtLogin) }
                controller.setProblem(ProblemKey.Login, problem, problem?.let { ProblemAction.ShowConfigFolder })
            }
            // A .deb puts Azkar in the menu; a folder you unzipped yourself doesn't, so write an entry for it.
            LaunchedEffect(Unit) {
                withContext(Dispatchers.IO) {
                    if (!installedSystemWide(launcherCommand())) autostart.installMenuEntry()
                }
            }
            // "Saved", "Nothing to show": long enough to read, then gone.
            LaunchedEffect(ui.notice) {
                if (ui.notice == null) return@LaunchedEffect
                delay(4.seconds)
                controller.setNotice(null)
            }

            val actions = remember {
                DesktopActions(
                    controller = controller,
                    now = { Clock.System.now() },
                    loop = loop,
                    stack = stack,
                    paths = paths,
                    open = { windowOpen = true },
                    retry = { attempt += 1 },
                    exit = { exitApplication() },
                )
            }

            AzkarTray(
                ui = ui,
                cards = cards.size,
                actions = remember {
                    TrayActions(
                        count = { stack.tapOldest() },
                        dismissOldest = { stack.dismissOldest() },
                        dismissAll = { stack.dismissAll() },
                        showNow = { actions.showNow() },
                        togglePause = { loop.setPaused(!controller.state.paused) },
                        open = { windowOpen = true },
                        quit = { exitApplication() },
                    )
                },
            )

            if (windowOpen) {
                Window(
                    onCloseRequest = { windowOpen = false },
                    state = mainWindow,
                    title = "Azkar",
                ) {
                    AzkarTheme { AzkarWindow(ui, features, actions) }
                }
            }

            CardWindows(
                cards = cards,
                fontSize = ui.config.fontSize,
                hint = ui.shortcut.display,
                onTap = { stack.tap(it) },
                onClose = { stack.dismiss(it) },
            )
        }
    } finally {
        shortcuts.close()
        instance.close()
    }
}

/** What to offer next to a shortcut that didn't work: the desktop's settings, or simply trying again. */
private fun shortcutFix(mode: ShortcutMode): ProblemAction =
    if (mode is ShortcutMode.SystemSettings) ProblemAction.OpenShortcutSettings else ProblemAction.TryAgain

/** The parts of the window's work only this desktop can do. */
private class DesktopActions(
    controller: AzkarController,
    now: () -> kotlin.time.Instant,
    private val loop: Loop,
    private val stack: CardStack,
    private val paths: DesktopPaths,
    private val open: () -> Unit,
    private val retry: () -> Unit,
    private val exit: () -> Unit,
) : ControllerActions(controller, now) {
    override fun setPaused(paused: Boolean) = loop.setPaused(paused)

    override fun showNow() {
        if (!loop.showNow()) controller.setNotice("There is nothing to show: azkar.json has no azkar in it.")
    }

    override fun dismissAll() = stack.dismissAll()

    override fun editAzkar() {
        if (!Reveal.file(paths.azkarFile)) controller.setNotice("azkar.json is at ${paths.azkarFile}")
    }

    override fun perform(action: ProblemAction) {
        when (action) {
            ProblemAction.ShowConfigFolder ->
                if (!Reveal.folder(paths.configDir)) controller.setNotice("The files are in ${paths.configDir}")
            ProblemAction.OpenShortcutSettings ->
                if (!openShortcutSettings(paths.os)) {
                    controller.setNotice("Change it in your desktop's keyboard settings.")
                }
            // Notifications and exact alarms are phone things: here a card is the reminder, and the app's
            // own timer is as exact as it gets. Show the window, so at least something happens.
            ProblemAction.OpenNotificationSettings, ProblemAction.OpenAlarmSettings -> open()
            ProblemAction.TryAgain -> retry()
        }
    }

    override fun quit() = exit()
}
