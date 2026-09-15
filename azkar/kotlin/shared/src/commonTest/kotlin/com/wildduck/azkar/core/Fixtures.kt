// Fixtures shared by the core tests, the same as apple/CoreTests/Harness.swift.
package com.wildduck.azkar.core

import kotlin.test.assertFailsWith
import kotlin.test.assertTrue
import kotlinx.datetime.LocalDateTime

/** A time on a day in September 2026 (the tests use UTC wherever a time zone is needed). */
fun at(day: Int, h: Int, m: Int): LocalDateTime = LocalDateTime(2026, 9, day, h, m)

/** `block` must throw a ConfigError whose message mentions `mentioning`. */
fun expectError(name: String, mentioning: String, block: () -> Unit) {
    val error = assertFailsWith<ConfigError>(name) { block() }
    assertTrue(
        error.message.orEmpty().contains(mentioning),
        "$name: error '${error.message}' should mention '$mentioning'",
    )
}
