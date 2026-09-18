// One zikr card: dark, right-to-left, one click per repetition.
package com.wildduck.azkar.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.Canvas
import com.wildduck.azkar.app.CardOnScreen
import com.wildduck.azkar.app.cardHeader

/** The card's width everywhere: on screen and in the settings preview. */
val cardWidth = 440.dp

/**
 * A card. The whole card counts one repetition when clicked, except the × in its corner, which
 * closes it whatever is left of its count. `hint` is the shortcut, shown at the bottom.
 */
@Composable
fun CardView(
    card: CardOnScreen,
    fontSize: Double,
    hint: String,
    onTap: () -> Unit,
    onClose: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val accent = card.card.session.accent
    val zikr = card.card.zikr
    val header = cardHeader(card.card)

    Column(
        modifier
            .testTag("card")
            .background(CardColors.surface, RoundedCornerShape(14.dp))
            .clickable(onClick = onTap)
            .padding(18.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            CloseButton(onClose)
            if (card.badge.isNotEmpty()) {
                Text(
                    card.badge,
                    Modifier.padding(start = 6.dp),
                    color = accent,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                )
            }
            Text(
                header,
                Modifier.weight(1f),
                color = accent,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.End,
            )
        }
        Text(
            zikr.text,
            Modifier.fillMaxWidth(),
            color = CardColors.text,
            fontFamily = LocalArabic.current,
            fontSize = fontSize.sp,
            // Room for the harakat above and below the letters.
            lineHeight = (fontSize * 1.45).sp,
            textAlign = TextAlign.End,
        )
        zikr.note?.let { note ->
            Text(
                note,
                Modifier.fillMaxWidth(),
                color = CardColors.secondary,
                fontFamily = LocalArabic.current,
                fontSize = 12.sp,
                lineHeight = 18.sp,
                textAlign = TextAlign.End,
            )
        }
        Text("انقر أو $hint", color = CardColors.tertiary, fontSize = 11.sp)
        if (card.fraction > 0.0 || card.badge.isNotEmpty()) {
            // Fills right-to-left, like the text.
            Box(
                Modifier
                    .fillMaxWidth()
                    .height(3.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(accent.copy(alpha = 0.2f)),
                contentAlignment = Alignment.CenterEnd,
            ) {
                Box(
                    Modifier
                        .fillMaxWidth(card.fraction.toFloat())
                        .height(3.dp)
                        .background(accent),
                )
            }
        }
    }
}

/** The × in the card's corner, drawn rather than typed so it looks the same on every desktop. */
@Composable
private fun CloseButton(onClose: () -> Unit) {
    Canvas(
        Modifier
            .testTag("close")
            .size(16.dp)
            .clip(RoundedCornerShape(8.dp))
            .clickable(onClick = onClose)
            .padding(4.dp),
    ) {
        val stroke = 1.6.dp.toPx()
        val cross = Color(0xFF9AA1A6)
        drawLine(cross, Offset(0f, 0f), Offset(size.width, size.height), stroke, StrokeCap.Round)
        drawLine(cross, Offset(0f, size.height), Offset(size.width, 0f), stroke, StrokeCap.Round)
    }
}
