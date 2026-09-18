// What one reminder does, wherever it comes from: the desktop's second-by-second loop or a phone's alarm.
package com.wildduck.azkar.app

import com.wildduck.azkar.core.Card

/** A reminder either shows a zikr or doesn't, and then it says why not. */
sealed interface Fired {
    data class Show(val card: Card) : Fired

    /** "paused", "quiet hours", "stack full", "screen locked", "nothing to show". */
    data class Skip(val reason: String) : Fired
}
