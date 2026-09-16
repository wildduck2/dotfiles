// The sound a new card makes.
package com.wildduck.azkar.desktop

import javax.sound.sampled.AudioFormat
import javax.sound.sampled.AudioSystem
import kotlin.math.PI
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sin

object Chime {
    private const val RATE = 44100

    /** A card appeared. */
    fun card() {
        play(tone(784.0, 70, 0.28) + tone(1046.0, 90, 0.22))
    }

    /** A zikr's count is finished. */
    fun done() {
        play(tone(1046.0, 60, 0.24) + tone(1568.0, 110, 0.20))
    }

    /** 16-bit mono samples, faded in and out so there is no click at either end. */
    fun tone(hz: Double, milliseconds: Int, volume: Double): ByteArray {
        val samples = RATE * milliseconds / 1000
        val ramp = (RATE * 0.005).roundToInt().coerceAtMost(samples / 2)
        val bytes = ByteArray(samples * 2)
        for (i in 0 until samples) {
            val fade = if (ramp == 0) 1.0 else min(1.0, min(i, samples - 1 - i).toDouble() / ramp)
            val value = (sin(2 * PI * hz * i / RATE) * volume * fade * Short.MAX_VALUE).roundToInt().toShort()
            bytes[2 * i] = (value.toInt() and 0xFF).toByte()
            bytes[2 * i + 1] = (value.toInt() shr 8 and 0xFF).toByte()
        }
        return bytes
    }

    /** Plays the samples, or says nothing at all if this machine has no way to. */
    fun play(samples: ByteArray) {
        val format = AudioFormat(RATE.toFloat(), 16, 1, true, false)
        try {
            AudioSystem.getSourceDataLine(format).apply {
                open(format)
                start()
                write(samples, 0, samples.size)
                drain()
                close()
            }
        } catch (_: Exception) {
            // No sound card, no mixer, or the line is busy: a missing chime is not worth an error.
        }
    }
}
