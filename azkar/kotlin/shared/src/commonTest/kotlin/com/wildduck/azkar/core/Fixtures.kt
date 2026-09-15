// Fixtures shared by the core tests, the same as apple/CoreTests/Harness.swift.
package com.wildduck.azkar.core

import kotlinx.datetime.LocalDateTime

/** A time on a day in September 2026 (the tests use UTC wherever a time zone is needed). */
fun at(day: Int, h: Int, m: Int): LocalDateTime = LocalDateTime(2026, 9, day, h, m)
