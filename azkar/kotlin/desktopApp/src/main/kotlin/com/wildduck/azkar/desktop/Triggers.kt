// One shortcut, in the three ways a desktop wants to hear it.
package com.wildduck.azkar.desktop

import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.Modifier

/** What `RegisterHotKey` takes: MOD_* flags and a virtual-key code. */
data class WindowsTrigger(val modifiers: Int, val key: Int)

/** What `XGrabKey` takes: a keysym to look up, and a modifier mask. */
data class X11Trigger(val keysym: String, val mask: Int)

fun windowsTrigger(hotkey: Hotkey): WindowsTrigger? {
    val key = virtualKeys[hotkey.key] ?: return null
    var modifiers = 0
    for (modifier in hotkey.modifiers) {
        modifiers = modifiers or when (modifier) {
            Modifier.Alt -> 0x0001 // MOD_ALT
            Modifier.Ctrl -> 0x0002 // MOD_CONTROL
            Modifier.Shift -> 0x0004 // MOD_SHIFT
            Modifier.Cmd -> 0x0008 // MOD_WIN
        }
    }
    return WindowsTrigger(modifiers, key)
}

fun x11Trigger(hotkey: Hotkey): X11Trigger? {
    val keysym = keysyms[hotkey.key] ?: return null
    var mask = 0
    for (modifier in hotkey.modifiers) {
        mask = mask or when (modifier) {
            Modifier.Shift -> 1 shl 0 // ShiftMask
            Modifier.Ctrl -> 1 shl 2 // ControlMask
            Modifier.Alt -> 1 shl 3 // Mod1Mask
            Modifier.Cmd -> 1 shl 6 // Mod4Mask, the Super key
        }
    }
    return X11Trigger(keysym, mask)
}

/** Caps Lock and Num Lock are modifiers too, so a grab has to cover them. */
val X11Trigger.masks: List<Int>
    get() {
        val lock = 1 shl 1 // LockMask, Caps Lock
        val numLock = 1 shl 4 // Mod2Mask, usually Num Lock
        return listOf(mask, mask or lock, mask or numLock, mask or lock or numLock)
    }

/** The trigger the desktop portal takes, as the shortcuts specification writes it: "CTRL+ALT+z". */
fun portalTrigger(hotkey: Hotkey): String? {
    val key = keysyms[hotkey.key] ?: return null
    val modifiers = Modifier.entries.filter { it in hotkey.modifiers }.map {
        when (it) {
            Modifier.Ctrl -> "CTRL"
            Modifier.Alt -> "ALT"
            Modifier.Shift -> "SHIFT"
            Modifier.Cmd -> "LOGO"
        }
    }
    return (modifiers + key).joinToString("+")
}

private val virtualKeys: Map<String, Int> = buildMap {
    for (letter in 'a'..'z') put(letter.toString(), 0x41 + (letter - 'a'))
    for (digit in '0'..'9') put(digit.toString(), 0x30 + (digit - '0'))
    for (n in 1..12) put("f$n", 0x6F + n) // VK_F1 is 0x70
    putAll(
        mapOf(
            "=" to 0xBB, // VK_OEM_PLUS
            "-" to 0xBD, // VK_OEM_MINUS
            "]" to 0xDD, // VK_OEM_6
            "[" to 0xDB, // VK_OEM_4
            "'" to 0xDE, // VK_OEM_7
            ";" to 0xBA, // VK_OEM_1
            "\\" to 0xDC, // VK_OEM_5
            "," to 0xBC, // VK_OEM_COMMA
            "/" to 0xBF, // VK_OEM_2
            "." to 0xBE, // VK_OEM_PERIOD
            "`" to 0xC0, // VK_OEM_3
            "return" to 0x0D,
            "tab" to 0x09,
            "space" to 0x20,
            "delete" to 0x08, // VK_BACK: the key Azkar calls delete, as macOS does
            "escape" to 0x1B,
        ),
    )
}

/** X11 keysym names, which the portal's trigger strings use too. */
private val keysyms: Map<String, String> = buildMap {
    for (letter in 'a'..'z') put(letter.toString(), letter.toString())
    for (digit in '0'..'9') put(digit.toString(), digit.toString())
    for (n in 1..12) put("f$n", "F$n")
    putAll(
        mapOf(
            "=" to "equal",
            "-" to "minus",
            "]" to "bracketright",
            "[" to "bracketleft",
            "'" to "apostrophe",
            ";" to "semicolon",
            "\\" to "backslash",
            "," to "comma",
            "/" to "slash",
            "." to "period",
            "`" to "grave",
            "return" to "Return",
            "tab" to "Tab",
            "space" to "space",
            "delete" to "BackSpace",
            "escape" to "Escape",
        ),
    )
}
