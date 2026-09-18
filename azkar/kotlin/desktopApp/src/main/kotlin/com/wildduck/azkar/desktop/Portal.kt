// The bits of the XDG desktop portal Azkar talks to: a session, a request, and global shortcuts.
package com.wildduck.azkar.desktop

import org.freedesktop.dbus.DBusPath
import org.freedesktop.dbus.Struct
import org.freedesktop.dbus.annotations.DBusInterfaceName
import org.freedesktop.dbus.annotations.Position
import org.freedesktop.dbus.interfaces.DBusInterface
import org.freedesktop.dbus.messages.DBusSignal
import org.freedesktop.dbus.types.UInt32
import org.freedesktop.dbus.types.UInt64
import org.freedesktop.dbus.types.Variant

const val PORTAL_BUS = "org.freedesktop.portal.Desktop"
const val PORTAL_PATH = "/org/freedesktop/portal/desktop"

/** One shortcut as the portal passes it around: an id, and everything else in a dictionary. */
class PortalEntry(
    @Position(0) val id: String,
    @Position(1) val details: Map<String, Variant<*>>,
) : Struct()

/** The portal answers a call with a request object, and the answer itself arrives as its Response signal. */
@DBusInterfaceName("org.freedesktop.portal.Request")
interface PortalRequest : DBusInterface {
    fun Close()

    class Response(
        path: String,
        val response: UInt32,
        val results: Map<String, Variant<*>>,
    ) : DBusSignal(path, response, results)
}

@DBusInterfaceName("org.freedesktop.portal.Session")
interface PortalSession : DBusInterface {
    fun Close()

    class Closed(path: String, val details: Map<String, Variant<*>>) : DBusSignal(path, details)
}

@DBusInterfaceName("org.freedesktop.portal.GlobalShortcuts")
interface GlobalShortcuts : DBusInterface {
    fun CreateSession(options: Map<String, Variant<*>>): DBusPath

    fun BindShortcuts(
        sessionHandle: DBusPath,
        shortcuts: List<PortalEntry>,
        parentWindow: String,
        options: Map<String, Variant<*>>,
    ): DBusPath

    fun ListShortcuts(sessionHandle: DBusPath, options: Map<String, Variant<*>>): DBusPath

    /** The shortcut was pressed. */
    class Activated(
        path: String,
        val sessionHandle: DBusPath,
        val shortcutId: String,
        val timestamp: UInt64,
        val options: Map<String, Variant<*>>,
    ) : DBusSignal(path, sessionHandle, shortcutId, timestamp, options)

    class Deactivated(
        path: String,
        val sessionHandle: DBusPath,
        val shortcutId: String,
        val timestamp: UInt64,
        val options: Map<String, Variant<*>>,
    ) : DBusSignal(path, sessionHandle, shortcutId, timestamp, options)

    /** The user changed the keys in the desktop's settings. */
    class ShortcutsChanged(
        path: String,
        val sessionHandle: DBusPath,
        val shortcuts: List<PortalEntry>,
    ) : DBusSignal(path, sessionHandle, shortcuts)
}
