// The shortcut, how general azkar are picked, and how cards look.
package com.wildduck.azkar.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.wildduck.azkar.app.CardOnScreen
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.ProblemAction
import com.wildduck.azkar.app.ProblemKey
import com.wildduck.azkar.app.ShortcutMode
import com.wildduck.azkar.app.UiState
import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Order
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr
import kotlin.math.roundToInt

private const val PREVIEW_TEXT =
    "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ"

@Composable
fun CardsPage(ui: UiState, features: Features, actions: AzkarActions) {
    val config = ui.config
    Page("Cards") {
        if (features.shortcut) {
            Section(
                footer = "Each press — or a click on the card — counts once, and the last one closes it. " +
                    "× closes a card straight away.",
            ) {
                SettingsRow("Count / close shortcut", Accents.blue) {
                    when (val mode = ui.shortcut.mode) {
                        is ShortcutMode.App -> ShortcutRecorder(
                            hotkey = config.hotkey,
                            style = features.keyStyle,
                            onRecord = { actions.setConfig(config.copy(hotkey = it)) },
                        )
                        is ShortcutMode.SystemSettings -> Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            Text(ui.shortcut.display.ifEmpty { config.hotkey.display(features.keyStyle) })
                            TextButton(onClick = { actions.perform(ProblemAction.OpenShortcutSettings) }) {
                                Text(mode.hint)
                            }
                        }
                        ShortcutMode.None -> Text(
                            "Not available here",
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
                ui.problems.firstOrNull { it.key == ProblemKey.Shortcut }?.let { problem ->
                    Text(
                        problem.text,
                        Modifier.fillMaxWidth().padding(start = 48.dp, end = 14.dp, bottom = 10.dp),
                        color = MaterialTheme.colorScheme.error,
                        style = MaterialTheme.typography.bodySmall,
                    )
                }
            }
        }

        Section("General azkar") {
            SettingsRow("Order", Accents.teal) {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    FilterChip(
                        selected = config.order == Order.Random,
                        onClick = { actions.setConfig(config.copy(order = Order.Random)) },
                        label = { Text("Random") },
                    )
                    FilterChip(
                        selected = config.order == Order.Sequential,
                        onClick = { actions.setConfig(config.copy(order = Order.Sequential)) },
                        label = { Text("In order") },
                    )
                }
            }
            RowDivider()
            SwitchRow(
                title = "Repeat counts",
                color = Accents.green,
                detail = "Off: one tap each, even for ×100 azkar.",
                checked = config.repeatGeneral,
                onChange = { actions.setConfig(config.copy(repeatGeneral = it)) },
            )
        }

        if (features.cards) {
            Section("Cards") {
                StepperRow(
                    title = "Cards on screen at most",
                    color = Accents.pink,
                    value = config.maxStack.toString(),
                    range = 1..10,
                    current = config.maxStack,
                    onChange = { actions.setConfig(config.copy(maxStack = it)) },
                )
                RowDivider()
                SettingsRow("Text size", Accents.grey) {
                    Slider(
                        value = config.fontSize.toFloat(),
                        onValueChange = {
                            actions.setConfig(config.copy(fontSize = it.roundToInt().toDouble()))
                        },
                        valueRange = 14f..36f,
                        modifier = Modifier.width(180.dp),
                    )
                    Text(
                        config.fontSize.roundToInt().toString(),
                        Modifier.width(26.dp),
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.End,
                    )
                }
                Box(Modifier.fillMaxWidth().padding(14.dp), contentAlignment = Alignment.Center) {
                    CardView(
                        card = preview,
                        fontSize = config.fontSize,
                        hint = config.hotkey.display(features.keyStyle),
                        onTap = {},
                        onClose = {},
                        modifier = Modifier.widthIn(max = cardWidth),
                    )
                }
            }
        }
    }
}

/** Roughly what a card looks like at the chosen text size. */
private val preview =
    CardOnScreen(0, Card(Zikr(PREVIEW_TEXT, 3), Session.Sabah, 7, 25), badge = "×3", fraction = 0.0)
