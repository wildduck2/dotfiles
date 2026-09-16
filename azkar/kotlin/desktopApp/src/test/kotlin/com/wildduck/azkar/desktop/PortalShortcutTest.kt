package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.ShortcutInfo
import com.wildduck.azkar.app.ShortcutMode
import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.Modifier
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.freedesktop.dbus.DBusPath
import org.freedesktop.dbus.bin.EmbeddedDBusDaemon
import org.freedesktop.dbus.connections.BusAddress
import org.freedesktop.dbus.connections.impl.DBusConnection
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder
import org.freedesktop.dbus.connections.transports.TransportBuilder
import org.freedesktop.dbus.types.UInt32
import org.freedesktop.dbus.types.UInt64
import org.freedesktop.dbus.types.Variant

/** A portal that says yes, so the whole handshake can be tested without a Wayland session. */
private class FakePortal(private val connection: DBusConnection) : GlobalShortcuts {
    var trigger: String? = null
    var description = "Ctrl+Alt+Z"
    var session: DBusPath? = null
    /** The answer code: 0 took it, 1 you said no, 2 the portal gave up. */
    var answer = 0

    override fun getObjectPath(): String = PORTAL_PATH

    override fun CreateSession(options: Map<String, Variant<*>>): DBusPath {
        session = DBusPath("$PORTAL_PATH/session/1/${options["session_handle_token"]?.value}")
        return request(options, mapOf("session_handle" to Variant(session!!.path)))
    }

    override fun BindShortcuts(
        sessionHandle: DBusPath,
        shortcuts: List<PortalEntry>,
        parentWindow: String,
        options: Map<String, Variant<*>>,
    ): DBusPath {
        trigger = shortcuts.single().details["preferred_trigger"]?.value?.toString()
        return request(options, mapOf("shortcuts" to Variant(bound(), "a(sa{sv})")))
    }

    override fun ListShortcuts(sessionHandle: DBusPath, options: Map<String, Variant<*>>): DBusPath =
        request(options, mapOf("shortcuts" to Variant(bound(), "a(sa{sv})")))

    /** The desktop was told to use different keys. */
    fun changeShortcuts(to: String) {
        description = to
        connection.sendMessage(GlobalShortcuts.ShortcutsChanged(PORTAL_PATH, session!!, bound()))
    }

    fun press() {
        connection.sendMessage(
            GlobalShortcuts.Activated(PORTAL_PATH, session!!, "count", UInt64(1), emptyMap()),
        )
    }

    private fun bound() =
        listOf(PortalEntry("count", mapOf("trigger_description" to Variant(description))))

    /** The portal answers with a request object, then sends the answer to it. */
    private fun request(options: Map<String, Variant<*>>, results: Map<String, Variant<*>>): DBusPath {
        val path = "$PORTAL_PATH/request/1/${options["handle_token"]?.value}"
        Thread {
            Thread.sleep(50)
            val body = if (answer == 0) results else emptyMap()
            connection.sendMessage(PortalRequest.Response(path, UInt32(answer.toLong()), body))
        }.start()
        return DBusPath(path)
    }
}

class PortalShortcutTest {
    @Test
    fun theWaylandHandshake() {
        val listenOn = TransportBuilder.createDynamicSession("UNIX", true)
        // The daemon listens; everyone else connects to the same socket.
        val address = BusAddress.of(listenOn).removeParameter("listen")
        val daemon = EmbeddedDBusDaemon(BusAddress.of(listenOn))
        daemon.startInBackgroundAndWait(10_000)
        try {
            DBusConnectionBuilder.forAddress(address).withShared(false).build().use { desktop ->
                desktop.requestBusName(PORTAL_BUS)
                val portal = FakePortal(desktop)
                desktop.exportObject(PORTAL_PATH, portal)

                var pressed = 0
                var shown: ShortcutInfo? = null
                val shortcut = PortalShortcut(
                    events = ShortcutEvents(onPress = { pressed += 1 }, onInfo = { shown = it }),
                    connect = { DBusConnectionBuilder.forAddress(address).withShared(false).build() },
                    timeoutMillis = 10_000,
                )
                try {
                    assertNull(
                        shortcut.bind(Hotkey(setOf(Modifier.Ctrl, Modifier.Alt), "z")),
                        "the portal took the shortcut",
                    )
                    assertEquals("CTRL+ALT+z", portal.trigger, "asked for as the shortcuts specification writes it")
                    assertEquals("Ctrl+Alt+Z", assertNotNull(shown, "the portal said how it will be shown").display)
                    assertTrue(
                        shown!!.mode is ShortcutMode.SystemSettings,
                        "on Wayland the desktop owns the binding",
                    )

                    portal.press()
                    assertTrue(waitFor { pressed == 1 }, "a press reaches the app")

                    portal.changeShortcuts("Super+K")
                    assertTrue(waitFor { shown?.display == "Super+K" }, "and a change of keys is shown")
                } finally {
                    shortcut.close()
                }
            }
        } finally {
            daemon.close()
        }
    }

    @Test
    fun aPortalThatSaysNoBecomesAProblem() {
        val listenOn = TransportBuilder.createDynamicSession("UNIX", true)
        val address = BusAddress.of(listenOn).removeParameter("listen")
        val daemon = EmbeddedDBusDaemon(BusAddress.of(listenOn))
        daemon.startInBackgroundAndWait(10_000)
        try {
            DBusConnectionBuilder.forAddress(address).withShared(false).build().use { desktop ->
                desktop.requestBusName(PORTAL_BUS)
                val portal = FakePortal(desktop)
                portal.answer = 1
                desktop.exportObject(PORTAL_PATH, portal)

                val shortcut = PortalShortcut(
                    events = ShortcutEvents(),
                    connect = { DBusConnectionBuilder.forAddress(address).withShared(false).build() },
                    timeoutMillis = 10_000,
                )
                try {
                    val problem = assertNotNull(
                        shortcut.bind(Hotkey(setOf(Modifier.Ctrl, Modifier.Alt), "z")),
                        "a refusal is reported, not swallowed",
                    )
                    assertTrue("turned the request down" in problem, "with what the portal said: $problem")
                } finally {
                    shortcut.close()
                }
            }
        } finally {
            daemon.close()
        }
    }

    @Test
    fun theTriggerDescriptionHoweverItArrives() {
        val asStructs = listOf(
            PortalEntry("other", mapOf("trigger_description" to Variant("Ctrl+O"))),
            PortalEntry("count", mapOf("trigger_description" to Variant("Ctrl+Alt+Z"))),
        )
        assertEquals("Ctrl+Alt+Z", triggerDescription(asStructs, "count"), "from the portal's own structs")
        // Inside a variant, D-Bus structs come back as plain arrays.
        val asArrays = arrayOf<Any>(
            arrayOf<Any>("count", mapOf("trigger_description" to Variant("Super+K"))),
        )
        assertEquals("Super+K", triggerDescription(asArrays, "count"), "and from the arrays in a variant")
        assertNull(triggerDescription(asArrays, "nope"), "a shortcut that isn't there has no description")
        assertNull(triggerDescription("rubbish", "count"), "and neither has rubbish")
    }

    private fun waitFor(until: () -> Boolean): Boolean {
        val deadline = System.currentTimeMillis() + 10_000
        while (System.currentTimeMillis() < deadline) {
            if (until()) return true
            Thread.sleep(20)
        }
        return false
    }
}
