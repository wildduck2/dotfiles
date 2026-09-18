// state.json: today's progress, in the shape the macOS app writes it.
package com.wildduck.azkar.app

import com.wildduck.azkar.core.AppState
import kotlinx.serialization.SerializationException
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

/** Today's progress as it sits in a file — state.json, and inside each reminder of plan.json. */
@Serializable
internal data class StoredState(
    val day: String = "",
    val sabah: Int = 0,
    val masaa: Int = 0,
    val general: Int = 0,
    val lastGeneral: Int? = null,
    val paused: Boolean = false,
)

internal fun AppState.stored(): StoredState = StoredState(
    day = day,
    sabah = sabah,
    masaa = masaa,
    general = general,
    lastGeneral = lastGeneral,
    paused = paused,
)

internal fun StoredState.state(): AppState = AppState(
    day = day,
    sabah = sabah,
    masaa = masaa,
    general = general,
    lastGeneral = lastGeneral,
    paused = paused,
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
            text?.let { json.decodeFromString(StoredState.serializer(), it) }
        } catch (_: SerializationException) {
            null
        } ?: return AppState()
        return stored.state()
    }

    fun encode(state: AppState): String = json.encodeToString(StoredState.serializer(), state.stored())
}
