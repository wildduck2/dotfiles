// The tray icon and its menu: what Azkar is doing, and everything you can do without opening the window.
package com.wildduck.azkar.desktop

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import com.wildduck.azkar.app.UiState
import com.wildduck.azkar.ui.Accents
import dev.nucleusframework.composenativetray.menu.api.TrayMenuBuilder
import dev.nucleusframework.composenativetray.tray.api.Tray
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/** What the tray menu can ask the app to do. */
class TrayActions(
    val count: () -> Unit = {},
    val dismissOldest: () -> Unit = {},
    val dismissAll: () -> Unit = {},
    val showNow: () -> Unit = {},
    val togglePause: () -> Unit = {},
    val open: () -> Unit = {},
    val quit: () -> Unit = {},
)

/** The menu-bar item of the macOS app, as a tray icon: the same lines, in the same order. */
@Composable
fun AzkarTray(ui: UiState, cards: Int, actions: TrayActions) {
    val hint = ui.shortcut.display.takeIf { it.isNotEmpty() }?.let { "   $it or click" } ?: ""
    val waiting = cards > 0
    val menu: TrayMenuBuilder.() -> Unit = {
        Item(label = statusLine(ui), isEnabled = false) {}
        if (ui.sabahTotal + ui.masaaTotal > 0) Item(label = progressLine(ui), isEnabled = false) {}
        for (problem in ui.problems) Item(label = "⚠️  ${problem.text}", isEnabled = false) {}
        Divider()
        Item(label = "Count on oldest$hint", isEnabled = waiting) { actions.count() }
        Item(label = "Dismiss oldest", isEnabled = waiting) { actions.dismissOldest() }
        Item(label = "Dismiss all", isEnabled = waiting) { actions.dismissAll() }
        Item(label = "Show one now") { actions.showNow() }
        Item(label = if (ui.paused) "Resume" else "Pause") { actions.togglePause() }
        Divider()
        Item(label = "Open Azkar…") { actions.open() }
        Divider()
        Item(label = "Quit Azkar") { actions.quit() }
    }
    Tray(
        iconContent = { TrayBeads(if (ui.config.showCount) cards else 0, ui.paused) },
        tooltip = tooltip(ui, cards),
        primaryAction = actions.open,
        menuContent = menu,
    )
}

/**
 * The first line of the menu. Minutes, not seconds: the desktop rebuilds the whole menu whenever a line
 * changes, and once a minute is enough. The window's Today page has the countdown to the second.
 */
internal fun statusLine(ui: UiState): String {
    if (ui.paused) return "Paused"
    val seconds = ui.nextIn ?: return "Reminders are on"
    val line = if (seconds < 60) "Next zikr in under a minute" else "Next zikr in ${seconds / 60} min"
    return ui.lastSkip?.let { "$line  ·  last skipped: $it" } ?: line
}

/** Today's progress through the two lists, shown only while there is a list to get through. */
internal fun progressLine(ui: UiState): String =
    "Morning ${ui.sabahDone}/${ui.sabahTotal}  ·  Evening ${ui.masaaDone}/${ui.masaaTotal}"

internal fun tooltip(ui: UiState, cards: Int): String {
    val waiting = when {
        cards == 1 -> "  ·  1 card waiting"
        cards > 1 -> "  ·  $cards cards waiting"
        else -> ""
    }
    return "Azkar  ·  ${statusLine(ui)}$waiting"
}

/** Beads in a ring, with the waiting cards counted in the middle. Dimmed while reminders are paused. */
@Composable
private fun TrayBeads(count: Int, paused: Boolean) {
    val measurer = rememberTextMeasurer()
    val bead = if (paused) Accents.teal.copy(alpha = 0.4f) else Accents.teal
    Canvas(Modifier.fillMaxSize()) {
        val centre = Offset(size.width / 2, size.height / 2)
        val radius = size.minDimension / 2
        val ring = radius * 0.74f
        repeat(BEADS) { i ->
            val angle = 2 * PI * i / BEADS - PI / 2
            val at = centre + Offset((cos(angle) * ring).toFloat(), (sin(angle) * ring).toFloat())
            drawCircle(bead, radius * 0.16f, at)
        }
        if (count <= 0) {
            drawCircle(bead, radius * 0.2f, centre)
            return@Canvas
        }
        drawCircle(bead, radius * 0.46f, centre)
        val text = measurer.measure(
            AnnotatedString(count.toString()),
            TextStyle(color = Color.White, fontSize = (radius * 0.6f).toSp(), fontWeight = FontWeight.Bold),
        )
        drawText(text, topLeft = centre - Offset(text.size.width / 2f, text.size.height / 2f))
    }
}

private const val BEADS = 8
