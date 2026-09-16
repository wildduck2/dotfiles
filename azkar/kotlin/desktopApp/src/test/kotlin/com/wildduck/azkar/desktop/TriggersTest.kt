package com.wildduck.azkar.desktop

import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.Modifier
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

private fun key(spec: String) = assertNotNull(Hotkey.parse(spec), "$spec is a shortcut")

class TriggersTest {
    @Test
    fun windows() {
        assertEquals(WindowsTrigger(0x0002 or 0x0001, 0x5A), windowsTrigger(key("ctrl+alt+z")), "ctrl+alt+z")
        assertEquals(WindowsTrigger(0x0004 or 0x0008, 0x74), windowsTrigger(key("shift+cmd+f5")), "the Windows key")
        assertEquals(WindowsTrigger(0x0002, 0x08), windowsTrigger(key("ctrl+delete")), "delete is backspace")
        assertEquals(WindowsTrigger(0x0002, 0xBD), windowsTrigger(key("ctrl+-")), "the punctuation keys")
    }

    @Test
    fun x11() {
        assertEquals(X11Trigger("z", 4 or 8), x11Trigger(key("ctrl+alt+z")), "ctrl+alt+z")
        assertEquals(X11Trigger("F5", 1 or 64), x11Trigger(key("shift+cmd+f5")), "super is Mod4")
        assertEquals(X11Trigger("BackSpace", 4), x11Trigger(key("ctrl+delete")), "delete is BackSpace")
        assertEquals(
            listOf(12, 12 or 2, 12 or 16, 12 or 2 or 16),
            X11Trigger("z", 12).masks,
            "the grab has to cover Caps Lock and Num Lock",
        )
    }

    @Test
    fun portal() {
        assertEquals("CTRL+ALT+z", portalTrigger(key("ctrl+alt+z")), "as the shortcuts specification writes it")
        assertEquals("SHIFT+LOGO+F5", portalTrigger(key("shift+cmd+f5")), "the super key is LOGO")
        assertEquals("CTRL+BackSpace", portalTrigger(key("ctrl+delete")), "delete is BackSpace")
        assertEquals("CTRL+minus", portalTrigger(key("ctrl+-")), "punctuation is named")
        assertEquals("ALT+space", portalTrigger(key("alt+space")), "and so is the space bar")
    }

    @Test
    fun everyShortcutKeyCanBeAskedFor() {
        for (name in Hotkey.keys) {
            val hotkey = Hotkey(setOf(Modifier.Ctrl), name)
            assertNotNull(windowsTrigger(hotkey), "$name has a virtual-key code")
            assertNotNull(x11Trigger(hotkey), "$name has a keysym")
            assertNotNull(portalTrigger(hotkey), "$name can go to the portal")
        }
        val unknown = Hotkey(setOf(Modifier.Ctrl), "hyper")
        assertNull(windowsTrigger(unknown), "and nothing else does")
        assertNull(x11Trigger(unknown), "on any desktop")
        assertNull(portalTrigger(unknown), "at all")
    }
}
