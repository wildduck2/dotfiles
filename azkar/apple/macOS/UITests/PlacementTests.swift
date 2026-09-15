import AppKit

@MainActor
func placementTests() {
  // Cards go top-right on one fixed display — the primary one, with the menu bar — not on
  // NSScreen.main, which for a background app follows whatever screen you're working on. With
  // two screens, `target` is whichever one is *not* NSScreen.main right now, so a layout that
  // used NSScreen.main would fail.
  eq(CardStack().screen(), NSScreen.screens.first, "cards use the primary display by default")
  let target = NSScreen.screens.first { $0 != NSScreen.main } ?? NSScreen.screens[0]
  let pinned = CardStack()
  pinned.screen = { target }
  let placed = CardWindow(card: card(1), fontSize: 22, hint: "⌃⌥Z")
  pinned.push(placed)
  eq(placed.frame.maxX, target.visibleFrame.maxX - 16, "card sits at the right edge of its display")
  eq(placed.frame.maxY, target.visibleFrame.maxY - 16, "and at its top")
  pinned.dismissAll()
}
