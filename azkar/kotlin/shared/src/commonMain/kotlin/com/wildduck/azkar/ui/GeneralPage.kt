// Starting at login, the tray count, sounds, and where the settings live.
package com.wildduck.azkar.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.ProblemAction
import com.wildduck.azkar.app.UiState

@Composable
fun GeneralPage(ui: UiState, features: Features, actions: AzkarActions) {
    val config = ui.config
    Page("General") {
        if (features.openAtLogin) {
            Section(
                title = "Startup",
                footer = "Opening Azkar yourself always shows this window.",
            ) {
                SwitchRow(
                    title = "Open at login",
                    color = Accents.green,
                    detail = "Start Azkar in the tray when you log in.",
                    checked = config.openAtLogin,
                    onChange = { actions.setConfig(config.copy(openAtLogin = it)) },
                )
                RowDivider()
                SwitchRow(
                    title = "Show this window at login",
                    color = Accents.blue,
                    detail = "Off: it starts quietly, with just the tray icon.",
                    checked = config.showWindowAtLogin,
                    onChange = { actions.setConfig(config.copy(showWindowAtLogin = it)) },
                    enabled = config.openAtLogin,
                )
            }
        }

        if (features.showCount || features.sound) {
            Section(if (features.showCount) "Tray and sound" else "Sound") {
                if (features.showCount) {
                    SwitchRow(
                        title = "Show card count",
                        color = Accents.orange,
                        detail = "3 next to the tray icon while three cards are waiting.",
                        checked = config.showCount,
                        onChange = { actions.setConfig(config.copy(showCount = it)) },
                    )
                    if (features.sound) RowDivider()
                }
                if (features.sound) {
                    SwitchRow(
                        title = "Sounds",
                        color = Accents.pink,
                        detail = "A chime when a card pops in, and when you finish a zikr's count.",
                        checked = config.sound,
                        onChange = { actions.setConfig(config.copy(sound = it)) },
                    )
                }
            }
        }

        // A phone keeps its files inside the app and stops it itself, so there is nothing to press here.
        if (features.files || features.quit) {
            Section(footer = closing(features)) {
                Row(
                    Modifier.fillMaxWidth().padding(horizontal = 14.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    if (features.files) {
                        OutlinedButton(onClick = { actions.perform(ProblemAction.ShowConfigFolder) }) {
                            Text("Show the folder")
                        }
                    }
                    Spacer(Modifier.weight(1f))
                    if (features.quit) {
                        TextButton(
                            onClick = { actions.quit() },
                            colors = ButtonDefaults.textButtonColors(
                                contentColor = MaterialTheme.colorScheme.error,
                            ),
                        ) {
                            Text("Quit Azkar")
                        }
                    }
                }
            }
        } else {
            Footnote(closing(features))
        }
    }
}

private fun closing(features: Features): String = if (features.quit) {
    "Changes are saved to config.json straight away. Quitting stops reminders until you open Azkar again " +
        "or next log in."
} else {
    "Changes are saved straight away. Reminders keep coming with Azkar closed; they stop if you force it to stop."
}
