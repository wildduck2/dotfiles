package com.wildduck.azkar.desktop

import kotlin.io.path.createTempDirectory
import kotlin.io.path.deleteRecursively
import kotlin.io.path.exists
import kotlin.io.path.readText
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class AutostartTest {
    private val dir = createTempDirectory("azkar-autostart")

    @AfterTest
    fun cleanUp() {
        @OptIn(kotlin.io.path.ExperimentalPathApi::class)
        dir.deleteRecursively()
    }

    @Test
    fun theAutostartEntry() {
        val text = desktopEntry("/opt/azkar/bin/azkar", background = true)
        assertTrue("[Desktop Entry]" in text, "a desktop entry")
        assertTrue("Exec=/opt/azkar/bin/azkar --background" in text, "starts the app in the background: $text")
        assertTrue("X-GNOME-Autostart-enabled=true" in text, "and GNOME keeps it enabled")
        assertTrue("Name=Azkar" in text, "under its own name")
    }

    @Test
    fun theMenuEntry() {
        val text = desktopEntry("/opt/azkar/bin/azkar", background = false)
        assertTrue("Exec=/opt/azkar/bin/azkar" in text, "opens the window")
        assertTrue("--background" !in text, "not in the background")
        assertTrue("Categories=Utility;" in text, "in the utilities menu")
    }

    @Test
    fun switchingItOnAndOff() {
        val paths = DesktopPaths(Os.Linux, mapOf("XDG_CONFIG_HOME" to "$dir/cfg"), dir)
        val autostart = LinuxAutostart(paths, "/opt/azkar/bin/azkar")
        val entry = paths.configDir.parent.resolve("autostart/com.wildduck.azkar.desktop")

        assertTrue(!autostart.isEnabled(), "off until it is switched on")
        assertNull(autostart.set(true), "switching it on works")
        assertTrue(entry.exists(), "the autostart entry is there")
        assertTrue("--background" in entry.readText(), "and starts Azkar quietly")
        assertTrue(autostart.isEnabled(), "which counts as on")

        assertNull(autostart.set(false), "switching it off works")
        assertTrue(!entry.exists(), "and takes the entry away")
        assertTrue(!autostart.isEnabled(), "off again")
    }

    @Test
    fun theMenuEntryIsWrittenOnce() {
        val paths = DesktopPaths(Os.Linux, mapOf("XDG_DATA_HOME" to "$dir/data"), dir)
        val menu = LinuxAutostart(paths, "/opt/azkar/bin/azkar").installMenuEntry()
        assertEquals(paths.dataDir.resolve("applications/com.wildduck.azkar.desktop"), menu, "in the menu folder")
        assertTrue("Exec=/opt/azkar/bin/azkar" in menu!!.readText(), "pointing at the app")
    }

    @Test
    fun theWindowsRunValue() {
        assertEquals(
            "\"C:\\Program Files\\Azkar\\Azkar.exe\" --background",
            windowsRunValue("C:\\Program Files\\Azkar\\Azkar.exe"),
            "quoted, so the spaces in Program Files don't split the command",
        )
    }

    @Test
    fun aSystemInstallAlreadyHasItsMenuEntry() {
        assertTrue(installedSystemWide("/usr/bin/azkar"), "installed from a .deb")
        assertTrue(installedSystemWide("/opt/azkar/bin/azkar"), "where jpackage puts it")
        assertTrue(
            !installedSystemWide("/home/wildduck/Apps/azkar/bin/azkar"),
            "a folder you unzipped yourself needs its own menu entry",
        )
        assertTrue(!installedSystemWide("azkar"), "and so does a plain development run")
    }
}
