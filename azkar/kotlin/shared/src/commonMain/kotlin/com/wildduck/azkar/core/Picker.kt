// Picking the next card, and the progress through today's lists that it keeps.
package com.wildduck.azkar.core

import kotlinx.datetime.LocalDateTime

enum class Session(val raw: String) { Sabah("sabah"), Masaa("masaa"), General("general") }

data class Card(
    val zikr: Zikr,
    val session: Session,
    /** 1-based position within the morning/evening list; null for general azkar. */
    val position: Int? = null,
    val total: Int? = null,
)

/** Kept between launches so the morning/evening lists continue where they left off today. */
data class AppState(
    val day: String = "",
    val sabah: Int = 0,
    val masaa: Int = 0,
    val general: Int = 0,
    val lastGeneral: Int? = null,
    val paused: Boolean = false,
)

/** The picked card (null when there is nothing to show) and the state after picking. */
data class Pick(val card: Card?, val state: AppState)

object Picker {
    /**
     * Inside the morning (evening) window, walks that list in order once per day; otherwise, or once the list is
     * done, picks from `general` (one tap each unless `repeatGeneral`). `random(n)` must return 0 until n.
     */
    fun next(at: LocalDateTime, config: Config, library: Library, state: AppState, random: (Int) -> Int): Pick {
        val today = dayKey(at)
        var st = if (state.day == today) state else state.copy(day = today, sabah = 0, masaa = 0)
        val minute = minuteOfDay(at)

        val sabah = library.sabah
        if (config.sabah?.contains(minute) == true && st.sabah < sabah.size) {
            val i = st.sabah
            return Pick(Card(sabah[i], Session.Sabah, i + 1, sabah.size), st.copy(sabah = i + 1))
        }
        val masaa = library.masaa
        if (config.masaa?.contains(minute) == true && st.masaa < masaa.size) {
            val i = st.masaa
            return Pick(Card(masaa[i], Session.Masaa, i + 1, masaa.size), st.copy(masaa = i + 1))
        }

        val general = library.general
        if (general.isEmpty()) return Pick(null, st)
        val i: Int
        when (config.order) {
            Order.Sequential -> {
                i = st.general % general.size
                st = st.copy(general = i + 1)
            }
            Order.Random -> {
                val last = st.lastGeneral
                i = when {
                    general.size == 1 -> 0
                    // Skip `last` so the same zikr never shows twice in a row.
                    last != null && last < general.size -> random(general.size - 1).let { r -> if (r >= last) r + 1 else r }
                    else -> random(general.size)
                }
            }
        }
        val zikr = if (config.repeatGeneral) general[i] else general[i].copy(count = 1)
        return Pick(Card(zikr, Session.General), st.copy(lastGeneral = i))
    }
}
