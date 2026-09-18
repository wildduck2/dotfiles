// Click, then press the new shortcut. Esc cancels.
package com.wildduck.azkar.ui

import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.isAltPressed
import androidx.compose.ui.input.key.isCtrlPressed
import androidx.compose.ui.input.key.isMetaPressed
import androidx.compose.ui.input.key.isShiftPressed
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onPreviewKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.platform.testTag
import com.wildduck.azkar.app.KeyNames
import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.KeyStyle

/**
 * Shows the shortcut; click it and the next key press with a modifier becomes the new one. A press
 * without a modifier, or a key Azkar can't use, is ignored so the recorder keeps waiting.
 */
@Composable
fun ShortcutRecorder(
    hotkey: Hotkey,
    style: KeyStyle,
    onRecord: (Hotkey) -> Unit,
    modifier: Modifier = Modifier,
) {
    var recording by remember { mutableStateOf(false) }
    val focus = remember { FocusRequester() }
    LaunchedEffect(recording) { if (recording) focus.requestFocus() }

    Button(
        onClick = { recording = !recording },
        modifier = modifier
            .testTag("recorder")
            .focusRequester(focus)
            .onPreviewKeyEvent { event ->
                if (!recording || event.type != KeyEventType.KeyDown) return@onPreviewKeyEvent false
                if (event.key == Key.Escape) {
                    recording = false
                    return@onPreviewKeyEvent true
                }
                val recorded = KeyNames.hotkey(
                    event.key,
                    ctrl = event.isCtrlPressed,
                    alt = event.isAltPressed,
                    shift = event.isShiftPressed,
                    meta = event.isMetaPressed,
                )
                if (recorded != null) {
                    onRecord(recorded)
                    recording = false
                }
                // Nothing else gets the keys while the recorder is listening.
                true
            },
        colors = if (recording) {
            ButtonDefaults.buttonColors()
        } else {
            ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.surfaceVariant,
                contentColor = MaterialTheme.colorScheme.onSurface,
            )
        },
    ) {
        Text(if (recording) "Press keys…" else hotkey.display(style))
    }
}
