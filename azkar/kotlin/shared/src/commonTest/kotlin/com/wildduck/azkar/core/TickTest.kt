package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals

class TickTest {
    @Test
    fun decisions() {
        assertEquals(
            TickDecision.Show,
            decideTick(paused = false, locked = false, quiet = false, stackCount = 0, maxStack = 5),
            "normal tick shows",
        )
        assertEquals(
            TickDecision.Skip("paused"),
            decideTick(paused = true, locked = false, quiet = false, stackCount = 0, maxStack = 5),
            "paused",
        )
        assertEquals(
            TickDecision.Skip("screen locked"),
            decideTick(paused = false, locked = true, quiet = false, stackCount = 0, maxStack = 5),
            "locked",
        )
        assertEquals(
            TickDecision.Skip("quiet hours"),
            decideTick(paused = false, locked = false, quiet = true, stackCount = 0, maxStack = 5),
            "quiet",
        )
        assertEquals(
            TickDecision.Skip("stack full"),
            decideTick(paused = false, locked = false, quiet = false, stackCount = 5, maxStack = 5),
            "full",
        )
    }
}
