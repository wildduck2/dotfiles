// The three files on disk, and opening them the way the desktop does.
package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.Storage
import java.awt.Desktop
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.StandardCopyOption
import kotlin.io.path.createDirectories
import kotlin.io.path.deleteIfExists
import kotlin.io.path.exists
import kotlin.io.path.fileSize
import kotlin.io.path.getLastModifiedTime
import kotlin.io.path.readText

/**
 * Reads and writes config.json, azkar.json and state.json. The first run writes the azkar that ship with
 * the app, so they can be edited like any other file. `onProblem` is told when a write fails — a full disk
 * or a read-only folder shouldn't take the app down with it.
 */
class FileStorage(
    private val paths: DesktopPaths,
    private val onProblem: (String) -> Unit = {},
    private val bundledAzkar: () -> String?,
) : Storage {
    override fun readConfig(): String? = read(paths.configFile)

    override fun writeConfig(text: String) = write(paths.configFile, text)

    override fun readAzkar(): String? {
        read(paths.azkarFile)?.let { return it }
        val bundled = bundledAzkar() ?: return null
        write(paths.azkarFile, bundled)
        return bundled
    }

    override fun readState(): String? = read(paths.stateFile)

    override fun writeState(text: String) = write(paths.stateFile, text)

    /** The timestamp and size of each file that can be edited by hand. */
    override fun stamp(): Any = listOf(paths.configFile, paths.azkarFile).map { file ->
        if (file.exists()) "${file.getLastModifiedTime().toMillis()}:${file.fileSize()}" else ""
    }

    private fun read(file: Path): String? = try {
        if (file.exists()) file.readText() else null
    } catch (e: IOException) {
        onProblem("${file.fileName} could not be read: ${e.message ?: "unreadable"}")
        null
    }

    /** Writes through a temporary file, so a crash can't leave half a file behind. */
    private fun write(file: Path, text: String) {
        try {
            file.parent.createDirectories()
            val temp = Files.createTempFile(file.parent, file.fileName.toString(), ".tmp")
            try {
                Files.writeString(temp, text)
                Files.move(temp, file, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE)
            } catch (e: IOException) {
                temp.deleteIfExists()
                throw e
            }
        } catch (e: Exception) {
            onProblem("${file.fileName} could not be saved: ${e.message ?: e::class.simpleName}")
        }
    }
}

/** What comes packaged inside the app. */
object Bundled {
    /** The azkar the app ships with, used the first time it runs. */
    fun azkar(): String? =
        Bundled::class.java.getResourceAsStream("/azkar.json")?.use { it.readBytes().decodeToString() }
}

/** Opening a file or its folder with whatever the desktop uses for it. */
object Reveal {
    fun file(path: Path): Boolean = desktop { it.open(path.toFile()) } || command(path)

    fun folder(path: Path): Boolean {
        val dir = if (path.exists() && !java.nio.file.Files.isDirectory(path)) path.parent else path
        dir.createDirectories()
        return desktop { it.open(dir.toFile()) } || command(dir)
    }

    private fun desktop(open: (Desktop) -> Unit): Boolean = try {
        if (!Desktop.isDesktopSupported()) return false
        val desktop = Desktop.getDesktop()
        if (!desktop.isSupported(Desktop.Action.OPEN)) return false
        open(desktop)
        true
    } catch (_: Exception) {
        false
    }

    /** Desktop.open goes through xdg-open anyway, but it isn't there in every JDK build. */
    private fun command(path: Path): Boolean = try {
        val opener = when (osFrom(System.getProperty("os.name") ?: "")) {
            Os.Linux -> "xdg-open"
            Os.MacOS -> "open"
            Os.Windows -> "explorer"
        }
        ProcessBuilder(opener, path.toString()).start()
        true
    } catch (_: Exception) {
        false
    }
}
