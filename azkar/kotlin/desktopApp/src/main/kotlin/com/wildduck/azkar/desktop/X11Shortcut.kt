// The X11 shortcut: grab the key on the root window and watch for it.
package com.wildduck.azkar.desktop

import com.sun.jna.NativeLong
import com.sun.jna.platform.unix.X11
import com.wildduck.azkar.app.ShortcutMode
import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.KeyStyle

private const val GRAB_MODE_ASYNC = 1
private const val KEY_PRESS = 2
private const val KEY_PRESS_MASK = 1L

/** Grabs the shortcut from the X server, which every X11 desktop allows. */
class X11Shortcut(private val events: ShortcutEvents) : Shortcuts {
    override val mode = ShortcutMode.App

    private val x11: X11 = X11.INSTANCE
    private var display: X11.Display? = null
    private var grabbed: List<Int> = emptyList()
    private var keyCode: Int = 0

    @Volatile
    private var running = true
    private var thread: Thread? = null

    override fun bind(hotkey: Hotkey): String? {
        val trigger = x11Trigger(hotkey)
            ?: return "${hotkey.display(KeyStyle.Linux)} can't be used here"
        val display = display ?: x11.XOpenDisplay(null)?.also { display = it }
            ?: return "Azkar can't reach the X server, so the shortcut is off."
        val root = x11.XDefaultRootWindow(display)

        ungrab()
        val keysym = x11.XStringToKeysym(trigger.keysym)
        val code = x11.XKeysymToKeycode(display, keysym).toInt() and 0xFF
        if (code == 0) return "${hotkey.display(KeyStyle.Linux)} isn't on this keyboard layout."
        keyCode = code
        for (mask in trigger.masks) {
            x11.XGrabKey(display, code, mask, root, 1, GRAB_MODE_ASYNC, GRAB_MODE_ASYNC)
        }
        grabbed = trigger.masks
        x11.XSelectInput(display, root, NativeLong(KEY_PRESS_MASK))
        x11.XSync(display, false)
        if (thread == null) start()
        return null
    }

    override fun close() {
        running = false
        thread?.join(1_000)
        thread = null
        ungrab()
        display?.let { x11.XCloseDisplay(it) }
        display = null
    }

    private fun ungrab() {
        val display = display ?: return
        if (grabbed.isEmpty()) return
        val root = x11.XDefaultRootWindow(display)
        for (mask in grabbed) x11.XUngrabKey(display, keyCode, mask, root)
        grabbed = emptyList()
        x11.XSync(display, false)
    }

    /** X11 has no way to wait on one key, so the events are polled — cheaply, 25 times a second. */
    private fun start() {
        thread = Thread({
            val event = X11.XEvent()
            while (running) {
                val display = display ?: break
                while (x11.XPending(display) > 0) {
                    x11.XNextEvent(display, event)
                    if (event.type == KEY_PRESS) events.onPress()
                }
                Thread.sleep(40)
            }
        }, "azkar-hotkey").apply {
            isDaemon = true
            start()
        }
    }
}
