package com.wildduck.azkar.app

import androidx.compose.ui.input.key.Key
import com.wildduck.azkar.core.Hotkey
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class KeyNamesTest {
    @Test
    fun everyShortcutKeyHasAKey() {
        assertEquals(Hotkey.keys.toSet(), KeyNames.names.values.toSet(), "every key a shortcut can use is mapped")
        assertEquals(Hotkey.keys.size, KeyNames.names.size, "and no two keys share a name")
    }

    @Test
    fun aRecordedKeyPress() {
        assertEquals(
            "ctrl+alt+z",
            KeyNames.hotkey(Key.Z, ctrl = true, alt = true, shift = false, meta = false)?.spec,
            "a recorded key press becomes the same hotkey as its spec",
        )
        assertEquals(
            "shift+cmd+f5",
            KeyNames.hotkey(Key.F5, ctrl = false, alt = false, shift = true, meta = true)?.spec,
            "with every modifier that was held down",
        )
        assertEquals(
            "ctrl+space",
            KeyNames.hotkey(Key.Spacebar, ctrl = true, alt = false, shift = false, meta = false)?.spec,
            "and the config.json name of the key",
        )
        assertNull(
            KeyNames.hotkey(Key.Z, ctrl = false, alt = false, shift = false, meta = false),
            "a recorded key press needs a modifier",
        )
        assertNull(
            KeyNames.hotkey(Key.CapsLock, ctrl = true, alt = true, shift = false, meta = false),
            "unknown key code",
        )
    }
}
