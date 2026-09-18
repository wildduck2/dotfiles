package com.wildduck.azkar.core

/** Shortcut modifiers, in the order they are written and displayed. `names[0]` is the one config.json uses. */
enum class Modifier(val names: List<String>, private val symbol: String, private val label: String) {
    Ctrl(listOf("ctrl", "control"), "⌃", "Ctrl"),
    Alt(listOf("alt", "opt", "option"), "⌥", "Alt"),
    Shift(listOf("shift"), "⇧", "Shift"),
    Cmd(listOf("cmd", "command"), "⌘", "Super"),
    ;

    fun display(style: KeyStyle): String = when {
        style == KeyStyle.Apple -> symbol
        this == Cmd && style == KeyStyle.Windows -> "Win"
        else -> label
    }
}

/** How a shortcut is shown: Apple symbols (⌃⌥Z), or key names joined with + (Ctrl+Alt+Z). */
enum class KeyStyle { Apple, Windows, Linux }

/** A global shortcut such as "ctrl+alt+z": one or more modifiers plus one key, by name. */
data class Hotkey(val modifiers: Set<Modifier>, val key: String) {
    /** Canonical "ctrl+alt+z" form, as written to config.json. */
    val spec: String
        get() = (Modifier.entries.filter { it in modifiers }.map { it.names[0] } + key).joinToString("+")

    fun display(style: KeyStyle): String {
        val mods = Modifier.entries.filter { it in modifiers }.map { it.display(style) }
        return if (style == KeyStyle.Apple) {
            mods.joinToString("") + (appleKeyLabels[key] ?: key.uppercase())
        } else {
            (mods + (pcKeyLabels[key] ?: key.uppercase())).joinToString("+")
        }
    }

    companion object {
        /** Every key a shortcut can use: the keys the macOS app has key codes for. */
        val keys: List<String> =
            ('a'..'z').map { it.toString() } + ('0'..'9').map { it.toString() } +
                listOf("=", "-", "]", "[", "'", ";", "\\", ",", "/", ".", "`") +
                listOf("return", "tab", "space", "delete", "escape") + (1..12).map { "f$it" }

        private val appleKeyLabels =
            mapOf("return" to "↩", "tab" to "⇥", "space" to "Space", "delete" to "⌫", "escape" to "⎋")
        private val pcKeyLabels =
            mapOf("return" to "Enter", "tab" to "Tab", "space" to "Space", "delete" to "Backspace", "escape" to "Esc")

        /** Parses "ctrl+alt+z": one or more modifiers plus exactly one key, case-insensitive. */
        fun parse(s: String): Hotkey? {
            val mods = mutableSetOf<Modifier>()
            var key: String? = null
            for (part in s.lowercase().split("+").filter { it.isNotEmpty() }.map { it.trim() }) {
                val modifier = Modifier.entries.firstOrNull { part in it.names }
                when {
                    modifier != null -> mods += modifier
                    key == null && part in keys -> key = part
                    else -> return null
                }
            }
            if (mods.isEmpty() || key == null) return null
            return Hotkey(mods, key)
        }
    }
}
