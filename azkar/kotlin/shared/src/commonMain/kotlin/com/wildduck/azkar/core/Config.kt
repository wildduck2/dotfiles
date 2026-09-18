// config.json: decoding (missing keys keep their defaults) and the canonical form the settings page writes.
package com.wildduck.azkar.core

import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.round
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull

enum class Order(val raw: String) { Random("random"), Sequential("sequential") }

class ConfigError(message: String) : Exception(message)

data class Config(
    val intervalMinutes: Double = 3.0,
    val hotkey: Hotkey = Hotkey(setOf(Modifier.Ctrl, Modifier.Alt), "z"),
    val order: Order = Order.Random,
    /** Off: general azkar are one tap each. On: they keep their full count (e.g. ×100). */
    val repeatGeneral: Boolean = false,
    val maxStack: Int = 5,
    val sabah: TimeWindow? = TimeWindow(5 * 60, 11 * 60),
    val masaa: TimeWindow? = TimeWindow(15 * 60 + 30, 21 * 60),
    val quietHours: TimeWindow? = TimeWindow(23 * 60 + 30, 5 * 60),
    val fontSize: Double = 22.0,
    /** Play a sound when a new card appears. */
    val sound: Boolean = false,
    /** The number of waiting cards next to the menu-bar or tray icon. */
    val showCount: Boolean = true,
    /** Start at login, in the background. */
    val openAtLogin: Boolean = true,
    /** Also open the window when starting at login. */
    val showWindowAtLogin: Boolean = false,
) {
    /** The config.json the settings page writes: the same bytes as Swift's `Config.encode()`. */
    fun encode(): String {
        fun string(s: String) = "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
        fun window(w: TimeWindow?) =
            if (w == null) "null" else "{ \"start\": ${string(formatClock(w.start))}, \"end\": ${string(formatClock(w.end))} }"

        val fields = listOf(
            "intervalMinutes" to formatNumber(intervalMinutes),
            "hotkey" to string(hotkey.spec),
            "order" to string(order.raw),
            "repeatGeneral" to repeatGeneral.toString(),
            "maxStack" to maxStack.toString(),
            "sabah" to window(sabah),
            "masaa" to window(masaa),
            "quietHours" to window(quietHours),
            "fontSize" to formatNumber(fontSize),
            "sound" to sound.toString(),
            "showCount" to showCount.toString(),
            "openAtLogin" to openAtLogin.toString(),
            "showWindowAtLogin" to showWindowAtLogin.toString(),
        )
        return fields.joinToString(",\n", prefix = "{\n", postfix = "\n}\n") { (key, value) -> "  \"$key\": $value" }
    }

    companion object {
        /** Missing keys keep their defaults; `null` disables a time window. Errors use the Swift app's wording. */
        fun decode(text: String): Config {
            val json = try {
                Json.parseToJsonElement(text)
            } catch (e: SerializationException) {
                throw ConfigError("not valid JSON (${e.message?.lineSequence()?.first()})")
            }
            val obj = json as? JsonObject ?: throw ConfigError("must be a JSON object")

            var c = Config()
            obj["intervalMinutes"]?.let { v ->
                val n = v.number()
                if (n == null || n <= 0) throw ConfigError("intervalMinutes must be a number > 0")
                c = c.copy(intervalMinutes = n)
            }
            obj["maxStack"]?.let { v ->
                val n = v.number()
                if (n == null || n != floor(n) || n < 1 || n > Int.MAX_VALUE) {
                    throw ConfigError("maxStack must be a whole number >= 1")
                }
                c = c.copy(maxStack = n.toInt())
            }
            obj["hotkey"]?.let { v ->
                val hotkey = v.string()?.let { Hotkey.parse(it) }
                    ?: throw ConfigError(
                        "hotkey ${(v as? JsonPrimitive)?.content ?: v} is not valid, use e.g. \"ctrl+alt+z\"",
                    )
                c = c.copy(hotkey = hotkey)
            }
            obj["order"]?.let { v ->
                val order = Order.entries.firstOrNull { it.raw == v.string() }
                    ?: throw ConfigError("order must be \"random\" or \"sequential\"")
                c = c.copy(order = order)
            }

            fun switch(key: String, current: Boolean): Boolean {
                val v = obj[key] ?: return current
                return (v as? JsonPrimitive)?.takeUnless { it.isString }?.booleanOrNull
                    ?: throw ConfigError("$key must be true or false")
            }
            c = c.copy(
                repeatGeneral = switch("repeatGeneral", c.repeatGeneral),
                sound = switch("sound", c.sound),
                showCount = switch("showCount", c.showCount),
                openAtLogin = switch("openAtLogin", c.openAtLogin),
                showWindowAtLogin = switch("showWindowAtLogin", c.showWindowAtLogin),
            )

            obj["fontSize"]?.let { v ->
                val n = v.number()
                if (n == null || n <= 0) throw ConfigError("fontSize must be a number > 0")
                c = c.copy(fontSize = n)
            }

            fun window(key: String, current: TimeWindow?): TimeWindow? {
                val v = obj[key] ?: return current
                if (v is JsonNull) return null
                val w = v as? JsonObject
                val start = w?.get("start")?.string()?.let(::parseClock)
                val end = w?.get("end")?.string()?.let(::parseClock)
                if (start == null || end == null) {
                    throw ConfigError("$key must be null or {\"start\": \"HH:mm\", \"end\": \"HH:mm\"}")
                }
                return TimeWindow(start, end)
            }
            return c.copy(
                sabah = window("sabah", c.sabah),
                masaa = window("masaa", c.masaa),
                quietHours = window("quietHours", c.quietHours),
            )
        }
    }
}

// The JSON number grammar. kotlinx.serialization also reads unquoted words (`abc`, `Infinity`, `3d`) as values,
// which Swift's JSONSerialization rejects.
private val jsonNumber = Regex("""-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?""")

/** A JSON number as a Double; null for booleans, strings, null and anything else. */
private fun JsonElement.number(): Double? =
    (this as? JsonPrimitive)?.takeIf { !it.isString && jsonNumber.matches(it.content) }?.content?.toDouble()

private fun JsonElement.string(): String? = (this as? JsonPrimitive)?.takeIf { it.isString }?.content

/** A number as Swift's `Config.encode()` writes it: whole numbers below 1e15 as integers, others as `String(n)`. */
private fun formatNumber(n: Double): String =
    if (n == round(n) && abs(n) < 1e15) n.toLong().toString() else swiftDescription(n)

/**
 * Swift's `String(n)` for a Double: the shortest digits that read back as `n`, as a plain decimal ("0.0001",
 * "1000000000000000.0"), or with an exponent below 1e-4 or above 2^53 ("1e-05", "1.25e+16").
 */
private fun swiftDescription(n: Double): String {
    if (n.isNaN()) return "nan"
    if (n.isInfinite()) return if (n > 0) "inf" else "-inf"
    // Kotlin prints the same shortest digits, laid out differently: "0.5", "1.0E-4", "1.23456785E7".
    val text = abs(n).toString()
    val mantissa = text.substringBefore('E').substringBefore('e')
    val shift = text.substringAfter('E', text.substringAfter('e', "0")).toInt()
    val whole = mantissa.substringBefore('.')
    val all = whole + mantissa.substringAfter('.', "")
    val digits = all.trimStart('0').trimEnd('0')
    // n = d.ddd × 10^exponent
    val exponent = whole.length - (all.length - all.trimStart('0').length) - 1 + shift
    val body = when {
        abs(n) > 9007199254740992.0 || exponent < -4 -> {
            val fraction = digits.drop(1)
            digits.take(1) + (if (fraction.isEmpty()) "" else ".$fraction") +
                "e" + (if (exponent < 0) "-" else "+") + abs(exponent).toString().padStart(2, '0')
        }
        exponent < 0 -> "0." + "0".repeat(-exponent - 1) + digits
        else -> digits.take(exponent + 1).padEnd(exponent + 1, '0') + "." + digits.drop(exponent + 1).ifEmpty { "0" }
    }
    return (if (n < 0) "-" else "") + body
}
