// The three files, in the app's own storage: on a phone nothing else can reach them.
package com.wildduck.azkar.android

import android.content.Context
import com.wildduck.azkar.app.Storage
import java.io.File
import java.io.IOException

private const val CONFIG = "config.json"
private const val AZKAR = "azkar.json"
private const val STATE = "state.json"

/**
 * config.json, azkar.json and state.json, laid out as they are on the desktop so the same code reads them.
 * The azkar that ship in the app are copied out the first time it runs.
 */
class AndroidStorage(
    private val context: Context,
    private val onProblem: (String) -> Unit = {},
) : Storage {
    override fun readConfig(): String? = read(CONFIG)

    override fun writeConfig(text: String) = write(CONFIG, text)

    override fun readAzkar(): String? {
        read(AZKAR)?.let { return it }
        val bundled = try {
            context.assets.open(AZKAR).use { it.readBytes().decodeToString() }
        } catch (e: IOException) {
            onProblem("the azkar that ship with the app could not be read: ${e.message ?: "unreadable"}")
            return null
        }
        write(AZKAR, bundled)
        return bundled
    }

    override fun readState(): String? = read(STATE)

    override fun writeState(text: String) = write(STATE, text)

    override fun stamp(): Any = listOf(CONFIG, AZKAR).map { name ->
        file(name).let { if (it.exists()) "${it.lastModified()}:${it.length()}" else "" }
    }

    private fun file(name: String) = File(context.filesDir, name)

    private fun read(name: String): String? = try {
        file(name).takeIf { it.exists() }?.readText()
    } catch (e: IOException) {
        onProblem("$name could not be read: ${e.message ?: "unreadable"}")
        null
    }

    /** Through a temporary file, so being killed halfway can't leave half a file behind. */
    private fun write(name: String, text: String) {
        try {
            val temp = File.createTempFile(name, ".tmp", context.filesDir)
            temp.writeText(text)
            if (!temp.renameTo(file(name))) {
                file(name).writeText(text)
                temp.delete()
            }
        } catch (e: IOException) {
            onProblem("$name could not be saved: ${e.message ?: "unwritable"}")
        }
    }
}
