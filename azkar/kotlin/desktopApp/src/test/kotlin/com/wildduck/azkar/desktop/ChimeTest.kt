package com.wildduck.azkar.desktop

import kotlin.math.roundToInt
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ChimeTest {
    @Test
    fun aShortTone() {
        val tone = Chime.tone(880.0, milliseconds = 50, volume = 0.4)
        assertEquals(2 * 44100 * 50 / 1000, tone.size, "16-bit mono samples for 50ms")
        assertEquals(0, tone.first().toInt(), "it fades in, so there is no click")
        assertEquals(0, tone.last().toInt(), "and fades out")
        val peak = tone.toList().chunked(2).maxOf { (low, high) ->
            kotlin.math.abs(((high.toInt() shl 8) or (low.toInt() and 0xFF)).toShort().toInt())
        }
        assertTrue(peak in 1000..(0.4 * Short.MAX_VALUE).roundToInt(), "no louder than asked for: $peak")
    }

    @Test
    fun playingIsSilentWhenThereIsNoSoundCard() {
        // Whatever this machine has, playing must not throw.
        Chime.play(Chime.tone(440.0, 10, 0.2))
    }
}
