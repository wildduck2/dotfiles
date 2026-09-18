// What the Swift shell calls: the app, once, and the screen it hosts.
package com.wildduck.azkar.ios

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
import androidx.compose.ui.window.ComposeUIViewController
import com.wildduck.azkar.app.CardOnScreen
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.TAP_TO_COUNT
import com.wildduck.azkar.ui.AzkarTheme
import com.wildduck.azkar.ui.AzkarWindow
import com.wildduck.azkar.ui.CardView
import com.wildduck.azkar.ui.cardWidth
import kotlin.time.Duration.Companion.seconds
import kotlinx.coroutines.delay
import platform.UIKit.UIViewController

/** One app for the process, whichever part of iOS asks for it first. */
private val app by lazy { IosApp() }

/** Called by the shell as the app finishes launching, before there is a screen. */
fun startAzkar() = app.start()

/** The screen, for the shell to host. */
fun mainViewController(): UIViewController = ComposeUIViewController { AzkarScreen() }

@Composable
private fun AzkarScreen() {
    val ui by app.controller.ui.collectAsState()
    val cards by app.stack.cards.collectAsState()
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

        Box(Modifier.fillMaxSize()) {
            AzkarWindow(ui, Features.ios, app.actions, Modifier.safeDrawingPadding())
            // One at a time: a tap opens one zikr, and the next appears once it's done.
            cards.firstOrNull()?.let { card ->
                ReminderCard(
                    card = card,
                    fontSize = ui.config.fontSize,
                    onTap = { app.stack.tap(card.id) },
                    onClose = { app.stack.dismiss(card.id) },
                )
            }
        }
    }
}

/** A tapped reminder, as the card it would have been on a desktop. */
@Composable
private fun ReminderCard(card: CardOnScreen, fontSize: Double, onTap: () -> Unit, onClose: () -> Unit) {
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
            card = card,
            fontSize = fontSize,
            hint = TAP_TO_COUNT,
            onTap = onTap,
            onClose = onClose,
            modifier = Modifier.widthIn(max = cardWidth),
        )
    }
}
