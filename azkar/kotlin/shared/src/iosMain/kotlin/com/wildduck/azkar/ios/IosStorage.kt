// The three files, plus the plan, in the app's own Application Support folder.
package com.wildduck.azkar.ios

import com.wildduck.azkar.app.Storage
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSApplicationSupportDirectory
import platform.Foundation.NSBundle
import platform.Foundation.NSFileManager
import platform.Foundation.NSSearchPathForDirectoriesInDomains
import platform.Foundation.NSString
import platform.Foundation.NSTemporaryDirectory
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.NSUserDomainMask
import platform.Foundation.stringWithContentsOfFile
import platform.Foundation.writeToFile

private const val CONFIG = "config.json"
private const val STATE = "state.json"
private const val PLAN = "plan.json"

/**
 * config.json, state.json and plan.json in Application Support, laid out as they are on the desktop so the
 * same code reads them. azkar.json ships inside the app: an iPhone has no ~/.config to read.
 */
class IosStorage(private val directory: String = applicationSupport()) : Storage {
    override fun readConfig(): String? = read(path(CONFIG))

    override fun writeConfig(text: String) = write(CONFIG, text)

    /** The copy in the app bundle, which is the only one there is. */
    override fun readAzkar(): String? = NSBundle.mainBundle.pathForResource("azkar", "json")?.let { read(it) }

    override fun readState(): String? = read(path(STATE))

    override fun writeState(text: String) = write(STATE, text)

    /** The reminders already handed to iOS. Not part of [Storage]: only a phone plans ahead. */
    fun readPlan(): String? = read(path(PLAN))

    fun writePlan(text: String) = write(PLAN, text)

    /**
     * Always the same: inside an iPhone app's container nothing but this app can touch the files, so there is
     * never anything to re-read.
     */
    override fun stamp(): Any = directory

    private fun path(name: String) = "$directory/$name"

    @OptIn(ExperimentalForeignApi::class)
    private fun read(path: String): String? =
        NSString.stringWithContentsOfFile(path, NSUTF8StringEncoding, null)

    // Atomically: a phone can take the app away mid-write, and half a file is worse than none.
    @OptIn(ExperimentalForeignApi::class)
    @Suppress("CAST_NEVER_SUCCEEDS")
    private fun write(name: String, text: String) {
        (text as NSString).writeToFile(path(name), atomically = true, encoding = NSUTF8StringEncoding, error = null)
    }
}

/** ~/Library/Application Support/Azkar inside the app's container, made if it isn't there yet. */
@OptIn(ExperimentalForeignApi::class)
fun applicationSupport(): String {
    val base = NSSearchPathForDirectoriesInDomains(
        NSApplicationSupportDirectory,
        NSUserDomainMask,
        true,
    ).firstOrNull() as? String ?: NSTemporaryDirectory()
    val directory = "$base/Azkar"
    NSFileManager.defaultManager.createDirectoryAtPath(directory, true, null, null)
    return directory
}
