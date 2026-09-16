package com.wildduck.azkar.ui

import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.test.ExperimentalTestApi
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextReplacement
import androidx.compose.ui.test.runComposeUiTest
import com.wildduck.azkar.app.AzkarController
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.Storage
import com.wildduck.azkar.app.WindowKey
import com.wildduck.azkar.core.TimeWindow
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.time.Instant
import kotlinx.datetime.TimeZone

private const val AZKAR_JSON =
    """{"sabah":[{"text":"سبحان الله","count":3}],"masaa":[{"text":"الحمد لله"}],""" +
        """"general":[{"text":"لا إله إلا الله"}]}"""

private class MemoryStorage(var config: String? = null) : Storage {
    var state: String? = null
    private var version = 0

    override fun readConfig(): String? = config

    override fun writeConfig(text: String) {
        config = text
        version += 1
    }

    override fun readAzkar(): String = AZKAR_JSON

    override fun readState(): String? = state

    override fun writeState(text: String) {
        state = text
    }

    override fun stamp(): Any = version
}

private fun controller(storage: Storage) = AzkarController(storage, Features.linux) { TimeZone.UTC }

/** The window, drawn for real. */
@OptIn(ExperimentalTestApi::class)
class WindowTest {
    @Test
    fun everyPageDraws() = runComposeUiTest {
        val c = controller(MemoryStorage())
        setContent {
            val ui by c.ui.collectAsState()
            AzkarTheme(dark = true) { AzkarWindow(ui, c.features, ControllerActions(c) { Instant.DISTANT_PAST }) }
        }
        onNodeWithText("Reminders are on").assertIsDisplayed()

        onNodeWithText("Schedule").performClick()
        onNodeWithText("Remind me every").assertIsDisplayed()

        onNodeWithText("Cards").performClick()
        onNodeWithText("Count / close shortcut").assertIsDisplayed()

        onNodeWithText("Azkar").performClick()
        onNodeWithText("Edit azkar.json").assertIsDisplayed()

        onNodeWithText("General").performClick()
        onNodeWithText("Open at login").assertIsDisplayed()

        onNodeWithText("Today").performClick()
        onNodeWithText("Show a zikr now").assertIsDisplayed()
    }

    @Test
    fun theRemindersSwitchPausesAndResumes() = runComposeUiTest {
        val storage = MemoryStorage()
        val c = controller(storage)
        setContent {
            val ui by c.ui.collectAsState()
            AzkarTheme(dark = true) { AzkarWindow(ui, c.features, ControllerActions(c) { Instant.DISTANT_PAST }) }
        }
        onNodeWithTag("switch:reminders").performClick()
        assertEquals(true, c.state.paused, "the switch pauses reminders")
        onNodeWithText("Reminders are paused").assertIsDisplayed()
        onNodeWithTag("switch:reminders").performClick()
        assertEquals(false, c.state.paused, "and starts them again")
    }

    @Test
    fun switchingAWindowOffAndOnKeepsItsTimes() = runComposeUiTest {
        val storage = MemoryStorage("""{"sabah": {"start": "06:00", "end": "10:00"}}""")
        val c = controller(storage)
        setContent {
            val ui by c.ui.collectAsState()
            AzkarTheme(dark = true) { AzkarWindow(ui, c.features, ControllerActions(c) { Instant.DISTANT_PAST }) }
        }
        onNodeWithText("Schedule").performClick()

        onNodeWithTag("switch:${WindowKey.Sabah.label}").performClick()
        assertNull(c.ui.value.config.sabah, "the morning window is off")
        onNodeWithTag("switch:${WindowKey.Sabah.label}").performClick()
        assertEquals(
            TimeWindow(6 * 60, 10 * 60),
            c.ui.value.config.sabah,
            "switching it back on restores the times it had",
        )
    }

    @Test
    fun aTimeIsOnlySavedOnceItReadsAsOne() = runComposeUiTest {
        val c = controller(MemoryStorage())
        setContent {
            val ui by c.ui.collectAsState()
            AzkarTheme(dark = true) { AzkarWindow(ui, c.features, ControllerActions(c) { Instant.DISTANT_PAST }) }
        }
        onNodeWithText("Schedule").performClick()

        onNodeWithTag("clock:Sabah:from").performTextReplacement("06:9")
        assertEquals(5 * 60, c.ui.value.config.sabah?.start, "half-typed times change nothing")
        onNodeWithTag("clock:Sabah:from").performTextReplacement("06:45")
        assertEquals(6 * 60 + 45, c.ui.value.config.sabah?.start, "a real time is saved")
        assertEquals(11 * 60, c.ui.value.config.sabah?.end, "and leaves the other end alone")
    }

    @Test
    fun restartingTodaysList() = runComposeUiTest {
        val storage = MemoryStorage()
        val c = controller(storage)
        c.pick(Instant.parse("2026-09-16T06:00:00Z")) { 0 }
        c.setStatus(now = Instant.parse("2026-09-16T06:00:10Z"), nextFire = Instant.parse("2026-09-16T06:03:00Z"))
        setContent {
            val ui by c.ui.collectAsState()
            AzkarTheme(dark = true) {
                AzkarWindow(ui, c.features, ControllerActions(c) { Instant.parse("2026-09-16T06:01:00Z") })
            }
        }
        onNodeWithText("Done").assertIsDisplayed()
        onNodeWithText("Next zikr in 2:50").assertIsDisplayed()
        onNodeWithTag("restart:Morning azkar").performClick()
        assertEquals(0, c.state.sabah, "the morning list starts again")
    }
}
