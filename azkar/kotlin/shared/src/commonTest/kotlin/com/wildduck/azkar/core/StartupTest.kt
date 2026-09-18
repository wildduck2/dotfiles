package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** Whether the window opens when the app starts. */
class StartupTest {
    @Test
    fun windowAtLaunch() {
        assertTrue(opensWindowAtLaunch(listOf("Azkar"), Config()), "opened by hand: the window shows")
        assertFalse(opensWindowAtLaunch(listOf("Azkar", "--background"), Config()), "at login: menu bar only")
        assertTrue(
            opensWindowAtLaunch(listOf("Azkar", "--background"), Config(showWindowAtLogin = true)),
            "at login, if asked: the window shows",
        )
    }
}
