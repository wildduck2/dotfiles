// One Azkar at a time: a second launch asks the running one to open its window.
package com.wildduck.azkar.desktop

import java.io.IOException
import java.net.StandardProtocolFamily
import java.net.UnixDomainSocketAddress
import java.nio.ByteBuffer
import java.nio.channels.FileChannel
import java.nio.channels.FileLock
import java.nio.channels.OverlappingFileLockException
import java.nio.channels.ServerSocketChannel
import java.nio.channels.SocketChannel
import java.nio.file.Path
import java.nio.file.StandardOpenOption
import kotlin.io.path.createDirectories
import kotlin.io.path.deleteIfExists

/**
 * Held by the running app. The lock file decides who runs; the socket next to it is how the launches that
 * lose the race say "open your window".
 */
class SingleInstance private constructor(
    private val channel: FileChannel,
    private val lock: FileLock,
    private val server: ServerSocketChannel?,
    private val socket: Path,
) : AutoCloseable {
    private var listener: Thread? = null

    /** Runs `handle` whenever another launch of Azkar asks for the window. */
    fun onOpenRequest(handle: () -> Unit) {
        val server = server ?: return
        listener = Thread({
            while (server.isOpen) {
                try {
                    server.accept().use { it.read(ByteBuffer.allocate(16)) }
                } catch (_: Exception) {
                    // The app is closing, or the connection went away: nothing to open.
                    return@Thread
                }
                handle()
            }
        }, "azkar-single-instance").apply {
            isDaemon = true
            start()
        }
    }

    override fun close() {
        try {
            server?.close()
        } catch (_: IOException) {
            // Already gone.
        }
        listener?.interrupt()
        try {
            lock.release()
        } catch (_: IOException) {
            // The JVM is going down anyway.
        }
        channel.close()
        socket.deleteIfExists()
    }

    companion object {
        /**
         * The lock, or null when Azkar is already running — in which case it has been asked to open its
         * window and this launch should just stop.
         */
        fun claim(dir: Path): SingleInstance? {
            dir.createDirectories()
            val socket = dir.resolve("azkar.sock")
            val channel = FileChannel.open(
                dir.resolve("azkar.lock"),
                StandardOpenOption.CREATE,
                StandardOpenOption.READ,
                StandardOpenOption.WRITE,
            )
            val lock = try {
                channel.tryLock()
            } catch (_: OverlappingFileLockException) {
                // Another instance in this same JVM (the tests do this).
                null
            }
            if (lock == null) {
                channel.close()
                askToOpen(socket)
                return null
            }
            return SingleInstance(channel, lock, listen(socket), socket)
        }

        /** Takes the socket over from the last run, which may have crashed without cleaning up. */
        private fun listen(socket: Path): ServerSocketChannel? = try {
            socket.deleteIfExists()
            ServerSocketChannel.open(StandardProtocolFamily.UNIX)
                .bind(UnixDomainSocketAddress.of(socket))
        } catch (_: Exception) {
            // No socket (an old Windows, or a path too long for one): the app still runs, just alone.
            null
        }

        private fun askToOpen(socket: Path) {
            try {
                SocketChannel.open(UnixDomainSocketAddress.of(socket)).use {
                    it.write(ByteBuffer.wrap("open".toByteArray()))
                }
            } catch (_: Exception) {
                // Nobody listening: the other instance is starting up or wedged. Nothing to do.
            }
        }
    }
}
