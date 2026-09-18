// The mark inside a tile. System Settings puts a symbol in every coloured square, and a square on its
// own reads as an icon that failed to load — which is exactly how the phone's tab bar looked. These are
// drawn rather than shipped as files, the same way the tray's beads are, so there is nothing to scale
// and nothing to keep in step across five platforms.
package com.wildduck.azkar.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/** The marks a tile can carry, one per page of the app. */
enum class Glyph { Clock, Calendar, Cards, List, Sliders }

/**
 * Draws [glyph] in white over whatever the tile is filled with. Every measurement is in 24ths of the
 * tile, so the same numbers hold whether it is a 24dp tab or a much larger square.
 */
@Composable
fun GlyphMark(glyph: Glyph, modifier: Modifier = Modifier) {
    Canvas(modifier.fillMaxSize()) {
        val u = size.minDimension / 24f
        when (glyph) {
            Glyph.Clock -> clock(u)
            Glyph.Calendar -> calendar(u)
            Glyph.Cards -> cards(u)
            Glyph.List -> list(u)
            Glyph.Sliders -> sliders(u)
        }
    }
}

private val ink = Color.White

private fun DrawScope.clock(u: Float) {
    val middle = Offset(size.width / 2, size.height / 2)
    drawCircle(ink, 6.4f * u, middle, style = Stroke(1.8f * u))
    // Ten past ten, the time every clock in every advert is set to.
    hand(middle, 2.9f * u, 10f / 12f, u)
    hand(middle, 3.9f * u, 2f / 12f, u)
}

/** [turns] is where the hand points, as a fraction of the dial clockwise from twelve. */
private fun DrawScope.hand(from: Offset, length: Float, turns: Float, u: Float) {
    val angle = (turns * 2 - 0.5f) * PI.toFloat()
    drawLine(
        ink,
        from,
        Offset(from.x + cos(angle) * length, from.y + sin(angle) * length),
        strokeWidth = 1.8f * u,
        cap = StrokeCap.Round,
    )
}

private fun DrawScope.calendar(u: Float) {
    // The two stubs poking out of the top are what stop this reading as a window.
    for (x in listOf(9f, 15f)) {
        drawLine(
            ink,
            Offset(x * u, 4.3f * u),
            Offset(x * u, 8f * u),
            strokeWidth = 1.8f * u,
            cap = StrokeCap.Round,
        )
    }
    val corner = CornerRadius(2.4f * u, 2.4f * u)
    drawRoundRect(ink, Offset(5f * u, 6.8f * u), Size(14f * u, 12.4f * u), corner, Stroke(1.8f * u))
    drawRoundRect(ink, Offset(5f * u, 6.8f * u), Size(14f * u, 3.6f * u), CornerRadius(1.6f * u, 1.6f * u))
}

private fun DrawScope.cards(u: Float) {
    // Two solid cards, the back one peeking out at the top right. Overlapping the same white is the
    // point: the silhouette is the icon.
    val corner = CornerRadius(2.2f * u, 2.2f * u)
    drawRoundRect(ink, Offset(8.5f * u, 4.5f * u), Size(10.5f * u, 11.5f * u), corner)
    drawRoundRect(ink, Offset(5f * u, 8f * u), Size(10.5f * u, 11.5f * u), corner)
}

private fun DrawScope.list(u: Float) {
    for (row in 0..2) {
        drawLine(
            ink,
            Offset(5.8f * u, (7.2f + row * 4.8f) * u),
            Offset(18.2f * u, (7.2f + row * 4.8f) * u),
            strokeWidth = 1.5f * u,
            cap = StrokeCap.Round,
        )
    }
}

private fun DrawScope.sliders(u: Float) {
    // The knobs are fatter than their tracks, which is the only thing that has to read at 24dp.
    track(y = 9f * u, knobX = 9f * u, u = u)
    track(y = 15f * u, knobX = 15f * u, u = u)
}

private fun DrawScope.track(y: Float, knobX: Float, u: Float) {
    drawLine(
        ink,
        Offset(5f * u, y),
        Offset(19f * u, y),
        strokeWidth = 1.6f * u,
        cap = StrokeCap.Round,
    )
    drawCircle(ink, 2.6f * u, Offset(knobX, y))
}
