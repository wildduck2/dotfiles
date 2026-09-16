// What the windows ask the app to do. Each platform implements what it can offer.
package com.wildduck.azkar.ui

import com.wildduck.azkar.app.AzkarController
import com.wildduck.azkar.app.ProblemAction
import com.wildduck.azkar.app.WindowKey
import com.wildduck.azkar.core.Config
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.TimeWindow
import kotlin.time.Instant

interface AzkarActions {
    /** Every change made in the window: the app applies it and writes config.json. */
    fun setConfig(config: Config) {}

    fun setPaused(paused: Boolean) {}

    /** Start one of today's lists again from its first zikr. */
    fun restart(session: Session) {}

    /** A card (or a notification on a phone) right now, without waiting for the interval. */
    fun showNow() {}

    fun dismissAll() {}

    /** Open azkar.json the way this platform opens files. */
    fun editAzkar() {}

    /** The button offered next to a problem. */
    fun perform(action: ProblemAction) {}

    fun quit() {}

    /** The times a switched-off window comes back with. */
    fun rememberedWindow(key: WindowKey): TimeWindow = checkNotNull(key.of(Config()))
}

/** The controller as the windows' actions; each platform adds the parts only it can do. */
open class ControllerActions(
    protected val controller: AzkarController,
    protected val now: () -> Instant,
) : AzkarActions {
    override fun setConfig(config: Config) = controller.setConfig(config)

    override fun setPaused(paused: Boolean) = controller.setPaused(paused)

    override fun restart(session: Session) = controller.restart(session, now())

    override fun rememberedWindow(key: WindowKey): TimeWindow = controller.rememberedWindow(key)
}
