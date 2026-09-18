package com.wildduck.azkar.app

import com.wildduck.azkar.core.AppState
import com.wildduck.azkar.core.Config
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.TimeWindow
import com.wildduck.azkar.core.firstIndex
import com.wildduck.azkar.core.instant
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.datetime.TimeZone

/** The fixture library as it is written in azkar.json. */
private const val AZKAR_JSON =
    """{"sabah":[{"text":"s1"},{"text":"s2"},{"text":"s3"}],"masaa":[{"text":"m1"},{"text":"m2"}],""" +
        """"general":[{"text":"g1"},{"text":"g2"},{"text":"g3"}]}"""

private class FakeStorage(
    var config: String? = null,
    var azkar: String? = AZKAR_JSON,
    var state: String? = null,
) : Storage {
    var version = 0
    var configWrites = 0

    override fun readConfig(): String? = config

    override fun writeConfig(text: String) {
        config = text
        configWrites += 1
        // Writing the file changes its timestamp, as it does on disk.
        version += 1
    }

    override fun readAzkar(): String? = azkar

    override fun readState(): String? = state

    override fun writeState(text: String) {
        state = text
    }

    override fun stamp(): Any = version
}

private fun controller(storage: Storage) = AzkarController(storage, Features.linux) { TimeZone.UTC }

class AzkarControllerTest {
    @Test
    fun startsFromTheFilesOnDisk() {
        val storage = FakeStorage(config = """{"intervalMinutes": 5}""", state = """{"day":"2026-09-14","sabah":1}""")
        val c = controller(storage)
        assertEquals(5.0, c.ui.value.config.intervalMinutes, "config.json is read at startup")
        assertEquals(3, c.ui.value.library.sabah.size, "azkar.json is read at startup")
        assertEquals(1, c.state.sabah, "state.json is read at startup")
        assertEquals(emptyList(), c.ui.value.problems, "nothing to report")
    }

    @Test
    fun aBrokenFileKeepsTheLastGoodVersion() {
        val storage = FakeStorage(config = """{"intervalMinutes": 5}""")
        val c = controller(storage)
        storage.config = """{"intervalMinutes": true}"""
        storage.version += 1
        c.reload()
        assertEquals(5.0, c.ui.value.config.intervalMinutes, "a broken config keeps the last good one")
        assertTrue(
            c.ui.value.problems.any { "config.json" in it.text && "intervalMinutes" in it.text },
            "the broken config is reported: ${c.ui.value.problems}",
        )
        storage.azkar = "{nope"
        storage.version += 1
        c.reload()
        assertEquals(3, c.ui.value.library.sabah.size, "a broken azkar.json keeps the last good list")
        assertTrue(c.ui.value.problems.any { "azkar.json" in it.text }, "the broken list is reported")

        storage.config = """{"intervalMinutes": 6}"""
        storage.azkar = AZKAR_JSON
        storage.version += 1
        c.reload()
        assertEquals(6.0, c.ui.value.config.intervalMinutes, "a fixed file is picked up")
        assertEquals(emptyList(), c.ui.value.problems, "and its problem is gone")
    }

    @Test
    fun reloadOnlyReadsWhenSomethingChanged() {
        val storage = FakeStorage()
        val c = controller(storage)
        assertTrue(!c.reload(), "nothing changed on disk")
        storage.version += 1
        assertTrue(c.reload(), "the files changed")
    }

    @Test
    fun savingConfigWritesTheFile() {
        val storage = FakeStorage()
        val c = controller(storage)
        c.setConfig(Config(intervalMinutes = 7.0, masaa = null))
        assertEquals(1, storage.configWrites, "the config is written once")
        assertEquals(Config(intervalMinutes = 7.0, masaa = null).encode(), storage.config, "written as the app writes it")
        assertEquals(7.0, c.ui.value.config.intervalMinutes, "and shown in the window")
        assertTrue(!c.reload(), "our own write is not a change to reload")
    }

    @Test
    fun pickingACardAdvancesAndSavesTheState() {
        val storage = FakeStorage()
        val c = controller(storage)
        val first = c.pick(instant(14, 6, 0), random = firstIndex)
        assertEquals("s1", first?.zikr?.text, "the morning list starts at its first zikr")
        assertEquals(1, c.state.sabah, "the state moves on")
        assertEquals(1, StateFile.decode(storage.state).sabah, "and is saved for the next launch")
        assertEquals("s2", c.pick(instant(14, 6, 3), random = firstIndex)?.zikr?.text, "then the second")
        assertNull(
            controller(FakeStorage(azkar = """{"general": []}""")).pick(instant(14, 13, 0), random = firstIndex),
            "nothing to show",
        )
    }

    @Test
    fun pauseAndRestart() {
        val storage = FakeStorage()
        val c = controller(storage)
        c.setPaused(true)
        assertTrue(c.ui.value.paused, "paused")
        assertTrue(StateFile.decode(storage.state).paused, "the pause is saved")
        c.setPaused(false)
        c.pick(instant(14, 6, 0), random = firstIndex)
        c.pick(instant(14, 6, 3), random = firstIndex)
        assertEquals(2, c.state.sabah, "two morning azkar done")
        c.restart(Session.Sabah, instant(14, 7, 0))
        assertEquals(0, c.state.sabah, "restart starts today's morning list again")
        c.pick(instant(14, 16, 0), random = firstIndex)
        c.restart(Session.Sabah, instant(15, 7, 0))
        assertEquals(0, c.state.masaa, "a new day clears the evening list too")
        assertEquals("2026-09-15", c.state.day, "and moves the state to today")
    }

    @Test
    fun statusCountsDownToTheNextCard() {
        val c = controller(FakeStorage())
        c.pick(instant(14, 6, 0), random = firstIndex)
        c.setStatus(now = instant(14, 6, 1), nextFire = instant(14, 6, 3), lastSkip = "stack full", onScreen = 2)
        val ui = c.ui.value
        assertEquals(120, ui.nextIn, "seconds until the next card")
        assertEquals("stack full", ui.lastSkip, "why the last tick was skipped")
        assertEquals(2, ui.onScreen, "cards on screen")
        assertEquals(1, ui.sabahDone, "today's morning progress")
        assertEquals(3, ui.sabahTotal, "out of the whole list")
        c.setStatus(now = instant(15, 6, 1), nextFire = instant(15, 6, 3))
        assertEquals(0, c.ui.value.sabahDone, "yesterday's progress is not today's")
        c.setPaused(true)
        c.setStatus(now = instant(15, 6, 1), nextFire = instant(15, 6, 3))
        assertNull(c.ui.value.nextIn, "nothing is coming while paused")
    }

    @Test
    fun problemsAndTheShortcut() {
        val c = controller(FakeStorage())
        c.setProblem(ProblemKey.Shortcut, "⌃⌥Z is taken by another app")
        c.setProblem(ProblemKey.Login, "Open at login: permission denied", ProblemAction.ShowConfigFolder)
        assertEquals(2, c.ui.value.problems.size, "both problems are shown")
        assertEquals(ProblemAction.ShowConfigFolder, c.ui.value.problems.last().action, "with its fix")
        c.setProblem(ProblemKey.Shortcut, null)
        assertEquals(1, c.ui.value.problems.size, "a solved problem disappears")

        c.setShortcut(ShortcutInfo("Ctrl+Alt+Z", ShortcutMode.SystemSettings("Change in System Settings")))
        assertEquals("Ctrl+Alt+Z", c.ui.value.shortcut.display, "the shortcut as the desktop shows it")
        assertEquals(
            ShortcutMode.SystemSettings("Change in System Settings"),
            c.ui.value.shortcut.mode,
            "on Wayland the desktop owns the binding",
        )
    }

    @Test
    fun windowsAreRememberedWhileTheyAreOff() {
        val c = controller(FakeStorage())
        c.setConfig(c.ui.value.config.copy(sabah = TimeWindow(6 * 60, 10 * 60)))
        c.setConfig(c.ui.value.config.copy(sabah = null))
        assertEquals(
            TimeWindow(6 * 60, 10 * 60),
            c.rememberedWindow(WindowKey.Sabah),
            "the times are kept while the window is off",
        )
        assertEquals(
            TimeWindow(15 * 60 + 30, 21 * 60),
            c.rememberedWindow(WindowKey.Masaa),
            "a window that was never switched off falls back to its default",
        )
    }

    @Test
    fun aFreshStateWhenTheStateFileIsBroken() {
        val c = controller(FakeStorage(state = "not json"))
        assertEquals(AppState(), c.state, "an unreadable state.json starts from a fresh state")
    }

    @Test
    fun oneReminderAtATime() {
        val c = controller(FakeStorage(config = """{"intervalMinutes": 3, "maxStack": 2}"""))
        val fired = c.fire(instant(14, 6, 0), onScreen = 0, random = firstIndex)
        assertEquals(
            "s1",
            (fired as? Fired.Show)?.card?.zikr?.text,
            "the next zikr in today's morning list: $fired",
        )
        assertEquals(Fired.Skip("stack full"), c.fire(instant(14, 6, 3), onScreen = 2), "two are already waiting")
        assertEquals(
            Fired.Skip("screen locked"),
            c.fire(instant(14, 6, 3), onScreen = 0, locked = true),
            "not onto a locked screen",
        )
        c.setPaused(true)
        assertEquals(Fired.Skip("paused"), c.fire(instant(14, 6, 3), onScreen = 0), "nothing while paused")
    }

    @Test
    fun theRemindersAheadAreOneIntervalApart() {
        val c = controller(FakeStorage(config = """{"intervalMinutes": 3}"""))
        val plan = c.plan(instant(14, 6, 0), limit = 3)
        assertEquals(3, plan.size, "as many reminders as were asked for")
        assertEquals(instant(14, 6, 3), plan[0].fireAt, "the first one is an interval away")
        assertEquals(listOf("s1", "s2", "s3"), plan.map { it.card.zikr.text }, "today's morning list, in order")
        assertEquals(2, plan[1].state.sabah, "each one carries the state it leaves behind")
        assertEquals(0, c.state.sabah, "planning doesn't move today's progress on by itself")
    }

    @Test
    fun theStateComesFromTheRemindersThatHaveFired() {
        val storage = FakeStorage(config = """{"intervalMinutes": 3}""")
        val c = controller(storage)
        val plan = c.plan(instant(14, 6, 0), limit = 3)

        c.commit(plan, instant(14, 6, 7))
        assertEquals(2, c.state.sabah, "two of the three have fired")
        assertTrue(storage.state.orEmpty().contains(""""sabah":2"""), "and that is saved: ${storage.state}")

        c.commit(emptyList(), instant(14, 6, 20))
        assertEquals(2, c.state.sabah, "no plan, nothing to take from it")
    }

    @Test
    fun quietHoursAndAnEmptyLibraryAreSaidOutLoud() {
        val quiet = controller(FakeStorage(config = """{"quietHours": {"start": "05:00", "end": "07:00"}}"""))
        assertEquals(Fired.Skip("quiet hours"), quiet.fire(instant(14, 6, 0), onScreen = 0), "in the quiet hours")
        val empty = controller(FakeStorage(azkar = """{"sabah": [], "masaa": [], "general": []}"""))
        assertEquals(
            Fired.Skip("nothing to show"),
            empty.fire(instant(14, 6, 0), onScreen = 0),
            "an azkar.json with no azkar in it",
        )
    }
}
