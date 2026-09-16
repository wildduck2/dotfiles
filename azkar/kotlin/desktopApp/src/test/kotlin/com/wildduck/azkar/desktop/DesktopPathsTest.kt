package com.wildduck.azkar.desktop

import kotlin.io.path.Path
import kotlin.test.Test
import kotlin.test.assertEquals

class DesktopPathsTest {
    @Test
    fun whichDesktop() {
        assertEquals(Os.Windows, osFrom("Windows 11"), "Windows")
        assertEquals(Os.MacOS, osFrom("Mac OS X"), "macOS")
        assertEquals(Os.Linux, osFrom("Linux"), "Linux")
        assertEquals(Os.Linux, osFrom("FreeBSD"), "anything else is treated as Linux")
    }

    @Test
    fun linuxFollowsXdg() {
        val home = Path("/home/wd")
        val plain = DesktopPaths(Os.Linux, emptyMap(), home)
        assertEquals(Path("/home/wd/.config/azkar/config.json"), plain.configFile, "config.json")
        assertEquals(Path("/home/wd/.config/azkar/azkar.json"), plain.azkarFile, "azkar.json")
        assertEquals(Path("/home/wd/.local/state/azkar/state.json"), plain.stateFile, "state.json")

        val xdg = DesktopPaths(
            Os.Linux,
            mapOf("XDG_CONFIG_HOME" to "/tmp/cfg", "XDG_STATE_HOME" to "/tmp/state"),
            home,
        )
        assertEquals(Path("/tmp/cfg/azkar/config.json"), xdg.configFile, "XDG_CONFIG_HOME is used")
        assertEquals(Path("/tmp/state/azkar/state.json"), xdg.stateFile, "XDG_STATE_HOME is used")

        val relative = DesktopPaths(Os.Linux, mapOf("XDG_CONFIG_HOME" to "cfg"), home)
        assertEquals(
            Path("/home/wd/.config/azkar/config.json"),
            relative.configFile,
            "a relative XDG path is not a path at all",
        )
    }

    @Test
    fun windowsUsesAppData() {
        val home = Path("C:\\Users\\wd")
        val env = mapOf(
            "APPDATA" to "C:\\Users\\wd\\AppData\\Roaming",
            "LOCALAPPDATA" to "C:\\Users\\wd\\AppData\\Local",
        )
        // Windows paths on this machine keep its own separator, so compare the text.
        val sep = java.io.File.separator
        val paths = DesktopPaths(Os.Windows, env, home)
        assertEquals(
            "C:\\Users\\wd\\AppData\\Roaming${sep}azkar${sep}config.json",
            paths.configFile.toString(),
            "config.json",
        )
        assertEquals(
            "C:\\Users\\wd\\AppData\\Local${sep}azkar${sep}state.json",
            paths.stateFile.toString(),
            "state.json",
        )
        assertEquals(
            "C:\\Users\\wd${sep}AppData${sep}Roaming${sep}azkar${sep}azkar.json",
            DesktopPaths(Os.Windows, emptyMap(), home).azkarFile.toString(),
            "without APPDATA it falls back to the usual place",
        )
    }

    @Test
    fun macOsMatchesTheSwiftApp() {
        val paths = DesktopPaths(Os.MacOS, mapOf("XDG_CONFIG_HOME" to "/tmp/cfg"), Path("/Users/wd"))
        assertEquals(Path("/Users/wd/.config/azkar/config.json"), paths.configFile, "the same config.json")
        assertEquals(Path("/Users/wd/.local/state/azkar/state.json"), paths.stateFile, "and the same state.json")
    }
}
