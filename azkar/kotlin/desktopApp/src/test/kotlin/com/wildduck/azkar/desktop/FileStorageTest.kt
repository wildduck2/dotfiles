package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.StateFile
import com.wildduck.azkar.core.AppState
import com.wildduck.azkar.core.Config
import com.wildduck.azkar.core.Library
import kotlin.io.path.createDirectories
import kotlin.io.path.createTempDirectory
import kotlin.io.path.deleteRecursively
import kotlin.io.path.readText
import kotlin.io.path.writeText
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class FileStorageTest {
    private val dir = createTempDirectory("azkar-files")
    private val paths = DesktopPaths(Os.Linux, mapOf("XDG_CONFIG_HOME" to "$dir/cfg", "XDG_STATE_HOME" to "$dir/state"), dir)

    @AfterTest
    fun cleanUp() {
        @OptIn(kotlin.io.path.ExperimentalPathApi::class)
        dir.deleteRecursively()
    }

    @Test
    fun theFirstRunWritesTheAzkarThatShipWithTheApp() {
        val storage = FileStorage(paths) { """{"general":[{"text":"g"}]}""" }
        assertNull(storage.readConfig(), "no config.json until something is saved")
        assertEquals("""{"general":[{"text":"g"}]}""", storage.readAzkar(), "the bundled azkar")
        assertEquals(
            """{"general":[{"text":"g"}]}""",
            paths.azkarFile.readText(),
            "written where they can be edited",
        )
    }

    @Test
    fun theAzkarThatShipWithTheApp() {
        val text = assertNotNull(Bundled.azkar(), "azkar.json is packaged with the app")
        val library = Library.decode(text)
        assertTrue(library.sabah.size > 10, "the morning list is there: ${library.sabah.size} azkar")
        assertTrue(library.masaa.isNotEmpty() && library.general.isNotEmpty(), "and so are the other two")
    }

    @Test
    fun savingAndReadingBack() {
        val storage = FileStorage(paths) { null }
        storage.writeConfig(Config(intervalMinutes = 4.0).encode())
        assertEquals(4.0, Config.decode(paths.configFile.readText()).intervalMinutes, "config.json is written")
        storage.writeState(StateFile.encode(AppState(day = "2026-09-16", sabah = 2)))
        assertEquals(2, StateFile.decode(storage.readState()).sabah, "state.json is written and read back")
        assertEquals(
            Config(intervalMinutes = 4.0).encode(),
            storage.readConfig(),
            "and the config comes back byte for byte",
        )
    }

    @Test
    fun theStampChangesWhenAFileDoes() {
        val storage = FileStorage(paths) { null }
        val empty = storage.stamp()
        paths.configFile.parent.createDirectories()
        paths.configFile.writeText("{}")
        assertTrue(storage.stamp() != empty, "a new config.json is a change")
        val written = storage.stamp()
        assertEquals(written, storage.stamp(), "and nothing changes on its own")
        paths.azkarFile.writeText("""{"general":[]}""")
        assertTrue(storage.stamp() != written, "so is a new azkar.json")
    }

    @Test
    fun aFolderItCannotWriteToIsReported() {
        // A plain file where the folder should be: no OS makes a directory inside one of those.
        val blocker = dir.resolve("not-a-folder")
        blocker.writeText("")
        val problems = mutableListOf<String>()
        val blocked = DesktopPaths(Os.Linux, mapOf("XDG_CONFIG_HOME" to blocker.toString()), dir)
        val storage = FileStorage(blocked, onProblem = { problems += it }) { null }
        storage.writeConfig("{}")
        assertEquals(1, problems.size, "the app says so instead of falling over: $problems")
        assertTrue("config.json" in problems[0], "and which file it was: ${problems[0]}")
    }
}
