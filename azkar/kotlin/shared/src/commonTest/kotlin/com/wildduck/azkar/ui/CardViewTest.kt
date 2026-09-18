package com.wildduck.azkar.ui

import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.test.ExperimentalTestApi
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performKeyInput
import androidx.compose.ui.test.pressKey
import androidx.compose.ui.test.runComposeUiTest
import androidx.compose.ui.test.withKeyDown
import com.wildduck.azkar.app.CardStack
import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.KeyStyle
import com.wildduck.azkar.core.Modifier
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

@OptIn(ExperimentalTestApi::class)
class CardViewTest {
    @Test
    fun clickingACardCountsItsRepetitions() = runComposeUiTest {
        val stack = CardStack()
        stack.push(Card(Zikr("سبحان الله", 3), Session.Sabah, 1, 12))
        setContent {
            val cards by stack.cards.collectAsState()
            AzkarTheme(dark = true) {
                cards.firstOrNull()?.let { card ->
                    CardView(
                        card = card,
                        fontSize = 22.0,
                        hint = "Ctrl+Alt+Z",
                        onTap = { stack.tap(card.id) },
                        onClose = { stack.dismiss(card.id) },
                    )
                }
            }
        }
        onNodeWithText("أذكار الصباح  ·  1 من 12").assertIsDisplayed()
        onNodeWithText("×3").assertIsDisplayed()
        onNodeWithText("انقر أو Ctrl+Alt+Z").assertIsDisplayed()

        onNodeWithTag("card").performClick()
        onNodeWithText("1/3").assertIsDisplayed()
        onNodeWithTag("card").performClick()
        onNodeWithTag("card").performClick()
        assertEquals(0, stack.count, "the last click closes the card")
    }

    @Test
    fun theCrossClosesACardStraightAway() = runComposeUiTest {
        val stack = CardStack()
        stack.push(Card(Zikr("سبحان الله", 3), Session.General))
        setContent {
            val cards by stack.cards.collectAsState()
            AzkarTheme(dark = true) {
                cards.firstOrNull()?.let { card ->
                    CardView(card, 22.0, "Ctrl+Alt+Z", onTap = { stack.tap(card.id) }, onClose = { stack.dismiss(card.id) })
                }
            }
        }
        onNodeWithTag("close").performClick()
        assertEquals(0, stack.count, "the card is gone with its count unfinished")
    }

    @Test
    fun theRecorderTakesAKeyWithAModifier() = runComposeUiTest {
        var recorded: Hotkey? = null
        setContent {
            AzkarTheme(dark = true) {
                ShortcutRecorder(
                    hotkey = Hotkey(setOf(Modifier.Ctrl, Modifier.Alt), "z"),
                    style = KeyStyle.Linux,
                    onRecord = { recorded = it },
                )
            }
        }
        onNodeWithText("Ctrl+Alt+Z").assertIsDisplayed()

        onNodeWithTag("recorder").performClick()
        onNodeWithText("Press keys…").assertIsDisplayed()

        onNodeWithTag("recorder").performKeyInput { pressKey(Key.J) }
        assertNull(recorded, "a recorded key press needs a modifier")
        onNodeWithText("Press keys…").assertIsDisplayed()

        onNodeWithTag("recorder").performKeyInput { withKeyDown(Key.CtrlLeft) { pressKey(Key.J) } }
        assertEquals("ctrl+j", recorded?.spec, "a recorded key press becomes the same hotkey as its spec")
    }

    @Test
    fun escapeStopsRecording() = runComposeUiTest {
        var recorded: Hotkey? = null
        setContent {
            AzkarTheme(dark = true) {
                ShortcutRecorder(
                    hotkey = Hotkey(setOf(Modifier.Ctrl), "space"),
                    style = KeyStyle.Windows,
                    onRecord = { recorded = it },
                )
            }
        }
        onNodeWithTag("recorder").performClick()
        onNodeWithTag("recorder").performKeyInput { pressKey(Key.Escape) }
        onNodeWithText("Ctrl+Space").assertIsDisplayed()
        assertNull(recorded, "nothing was recorded")
    }
}
