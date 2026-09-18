// The Windows shortcut: RegisterHotKey, on the thread that reads its messages.
package com.wildduck.azkar.desktop

import com.sun.jna.platform.win32.User32
import com.sun.jna.platform.win32.WinUser
import com.wildduck.azkar.app.ShortcutMode
import com.wildduck.azkar.core.Hotkey
import com.wildduck.azkar.core.KeyStyle
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

private const val HOTKEY_ID = 1
private const val WM_HOTKEY = 0x0312
private const val PM_REMOVE = 0x0001

/**
 * `RegisterHotKey` belongs to the thread that calls it, and only that thread's message queue hears the key
 * being pressed — so the whole thing lives on one thread of its own, which also does the re-binding.
 */
class WindowsShortcut(private val events: ShortcutEvents) : Shortcuts {
    override val mode = ShortcutMode.App

    @Volatile
    private var wanted: Pair<WindowsTrigger, CompletableFuture<String?>>? = null

    @Volatile
    private var running = true
    private var thread: Thread? = null

    override fun bind(hotkey: Hotkey): String? {
        val trigger = windowsTrigger(hotkey)
            ?: return "${hotkey.display(KeyStyle.Windows)} can't be used here."
        val answer = CompletableFuture<String?>()
        wanted = trigger to answer
        if (thread == null) start()
        return try {
            answer.get(3, TimeUnit.SECONDS)
        } catch (_: Exception) {
            // The key thread is wedged or gone; the app carries on without the shortcut.
            "Azkar couldn't take the shortcut."
        }
    }

    override fun close() {
        running = false
        thread?.join(1_000)
        thread = null
    }

    private fun start() {
        thread = Thread({ loop() }, "azkar-hotkey").apply {
            isDaemon = true
            start()
        }
    }

    private fun loop() {
        val user32 = User32.INSTANCE
        val message = WinUser.MSG()
        var current: WindowsTrigger? = null
        while (running) {
            val next = wanted
            if (next != null && next.first != current) {
                if (current != null) user32.UnregisterHotKey(null, HOTKEY_ID)
                val took = user32.RegisterHotKey(null, HOTKEY_ID, next.first.modifiers, next.first.key)
                current = if (took) next.first else null
                wanted = null
                next.second.complete(if (took) null else "Another app already has this shortcut.")
            }
            while (user32.PeekMessage(message, null, 0, 0, PM_REMOVE)) {
                if (message.message == WM_HOTKEY) events.onPress()
            }
            Thread.sleep(40)
        }
        if (current != null) user32.UnregisterHotKey(null, HOTKEY_ID)
    }
}
