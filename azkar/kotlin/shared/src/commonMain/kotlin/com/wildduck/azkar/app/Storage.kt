// Where the three files live, per platform: ~/.config/azkar on the desktop, app storage on a phone.
package com.wildduck.azkar.app

/**
 * The app's files as text. Reads return null when the file isn't there; writes replace it.
 * Implementations keep the desktop layout: config.json, azkar.json and state.json in one folder.
 */
interface Storage {
    fun readConfig(): String?

    fun writeConfig(text: String)

    fun readAzkar(): String?

    fun readState(): String?

    fun writeState(text: String)

    /**
     * Anything that changes when config.json or azkar.json change on disk (their timestamps, say), so the app can
     * skip re-reading them. Return a fresh object to always reload.
     */
    fun stamp(): Any?
}
