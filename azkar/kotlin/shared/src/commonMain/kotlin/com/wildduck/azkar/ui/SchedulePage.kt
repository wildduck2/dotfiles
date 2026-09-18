// The interval, and the morning, evening and quiet-hours times.
package com.wildduck.azkar.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.UiState
import com.wildduck.azkar.app.WindowKey
import com.wildduck.azkar.core.Config
import com.wildduck.azkar.core.TimeWindow
import kotlin.math.floor
import kotlin.math.roundToInt

@Composable
fun SchedulePage(ui: UiState, features: Features, actions: AzkarActions) {
    val config = ui.config
    Page("Schedule") {
        Section(footer = "A new card appears on this interval while there's room on screen.") {
            StepperRow(
                title = "Remind me every",
                color = Accents.teal,
                value = "${trim(config.intervalMinutes)} min",
                range = 1..120,
                current = config.intervalMinutes.roundToInt(),
                onChange = { actions.setConfig(config.copy(intervalMinutes = it.toDouble())) },
            )
        }

        WindowSection(
            key = WindowKey.Sabah,
            color = Accents.orange,
            footer = "Goes through the ${ui.library.sabah.size} morning azkar in order, once a day.",
            config = config,
            actions = actions,
        )
        WindowSection(
            key = WindowKey.Masaa,
            color = Accents.purple,
            footer = "Goes through the ${ui.library.masaa.size} evening azkar in order, once a day.",
            config = config,
            actions = actions,
        )
        WindowSection(
            key = WindowKey.Quiet,
            color = Accents.indigo,
            footer = "No new cards during these hours.",
            config = config,
            actions = actions,
        )

        Footnote(
            "Between and after the morning and evening times — and once their list is done — you get general " +
                "azkar" + (if (config.repeatGeneral) "" else ", one tap each") + ".",
        )
    }
}

/** One daily window: a switch, and its two times while it is on. */
@Composable
private fun WindowSection(
    key: WindowKey,
    color: Color,
    footer: String,
    config: Config,
    actions: AzkarActions,
) {
    val window = key.of(config)
    Section(footer = footer) {
        SwitchRow(
            title = key.label,
            color = color,
            checked = window != null,
            onChange = { on ->
                actions.setConfig(key.set(config, if (on) actions.rememberedWindow(key) else null))
            },
        )
        if (window != null) {
            Row(
                Modifier.fillMaxWidth().padding(start = 48.dp, end = 14.dp, bottom = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                ClockField(
                    label = "From",
                    minutes = window.start,
                    onChange = { actions.setConfig(key.set(config, TimeWindow(it, window.end))) },
                    modifier = Modifier.testTag("clock:${key.name}:from"),
                )
                ClockField(
                    label = "To",
                    minutes = window.end,
                    onChange = { actions.setConfig(key.set(config, TimeWindow(window.start, it))) },
                    modifier = Modifier.testTag("clock:${key.name}:to"),
                )
                Text(
                    if (window.end <= window.start) "Runs past midnight" else "",
                    Modifier.padding(top = 18.dp),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.bodySmall,
                )
            }
        }
    }
}

/** 3.0 -> "3", 2.5 -> "2.5". */
private fun trim(minutes: Double): String =
    if (minutes == floor(minutes)) minutes.toInt().toString() else minutes.toString()
