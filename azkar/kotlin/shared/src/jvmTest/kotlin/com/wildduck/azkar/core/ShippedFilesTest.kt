package com.wildduck.azkar.core

import java.io.File
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The azkar.json and config.json in azkar/.config/azkar, as apple/CoreTests/ShippedFilesTests.swift checks them. */
class ShippedFilesTest {
    // Set by shared/build.gradle.kts: the azkar/ stow package.
    private val dir = File(requireNotNull(System.getProperty("azkar.package")) { "run with ./gradlew jvmTest" })
        .resolve(".config/azkar")

    @Test
    fun shippedAzkarJson() {
        val shipped = Library.decode(dir.resolve("azkar.json").readText())
        assertEquals(25, shipped.sabah.size, "shipped sabah count")
        assertEquals(23, shipped.masaa.size, "shipped masaa count")
        assertEquals(22, shipped.general.size, "shipped general count")
        val all = shipped.sabah + shipped.masaa + shipped.general
        assertTrue(all.all { it.text.isNotEmpty() && it.count >= 1 }, "every shipped zikr has text and a count")
    }

    @Test
    fun shippedConfigJson() {
        // The live file the macOS settings window writes to (through stow), so it can differ from the defaults, but
        // it must be valid and in exactly the format both apps write.
        val text = dir.resolve("config.json").readText()
        assertEquals(Config.decode(text).encode(), text, "config.json is in the format the settings window writes")
    }
}
