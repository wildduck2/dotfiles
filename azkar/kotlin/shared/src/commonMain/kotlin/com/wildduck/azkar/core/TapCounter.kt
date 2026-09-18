package com.wildduck.azkar.core

import kotlin.math.max
import kotlin.math.min

/** Repetitions of one zikr: each click or shortcut press is one tap; the card closes at `target`. */
class TapCounter(target: Int) {
    val target: Int = max(1, target)

    var done: Int = 0
        private set

    val isComplete: Boolean get() = done >= target

    /** Returns true once the target is reached. */
    fun tap(): Boolean {
        done = min(done + 1, target)
        return isComplete
    }

    /** "" for ×1, "×3" before the first tap, then "1/3", "2/3"… */
    val badge: String
        get() = when {
            target == 1 -> ""
            done == 0 -> "×$target"
            else -> "$done/$target"
        }

    val fraction: Double get() = done.toDouble() / target
}
