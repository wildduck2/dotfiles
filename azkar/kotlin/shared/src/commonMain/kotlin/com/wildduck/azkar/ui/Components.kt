// The pieces every settings page is built from: sections, rows, switches, steppers and clock fields.
package com.wildduck.azkar.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.wildduck.azkar.core.formatClock
import com.wildduck.azkar.core.parseClock

/** The coloured square that marks a row, the way System Settings does, with its symbol if it has one. */
@Composable
fun Tile(color: Color, modifier: Modifier = Modifier, glyph: Glyph? = null) {
    Box(
        modifier
            .size(24.dp)
            .background(
                Brush.verticalGradient(listOf(color, color.copy(alpha = 0.72f))),
                RoundedCornerShape(7.dp),
            ),
        contentAlignment = Alignment.Center,
    ) {
        if (glyph != null) GlyphMark(glyph)
    }
}

/** The explanation under a section. */
@Composable
fun Footnote(text: String, modifier: Modifier = Modifier) {
    Text(
        text,
        modifier.fillMaxWidth().padding(start = 4.dp, end = 4.dp, top = 6.dp),
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        style = MaterialTheme.typography.bodySmall,
    )
}

/** A titled group of rows on a card, with an optional footnote underneath. */
@Composable
fun Section(
    title: String? = null,
    footer: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(modifier.fillMaxWidth().padding(bottom = 14.dp)) {
        if (title != null) {
            Text(
                title,
                Modifier.padding(start = 4.dp, bottom = 6.dp),
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                style = MaterialTheme.typography.labelLarge,
            )
        }
        Column(
            Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(12.dp))
                .padding(vertical = 4.dp),
            content = content,
        )
        if (footer != null) Footnote(footer)
    }
}

/** A thin line between two rows in the same section. */
@Composable
fun RowDivider() {
    HorizontalDivider(
        Modifier.padding(start = 48.dp, end = 14.dp),
        color = MaterialTheme.colorScheme.outlineVariant,
    )
}

/** Tile, title and optional detail on the left; whatever `trailing` draws on the right. */
@Composable
fun SettingsRow(
    title: String,
    color: Color,
    detail: String? = null,
    enabled: Boolean = true,
    modifier: Modifier = Modifier,
    trailing: @Composable () -> Unit = {},
) {
    Row(
        modifier.fillMaxWidth().padding(horizontal = 14.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Tile(if (enabled) color else color.copy(alpha = 0.4f))
        Column(Modifier.weight(1f)) {
            Text(
                title,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = if (enabled) 1f else 0.5f),
                style = MaterialTheme.typography.bodyLarge,
            )
            if (detail != null) {
                Text(
                    detail,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.bodySmall,
                )
            }
        }
        trailing()
    }
}

@Composable
fun SwitchRow(
    title: String,
    color: Color,
    checked: Boolean,
    onChange: (Boolean) -> Unit,
    detail: String? = null,
    enabled: Boolean = true,
) {
    SettingsRow(title, color, detail, enabled) {
        Switch(checked, onChange, modifier = Modifier.testTag("switch:$title"), enabled = enabled)
    }
}

/** − and + around a value, for the interval and the card limit. */
@Composable
fun StepperRow(
    title: String,
    color: Color,
    value: String,
    range: IntRange,
    current: Int,
    onChange: (Int) -> Unit,
    detail: String? = null,
) {
    SettingsRow(title, color, detail) {
        Text(value, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.width(6.dp))
        TextButton(onClick = { onChange(current - 1) }, enabled = current > range.first) { Text("−") }
        TextButton(onClick = { onChange(current + 1) }, enabled = current < range.last) { Text("+") }
    }
}

/**
 * A time as HH:mm. The value is only passed on once it reads as a time, so half-typed text
 * ("06:" ) doesn't change the setting.
 */
@Composable
fun ClockField(label: String, minutes: Int, onChange: (Int) -> Unit, modifier: Modifier = Modifier) {
    var text by remember { mutableStateOf(formatClock(minutes)) }
    // Follow the setting when it changes elsewhere, without rewriting what is being typed.
    LaunchedEffect(minutes) {
        if (parseClock(text) != minutes) text = formatClock(minutes)
    }
    val parsed = parseClock(text)
    OutlinedTextField(
        value = text,
        onValueChange = { new ->
            text = new.take(5)
            parseClock(text)?.let(onChange)
        },
        modifier = modifier.width(112.dp),
        label = { Text(label) },
        isError = parsed == null,
        singleLine = true,
        textStyle = LocalTextStyle.current.copy(fontWeight = FontWeight.Medium),
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
    )
}

/** A page: a title, then its sections, scrolling if the window is short. */
@Composable
fun Page(title: String, modifier: Modifier = Modifier, content: @Composable ColumnScope.() -> Unit) {
    Column(
        modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 18.dp),
    ) {
        Text(title, style = MaterialTheme.typography.headlineSmall)
        Spacer(Modifier.width(0.dp))
        Column(Modifier.padding(top = 14.dp), content = content)
    }
}
