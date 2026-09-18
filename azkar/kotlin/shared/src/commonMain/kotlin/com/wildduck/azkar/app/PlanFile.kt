// plan.json: the reminders iOS has already been handed, so a later launch knows which of them have fired.
package com.wildduck.azkar.app

import com.wildduck.azkar.core.Card
import com.wildduck.azkar.core.PlannedReminder
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr
import kotlin.time.Instant
import kotlinx.serialization.SerializationException
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
private data class StoredZikr(val text: String, val count: Int = 1, val note: String? = null)

@Serializable
private data class StoredReminder(
    /** The time in UTC, to the second: "2026-09-16T18:45:00Z". */
    val at: String,
    val session: String,
    val position: Int? = null,
    val total: Int? = null,
    val zikr: StoredZikr,
    val state: StoredState = StoredState(),
)

@Serializable
private data class StoredPlan(val reminders: List<StoredReminder> = emptyList())

object PlanFile {
    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
        explicitNulls = false
        encodeDefaults = true
    }

    fun encode(plan: List<PlannedReminder>): String = json.encodeToString(
        StoredPlan.serializer(),
        StoredPlan(
            plan.map { reminder ->
                StoredReminder(
                    at = Instant.fromEpochSeconds(reminder.fireAt.epochSeconds).toString(),
                    session = reminder.card.session.name.lowercase(),
                    position = reminder.card.position,
                    total = reminder.card.total,
                    zikr = reminder.card.zikr.let { StoredZikr(it.text, it.count, it.note) },
                    state = reminder.state.stored(),
                )
            },
        ),
    )

    /** A plan is a convenience, not a record: anything unreadable is simply no plan. */
    fun decode(text: String?): List<PlannedReminder> {
        val stored = try {
            text?.let { json.decodeFromString(StoredPlan.serializer(), it) }
        } catch (_: SerializationException) {
            null
        } ?: return emptyList()
        return stored.reminders.mapNotNull { reminder ->
            val fireAt = try {
                Instant.parse(reminder.at)
            } catch (_: IllegalArgumentException) {
                return@mapNotNull null
            }
            val session = Session.entries.firstOrNull { it.name.lowercase() == reminder.session }
                ?: return@mapNotNull null
            PlannedReminder(
                fireAt = fireAt,
                card = Card(
                    zikr = reminder.zikr.let { Zikr(text = it.text, count = it.count, note = it.note) },
                    session = session,
                    position = reminder.position,
                    total = reminder.total,
                ),
                state = reminder.state.state(),
            )
        }
    }
}
