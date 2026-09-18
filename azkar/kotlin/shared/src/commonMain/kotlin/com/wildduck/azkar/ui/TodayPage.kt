// Reminders on or off, the next card, and today's progress through the morning and evening lists.
package com.wildduck.azkar.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.UiState
import com.wildduck.azkar.core.Session

@Composable
fun TodayPage(ui: UiState, features: Features, actions: AzkarActions) {
    Page("Today") {
        Section {
            Row(
                Modifier.fillMaxWidth().padding(horizontal = 14.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(Modifier.weight(1f)) {
                    Text(
                        if (ui.paused) "Reminders are paused" else "Reminders are on",
                        style = MaterialTheme.typography.titleMedium,
                    )
                    Text(
                        subtitle(ui),
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        style = MaterialTheme.typography.bodyMedium,
                    )
                }
                Switch(!ui.paused, { actions.setPaused(!it) }, Modifier.testTag("switch:reminders"))
            }
        }

        Section("Today") {
            ProgressRow("Morning azkar", Accents.orange, ui.sabahDone, ui.sabahTotal) {
                actions.restart(Session.Sabah)
            }
            RowDivider()
            ProgressRow("Evening azkar", Accents.purple, ui.masaaDone, ui.masaaTotal) {
                actions.restart(Session.Masaa)
            }
        }

        Section {
            Row(
                Modifier.fillMaxWidth().padding(horizontal = 14.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                Button(onClick = { actions.showNow() }) { Text("Show a zikr now") }
                if (features.cards) {
                    OutlinedButton(onClick = { actions.dismissAll() }, enabled = ui.onScreen > 0) {
                        Text("Dismiss all")
                    }
                    Spacer(Modifier.weight(1f))
                    Text(
                        if (ui.onScreen == 1) "1 card on screen" else "${ui.onScreen} cards on screen",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }

        if (ui.problems.isNotEmpty()) {
            Section("Needs attention") {
                for (problem in ui.problems) {
                    SettingsRow(problem.text, MaterialTheme.colorScheme.error) {
                        problem.action?.let { action ->
                            TextButton(onClick = { actions.perform(action) }) { Text(action.label) }
                        }
                    }
                }
            }
        }
    }
}

private fun subtitle(ui: UiState): String {
    if (ui.paused) return "No new cards until you switch them back on."
    val seconds = ui.nextIn ?: return ""
    val next = "Next zikr in ${seconds / 60}:${(seconds % 60).toString().padStart(2, '0')}"
    return ui.lastSkip?.let { "$next  ·  last one skipped: $it" } ?: next
}

@Composable
private fun ProgressRow(title: String, color: Color, done: Int, total: Int, onRestart: () -> Unit) {
    Row(
        Modifier.fillMaxWidth().padding(horizontal = 14.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Tile(color)
        Column(Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(title, Modifier.weight(1f), style = MaterialTheme.typography.bodyLarge)
                Text(
                    if (total > 0 && done >= total) "Done" else "$done of $total",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.bodyMedium,
                )
            }
            LinearProgressIndicator(
                progress = { if (total > 0) (done.coerceAtMost(total).toFloat() / total) else 0f },
                modifier = Modifier.fillMaxWidth().padding(top = 6.dp),
                color = color,
                trackColor = color.copy(alpha = 0.2f),
                drawStopIndicator = {},
            )
        }
        TextButton(
            onClick = onRestart,
            modifier = Modifier.testTag("restart:$title"),
            enabled = done > 0,
        ) { Text("Restart") }
    }
}
