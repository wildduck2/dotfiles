// The Wayland shortcut: the desktop holds the keys, and tells Azkar when they are pressed.
package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.ShortcutInfo
import com.wildduck.azkar.app.ShortcutMode
import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.KeyStyle
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit
import org.freedesktop.dbus.DBusPath
import org.freedesktop.dbus.connections.impl.DBusConnection
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder
import org.freedesktop.dbus.interfaces.DBus
import org.freedesktop.dbus.types.Variant

private const val SHORTCUT_ID = "count"
private const val DESCRIPTION = "Count the zikr on the card, or close it"

/** Is there a portal on this session bus to ask? */
fun portalAvailable(): Boolean = try {
    DBusConnectionBuilder.forSessionBus().withShared(false).build().use { connection ->
        val bus = connection.getRemoteObject("org.freedesktop.DBus", "/org/freedesktop/DBus", DBus::class.java)
        PORTAL_BUS in bus.ListNames() || PORTAL_BUS in bus.ListActivatableNames()
    }
} catch (_: Exception) {
    false
}

/**
 * On Wayland an app can't grab keys, so the desktop's portal holds the shortcut and sends `Activated`
 * when it is pressed. The desktop also decides what the trigger really ends up being, and says so — which
 * is why the settings page shows its words instead of a recorder.
 */
class PortalShortcut(
    private val events: ShortcutEvents,
    private val connect: () -> DBusConnection = { DBusConnectionBuilder.forSessionBus().withShared(false).build() },
    private val timeoutMillis: Long = 15_000,
) : Shortcuts {
    override val mode = ShortcutMode.SystemSettings("Change it in the desktop's keyboard settings")

    private var connection: DBusConnection? = null
    private var session: DBusPath? = null
    private val handlers = mutableListOf<AutoCloseable>()
    private val answers = ConcurrentHashMap<String, CompletableFuture<Map<String, Variant<*>>>>()

    override fun bind(hotkey: Hotkey): String? {
        val trigger = portalTrigger(hotkey)
            ?: return "${hotkey.display(KeyStyle.Linux)} can't be asked for here."
        return try {
            val connection = connection ?: open()
            // The trigger is fixed when the session is bound, so a new shortcut means a new session.
            closeSession()
            val portal = connection.getRemoteObject(PORTAL_BUS, PORTAL_PATH, GlobalShortcuts::class.java)

            val created = answer(portal.CreateSession(options()))
            val handle = created["session_handle"]?.value?.toString()
                ?: return "The desktop portal didn't open a session for the shortcut."
            val session = DBusPath(handle)
            this.session = session

            val entry = PortalEntry(
                SHORTCUT_ID,
                mapOf(
                    "description" to Variant(DESCRIPTION),
                    "preferred_trigger" to Variant(trigger),
                ),
            )
            val bound = answer(portal.BindShortcuts(session, listOf(entry), "", options()))
            describe(bound["shortcuts"]?.value)
            events.onProblem(null)
            null
        } catch (e: Exception) {
            "The desktop portal wouldn't take the shortcut: ${reason(e)}"
        }
    }

    override fun close() {
        closeSession()
        handlers.forEach { runCatching { it.close() } }
        handlers.clear()
        runCatching { connection?.close() }
        connection = null
    }

    private fun open(): DBusConnection {
        val connection = connect()
        this.connection = connection
        // Subscribed before anything is called, so an answer can't arrive before we are listening.
        handlers += connection.addSigHandler(PortalRequest.Response::class.java) { signal ->
            val future = answers.computeIfAbsent(signal.path) { CompletableFuture() }
            if (signal.response.toInt() == 0) {
                future.complete(signal.results)
            } else {
                future.completeExceptionally(
                    IllegalStateException(
                        if (signal.response.toInt() == 1) "you turned the request down" else "the portal gave up",
                    ),
                )
            }
        }
        handlers += connection.addSigHandler(GlobalShortcuts.Activated::class.java) { signal ->
            if (signal.shortcutId == SHORTCUT_ID && signal.sessionHandle == session) events.onPress()
        }
        handlers += connection.addSigHandler(GlobalShortcuts.ShortcutsChanged::class.java) { signal ->
            if (signal.sessionHandle == session) describe(signal.shortcuts)
        }
        return connection
    }

    private fun options(): Map<String, Variant<*>> {
        val token = "azkar${(1..8).map { ('a'..'z').random() }.joinToString("")}"
        return mapOf(
            "handle_token" to Variant(token),
            "session_handle_token" to Variant(token),
        )
    }

    private fun answer(request: DBusPath): Map<String, Variant<*>> {
        val future = answers.computeIfAbsent(request.path) { CompletableFuture() }
        try {
            return future.get(timeoutMillis, TimeUnit.MILLISECONDS)
        } finally {
            answers.remove(request.path)
        }
    }

    /** The desktop's own words for the trigger, which is what the settings page shows. */
    private fun describe(shortcuts: Any?) {
        val description = triggerDescription(shortcuts, SHORTCUT_ID) ?: return
        events.onInfo(ShortcutInfo(description, mode))
    }

    private fun closeSession() {
        val connection = connection ?: return
        val session = session ?: return
        this.session = null
        runCatching {
            connection.getRemoteObject(PORTAL_BUS, session.path, PortalSession::class.java).Close()
        }
    }

    private fun reason(e: Exception): String =
        (e.cause?.message ?: e.message)?.lineSequence()?.first() ?: (e::class.simpleName ?: "no answer")
}

/**
 * Pulls the trigger description for `id` out of the portal's `a(sa{sv})`. Inside a variant, D-Bus structs
 * arrive as plain arrays rather than as [PortalEntry], so both shapes are read here.
 */
fun triggerDescription(shortcuts: Any?, id: String): String? {
    val entries: List<Any?> = when (shortcuts) {
        is List<*> -> shortcuts
        is Array<*> -> shortcuts.toList()
        else -> return null
    }
    for (entry in entries) {
        val entryId: String?
        val details: Map<*, *>?
        when (entry) {
            is PortalEntry -> {
                entryId = entry.id
                details = entry.details
            }
            is Array<*> -> {
                entryId = entry.getOrNull(0) as? String
                details = entry.getOrNull(1) as? Map<*, *>
            }
            else -> continue
        }
        if (entryId != id || details == null) continue
        val value = details["trigger_description"]
        val text = ((value as? Variant<*>)?.value ?: value)?.toString()
        if (!text.isNullOrEmpty()) return text
    }
    return null
}
