package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.AzkarController
import com.wildduck.azkar.app.CardStack
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.Storage
import com.wildduck.azkar.core.Card
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlin.time.Duration.Companion.seconds
import kotlin.time.Instant
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant

private const val AZKAR =
    """{"sabah":[{"text":"s1"},{"text":"s2"},{"text":"s3"}],"masaa":[],"general":[{"text":"g1"}]}"""

private class FakeStorage(
    var config: String? = null,
    var azkar: String? = AZKAR,
    var state: String? = null,
) : Storage {
    var version = 0

    override fun readConfig(): String? = config

    override fun writeConfig(text: String) {
        config = text
        version += 1
    }

    override fun readAzkar(): String? = azkar

    override fun readState(): String? = state

    override fun writeState(text: String) {
        state = text
    }

    override fun stamp(): Any = version
}

/** A loop on a clock we move by hand, so a whole day of reminders takes no time at all. */
private class Fixture(config: String? = """{"intervalMinutes": 3}""", locked: Boolean = false) {
    val storage = FakeStorage(config = config)
    val controller = AzkarController(storage, Features.linux) { TimeZone.UTC }
    val stack = CardStack()
    val chimed = mutableListOf<Card>()
    var locked = locked
    var clock: Instant = LocalDateTime(2026, 9, 15, 6, 0).toInstant(TimeZone.UTC)
    val loop = Loop(
        controller = controller,
        stack = stack,
        now = { clock },
        timeZone = { TimeZone.UTC },
        locked = { this.locked },
        onCard = { chimed += it },
    )

    /** One second per tick, as the real app runs. */
    fun run(seconds: Int) = repeat(seconds) {
        clock += 1.seconds
        loop.tick()
    }
}

class LoopTest {
    @Test
    fun theFirstReminderComesRightAfterLaunch() {
        val f = Fixture()
        f.run(4)
        assertEquals(0, f.stack.count, "nothing in the first seconds")
        f.run(1)
        assertEquals(1, f.stack.count, "the first card, five seconds in")
        assertEquals(1, f.chimed.size, "and a chime with it")
    }

    @Test
    fun thenOneEveryInterval() {
        val f = Fixture()
        f.run(5)
        f.run(179)
        assertEquals(1, f.stack.count, "still the first card, just before the interval is up")
        f.run(1)
        assertEquals(2, f.stack.count, "the second card, three minutes later")
    }

    @Test
    fun theStatusCountsDownEverySecond() {
        val f = Fixture()
        f.run(5)
        assertEquals(180, f.controller.ui.value.nextIn, "three minutes to the next card")
        assertEquals(1, f.controller.ui.value.onScreen, "one card on screen")
        f.run(10)
        assertEquals(170, f.controller.ui.value.nextIn, "ten seconds closer")
        assertNull(f.controller.ui.value.lastSkip, "nothing has been skipped")
    }

    @Test
    fun aFullStackIsSkippedAndSaysWhy() {
        val f = Fixture(config = """{"intervalMinutes": 3, "maxStack": 1}""")
        f.run(5 + 180)
        assertEquals(1, f.stack.count, "the one card stays on its own")
        assertEquals("stack full", f.controller.ui.value.lastSkip, "and the menu says why")
        f.stack.dismissAll()
        f.run(180)
        assertEquals(1, f.stack.count, "with the screen clear the next card comes")
        assertNull(f.controller.ui.value.lastSkip, "and nothing is skipped any more")
    }

    @Test
    fun quietHoursAndALockedScreenAreSkipped() {
        val quiet = Fixture(config = """{"intervalMinutes": 3, "quietHours": {"start": "05:00", "end": "07:00"}}""")
        quiet.run(5)
        assertEquals(0, quiet.stack.count, "no cards in the quiet hours")
        assertEquals("quiet hours", quiet.controller.ui.value.lastSkip, "and the menu says why")

        val locked = Fixture(locked = true)
        locked.run(5)
        assertEquals(0, locked.stack.count, "no cards while the screen is locked")
        assertEquals("screen locked", locked.controller.ui.value.lastSkip, "and the menu says why")
    }

    @Test
    fun pausingStopsTheCardsAndResumingStartsTheWaitAgain() {
        val f = Fixture()
        f.loop.setPaused(true)
        f.run(5)
        assertEquals(0, f.stack.count, "paused: no cards")
        assertNull(f.controller.ui.value.nextIn, "and nothing is coming")
        assertTrue(f.controller.state.paused, "the pause is saved for the next launch")
        f.loop.setPaused(false)
        f.run(179)
        assertEquals(0, f.stack.count, "resuming waits a whole interval")
        f.run(1)
        assertEquals(1, f.stack.count, "then the cards come back")
    }

    @Test
    fun theFilesAreReloadedEveryOtherTick() {
        val f = Fixture()
        f.storage.config = """{"intervalMinutes": 9}"""
        f.storage.version += 1
        f.run(1)
        assertEquals(3.0, f.controller.ui.value.config.intervalMinutes, "the files aren't read every second")
        f.run(1)
        assertEquals(9.0, f.controller.ui.value.config.intervalMinutes, "an edit is picked up within two seconds")
    }

    @Test
    fun showNowShowsACardAndStartsTheWaitAgain() {
        val f = Fixture()
        f.run(2)
        assertTrue(f.loop.showNow(), "a card on demand")
        assertEquals(1, f.stack.count, "there it is")
        f.run(5)
        assertEquals(1, f.stack.count, "and the reminder that was due is pushed back")
        assertEquals(175, f.controller.ui.value.nextIn, "the full interval, from the card we just asked for")
    }

    @Test
    fun showNowSaysWhenThereIsNothingToShow() {
        val f = Fixture()
        f.storage.azkar = """{"sabah": [], "masaa": [], "general": []}"""
        f.storage.version += 1
        f.controller.reload()
        assertTrue(!f.loop.showNow(), "an empty azkar.json has nothing to show")
    }
}
