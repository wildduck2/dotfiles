package com.wildduck.azkar.core

/** What a reminder tick does: show a card, or skip it and say why. */
sealed interface TickDecision {
    data object Show : TickDecision

    data class Skip(val reason: String) : TickDecision
}

fun decideTick(paused: Boolean, locked: Boolean, quiet: Boolean, stackCount: Int, maxStack: Int): TickDecision =
    when {
        paused -> TickDecision.Skip("paused")
        locked -> TickDecision.Skip("screen locked")
        quiet -> TickDecision.Skip("quiet hours")
        stackCount >= maxStack -> TickDecision.Skip("stack full")
        else -> TickDecision.Show
    }
