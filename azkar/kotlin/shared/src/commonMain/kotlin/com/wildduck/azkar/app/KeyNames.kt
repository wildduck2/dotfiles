// Compose keys <-> the key names config.json uses.
package com.wildduck.azkar.app

import androidx.compose.ui.input.key.Key
import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.Modifier

object KeyNames {
    /** Every key a shortcut can use, by the Compose key that presses it. */
    val names: Map<Key, String> = mapOf(
        Key.A to "a", Key.B to "b", Key.C to "c", Key.D to "d", Key.E to "e", Key.F to "f",
        Key.G to "g", Key.H to "h", Key.I to "i", Key.J to "j", Key.K to "k", Key.L to "l",
        Key.M to "m", Key.N to "n", Key.O to "o", Key.P to "p", Key.Q to "q", Key.R to "r",
        Key.S to "s", Key.T to "t", Key.U to "u", Key.V to "v", Key.W to "w", Key.X to "x",
        Key.Y to "y", Key.Z to "z",
        Key.Zero to "0", Key.One to "1", Key.Two to "2", Key.Three to "3", Key.Four to "4",
        Key.Five to "5", Key.Six to "6", Key.Seven to "7", Key.Eight to "8", Key.Nine to "9",
        Key.Equals to "=", Key.Minus to "-", Key.RightBracket to "]", Key.LeftBracket to "[",
        Key.Apostrophe to "'", Key.Semicolon to ";", Key.Backslash to "\\", Key.Comma to ",",
        Key.Slash to "/", Key.Period to ".", Key.Grave to "`",
        Key.Enter to "return", Key.Tab to "tab", Key.Spacebar to "space", Key.Backspace to "delete",
        Key.Escape to "escape",
        Key.F1 to "f1", Key.F2 to "f2", Key.F3 to "f3", Key.F4 to "f4", Key.F5 to "f5", Key.F6 to "f6",
        Key.F7 to "f7", Key.F8 to "f8", Key.F9 to "f9", Key.F10 to "f10", Key.F11 to "f11", Key.F12 to "f12",
    )

    /** The shortcut a key press records; null if the key can't be used or nothing was held down with it. */
    fun hotkey(key: Key, ctrl: Boolean, alt: Boolean, shift: Boolean, meta: Boolean): Hotkey? {
        val name = names[key] ?: return null
        val modifiers = buildSet {
            if (ctrl) add(Modifier.Ctrl)
            if (alt) add(Modifier.Alt)
            if (shift) add(Modifier.Shift)
            if (meta) add(Modifier.Cmd)
        }
        if (modifiers.isEmpty()) return null
        return Hotkey(modifiers, name)
    }
}
