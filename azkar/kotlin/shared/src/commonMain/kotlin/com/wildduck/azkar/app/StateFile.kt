// state.json: today's progress, in the shape the macOS app writes it.
package com.wildduck.azkar.app

import com.wildduck.azkar.core.AppState
import kotlinx.serialization.SerializationException
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
private data class Stored(
    val day: String = "",
    val sabah: Int = 0,
    val masaa: Int = 0,
    val general: Int = 0,
    val lastGeneral: Int? = null,
    val paused: Boolean = false,
)

object StateFile {
    // Swift's JSONEncoder leaves nil out and writes the keys in any order; null counts as missing.
    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
        explicitNulls = false
        encodeDefaults = true
    }

    /** Progress is not worth an error: anything unreadable starts the day fresh. */
    fun decode(text: String?): AppState {
        val stored = try {
            text?.let { json.decodeFromString(Stored.serializer(), it) }
        } catch (_: SerializationException) {
            null
        } ?: return AppState()
        return AppState(
            day = stored.day,
            sabah = stored.sabah,
            masaa = stored.masaa,
            general = stored.general,
            lastGeneral = stored.lastGeneral,
            paused = stored.paused,
        )
    }

    fun encode(state: AppState): String =
        json.encodeToString(
            Stored.serializer(),
            Stored(
                day = state.day,
                sabah = state.sabah,
                masaa = state.masaa,
                general = state.general,
                lastGeneral = state.lastGeneral,
                paused = state.paused,
            ),
        )
}
