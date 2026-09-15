// Fixtures shared by the core tests, the same as apple/CoreTests/Harness.swift.
package com.wildduck.azkar.core

import kotlin.test.assertFailsWith
import kotlin.test.assertTrue
import kotlinx.datetime.LocalDateTime

/** A time on a day in September 2026 (the tests use UTC wherever a time zone is needed). */
fun at(day: Int, h: Int, m: Int): LocalDateTime = LocalDateTime(2026, 9, day, h, m)

fun z(text: String): Zikr = Zikr(text)

val lib = Library(
    sabah = listOf(z("s1"), z("s2"), z("s3")),
    masaa = listOf(z("m1"), z("m2")),
    general = listOf(z("g1"), z("g2"), z("g3")),
)

val firstIndex: (Int) -> Int = { 0 }

/** Picks cards one after another, keeping the state between picks like the Swift tests' `inout` state. */
class Picks(var state: AppState = AppState()) {
    fun pick(
        date: LocalDateTime,
        config: Config = Config(),
        library: Library = lib,
        random: (Int) -> Int = firstIndex,
    ): Card? {
        val result = Picker.next(date, config, library, state, random)
        state = result.state
        return result.card
    }
}

/** `block` must throw a ConfigError whose message mentions `mentioning`. */
fun expectError(name: String, mentioning: String, block: () -> Unit) {
    val error = assertFailsWith<ConfigError>(name) { block() }
    assertTrue(
        error.message.orEmpty().contains(mentioning),
        "$name: error '${error.message}' should mention '$mentioning'",
    )
}
