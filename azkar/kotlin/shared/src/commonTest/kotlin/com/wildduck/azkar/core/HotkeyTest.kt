package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class HotkeyTest {
    @Test
    fun parsesTheDefaultShortcut() {
        val hk = Hotkey.parse("ctrl+alt+z")
        assertEquals("z", hk?.key, "ctrl+alt+z key")
        assertEquals(setOf(Modifier.Ctrl, Modifier.Alt), hk?.modifiers, "ctrl+alt+z modifiers")
        assertEquals("⌃⌥Z", hk?.display(KeyStyle.Apple), "ctrl+alt+z display")
    }

    @Test
    fun modifierNamesAndAliases() {
        assertEquals(
            setOf(Modifier.Shift, Modifier.Cmd),
            Hotkey.parse("Command+Shift+1")?.modifiers,
            "modifier names are case-insensitive",
        )
        assertEquals("space", Hotkey.parse("cmd+opt+control+space")?.key, "aliases and named keys")
        assertEquals("ctrl+z", Hotkey.parse(" ctrl ++ z ")?.spec, "spaces and empty parts are ignored")
    }

    @Test
    fun rejectsIncompleteShortcuts() {
        assertNull(Hotkey.parse("z"), "a hotkey needs a modifier")
        assertNull(Hotkey.parse("ctrl+foo"), "unknown key")
        assertNull(Hotkey.parse("ctrl+alt"), "a hotkey needs a key")
        assertNull(Hotkey.parse("ctrl+z+x"), "only one key")
    }

    @Test
    fun specIsNormalized() {
        assertEquals("shift+cmd+1", Hotkey.parse("Command+Shift+1")?.spec, "spec is normalized, in display order")
        assertEquals("ctrl+alt+z", Hotkey.parse("ctrl+alt+z")?.spec, "default spec")
    }

    @Test
    fun everyKeyParsesAndRoundTrips() {
        assertEquals(64, Hotkey.keys.size, "the same 64 keys as the macOS app")
        for (name in Hotkey.keys) {
            val h = Hotkey.parse("ctrl+$name")
            assertEquals(name, h?.key, "key for '$name'")
            assertEquals(h, h?.let { Hotkey.parse(it.spec) }, "spec round-trips for '$name'")
        }
    }

    @Test
    fun displayStyles() {
        assertEquals("Ctrl+Alt+Z", Hotkey.parse("ctrl+alt+z")?.display(KeyStyle.Windows), "Windows display")
        assertEquals("Shift+Win+1", Hotkey.parse("cmd+shift+1")?.display(KeyStyle.Windows), "cmd is the Windows key")
        assertEquals("Shift+Super+1", Hotkey.parse("cmd+shift+1")?.display(KeyStyle.Linux), "cmd is Super on Linux")
        assertEquals("Ctrl+Enter", Hotkey.parse("ctrl+return")?.display(KeyStyle.Linux), "named keys on Windows/Linux")
        assertEquals("⌃↩", Hotkey.parse("ctrl+return")?.display(KeyStyle.Apple), "named keys on Apple")
        assertEquals("⌘F5", Hotkey.parse("cmd+f5")?.display(KeyStyle.Apple), "function keys")
    }
}
