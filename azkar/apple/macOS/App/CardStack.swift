import AppKit

/// The cards on screen: top-right on the primary display, oldest on top.
@MainActor
final class CardStack {
  private var windows: [CardWindow] = []
  private let margin: CGFloat = 16
  private let gap: CGFloat = 10

  /// The display the cards go on: the primary one (with the menu bar), so they stay put instead
  /// of following keyboard focus between screens the way NSScreen.main does.
  var screen: () -> NSScreen? = { NSScreen.screens.first }

  /// Called whenever a card is removed.
  var onChange: (() -> Void)?

  /// Called when a card closes because its count was reached (not when it's closed with ×).
  var onComplete: (() -> Void)?

  var count: Int { windows.count }

  func push(_ window: CardWindow) {
    window.onClick = { [weak self, weak window] in
      guard let self, let window else { return }
      self.tap(window)
    }
    window.onClose = { [weak self, weak window] in
      guard let self, let window else { return }
      self.remove(window)
    }
    windows.append(window)
    layout(animated: true, fresh: window)
    window.alphaValue = 0
    window.orderFrontRegardless()
    NSAnimationContext.runAnimationGroup { ctx in
      ctx.duration = 0.25
      window.animator().alphaValue = 1
    }
  }

  /// One repetition on `window`; it closes when its count is reached.
  func tap(_ window: CardWindow) {
    guard window.tap() else { return }
    remove(window)
    onComplete?()
  }

  func tapOldest() {
    if let oldest = windows.first { tap(oldest) }
  }

  func dismissOldest() {
    if let oldest = windows.first { remove(oldest) }
  }

  func dismissAll() {
    for window in windows { window.orderOut(nil) }
    windows.removeAll()
    onChange?()
  }

  private func remove(_ window: CardWindow) {
    windows.removeAll { $0 === window }
    window.orderOut(nil)
    layout(animated: true)
    onChange?()
  }

  /// Cards flow down from the top-right corner; if they run out of room they overlap at the bottom.
  func layout(animated: Bool, fresh: CardWindow? = nil) {
    guard let display = screen() else { return }
    let area = display.visibleFrame
    var top = area.maxY - margin
    var frames: [(CardWindow, NSRect)] = []
    for w in windows {
      let size = w.frame.size
      let y = max(top - size.height, area.minY + margin)
      frames.append((w, NSRect(x: area.maxX - margin - size.width, y: y, width: size.width, height: size.height)))
      top = y - gap
    }
    NSAnimationContext.runAnimationGroup { ctx in
      ctx.duration = animated ? 0.2 : 0
      for (w, frame) in frames {
        if animated && w !== fresh {
          w.animator().setFrame(frame, display: true)
        } else {
          w.setFrame(frame, display: true)
        }
      }
    }
  }
}
