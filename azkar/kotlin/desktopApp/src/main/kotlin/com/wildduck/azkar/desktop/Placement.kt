// Where the cards go: the room a display leaves for them, and whether it can draw them without a frame.
package com.wildduck.azkar.desktop

import com.wildduck.azkar.app.CardArea
import java.awt.GraphicsDevice
import java.awt.GraphicsEnvironment
import java.awt.Insets
import java.awt.Rectangle
import java.awt.Toolkit

/**
 * A display minus the space the desktop keeps for itself: the menu bar, the taskbar, a dock on the side.
 * The numbers are the ones window positions use, so a card can be put straight at one.
 */
fun cardArea(bounds: Rectangle, insets: Insets): CardArea = CardArea(
    left = bounds.x + insets.left,
    top = bounds.y + insets.top,
    right = bounds.x + bounds.width - insets.right,
    bottom = bounds.y + bounds.height - insets.bottom,
)

/** The display the cards live on. */
fun defaultCardArea(): CardArea = try {
    val screen = GraphicsEnvironment.getLocalGraphicsEnvironment().defaultScreenDevice.defaultConfiguration
    cardArea(screen.bounds, Toolkit.getDefaultToolkit().getScreenInsets(screen))
} catch (_: Throwable) {
    // Nothing to ask (a build machine with no display): a plain screen, so cards still land somewhere.
    CardArea(left = 0, top = 0, right = 1280, bottom = 800)
}

/**
 * Whether a window can have transparent corners. Without a compositor it can't, and a card then sits in an
 * opaque rectangle instead of looking like a rounded card.
 */
fun transparentWindowsWork(): Boolean = try {
    GraphicsEnvironment.getLocalGraphicsEnvironment().defaultScreenDevice
        .isWindowTranslucencySupported(GraphicsDevice.WindowTranslucency.PERPIXEL_TRANSLUCENT)
} catch (_: Throwable) {
    false
}
