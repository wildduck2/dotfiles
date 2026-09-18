// One window per card: no frame, no focus, always on top, stacked down the right of the screen.
package com.wildduck.azkar.desktop

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.WindowPosition
import androidx.compose.ui.window.rememberWindowState
import com.wildduck.azkar.app.CardOnScreen
import com.wildduck.azkar.app.CardSpot
import com.wildduck.azkar.app.cardPositions
import com.wildduck.azkar.ui.AzkarTheme
import com.wildduck.azkar.ui.CardView
import com.wildduck.azkar.ui.cardWidth
import kotlin.math.ceil

/** How tall a card is taken to be until it has been drawn once and measured. */
private const val GUESSED_HEIGHT = 220

/** The cards on screen, laid out from the top-right corner down. */
@Composable
fun CardWindows(
    cards: List<CardOnScreen>,
    fontSize: Double,
    hint: String,
    onTap: (Long) -> Unit,
    onClose: (Long) -> Unit,
) {
    // Each card's real height, once it has been drawn; the layout needs them to stack the next one.
    val heights = remember { mutableStateMapOf<Long, Int>() }
    val transparent = remember { transparentWindowsWork() }
    val spots = cardPositions(
        area = defaultCardArea(),
        width = cardWidth.value.toInt(),
        heights = cards.map { heights[it.id] ?: GUESSED_HEIGHT },
    )
    for ((index, card) in cards.withIndex()) {
        key(card.id) {
            CardWindow(
                card = card,
                spot = spots[index],
                height = heights[card.id] ?: GUESSED_HEIGHT,
                transparent = transparent,
                fontSize = fontSize,
                hint = hint,
                onHeight = { heights[card.id] = it },
                onTap = { onTap(card.id) },
                onClose = { onClose(card.id) },
            )
        }
    }
    val ids = cards.map { it.id }
    LaunchedEffect(ids) { heights.keys.retainAll(ids.toSet()) }
}

@Composable
private fun CardWindow(
    card: CardOnScreen,
    spot: CardSpot,
    height: Int,
    transparent: Boolean,
    fontSize: Double,
    hint: String,
    onHeight: (Int) -> Unit,
    onTap: () -> Unit,
    onClose: () -> Unit,
) {
    val state = rememberWindowState(
        position = WindowPosition(spot.x.dp, spot.y.dp),
        size = DpSize(cardWidth, height.dp),
    )
    LaunchedEffect(spot, height) {
        state.position = WindowPosition(spot.x.dp, spot.y.dp)
        state.size = DpSize(cardWidth, height.dp)
    }
    Window(
        onCloseRequest = onClose,
        state = state,
        title = "Azkar",
        undecorated = true,
        transparent = transparent,
        resizable = false,
        // Cards never take the keyboard: whatever you were typing in stays where it was.
        focusable = false,
        alwaysOnTop = true,
    ) {
        AzkarTheme {
            val density = LocalDensity.current
            Box(Modifier.fillMaxWidth().wrapContentHeight(align = Alignment.Top, unbounded = true)) {
                CardView(
                    card = card,
                    fontSize = fontSize,
                    hint = hint,
                    onTap = onTap,
                    onClose = onClose,
                    modifier = Modifier.onSizeChanged { size ->
                        // The window is told how tall the card really came out, rounded up so nothing is cut off.
                        val tall = ceil(size.height / density.density).toInt()
                        if (tall > 0) onHeight(tall)
                    },
                )
            }
        }
    }
}
