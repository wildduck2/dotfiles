// azkar.json: the morning, evening and general lists.
package com.wildduck.azkar.core

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

/** One zikr. `count` may be omitted in azkar.json (defaults to 1); `note` and `ref` are optional. */
@Serializable
data class Zikr(val text: String, val count: Int = 1, val note: String? = null, val ref: Int? = null)

/** Any of the three lists may be omitted. */
@Serializable
data class Library(
    val sabah: List<Zikr> = emptyList(),
    val masaa: List<Zikr> = emptyList(),
    val general: List<Zikr> = emptyList(),
) {
    companion object {
        // Like Swift's JSONDecoder: unknown keys are ignored, and null counts as missing.
        private val json = Json {
            ignoreUnknownKeys = true
            coerceInputValues = true
        }

        fun decode(text: String): Library =
            try {
                json.decodeFromString(Library.serializer(), text)
            } catch (e: SerializationException) {
                throw ConfigError(e.message ?: "not a valid azkar.json")
            }
    }
}
