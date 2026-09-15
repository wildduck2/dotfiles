// Building cards, finding their parts, and clicking them through the real window event path.
import AppKit

let zikrText = "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ"

func card(_ count: Int) -> Card {
  Card(zikr: Zikr(text: zikrText, count: count, note: nil, ref: nil), session: .general, position: nil, total: nil)
}

/// Clicks at `point` (window coordinates), or the middle of the card.
@MainActor
func click(_ w: NSWindow, at point: NSPoint? = nil, clickCount: Int = 1) {
  let p = point ?? NSPoint(x: w.frame.width / 2, y: w.frame.height / 2)
  for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
    let e = NSEvent.mouseEvent(
      with: type, location: p, modifierFlags: [],
      timestamp: ProcessInfo.processInfo.systemUptime,
      windowNumber: w.windowNumber, context: nil, eventNumber: 0,
      clickCount: clickCount, pressure: 1)!
    w.sendEvent(e)
  }
}

@MainActor
func views(_ v: NSView?) -> [NSView] {
  guard let v else { return [] }
  return [v] + v.subviews.flatMap(views)
}

@MainActor
func fields(_ w: NSWindow) -> [NSTextField] { views(w.contentView).compactMap { $0 as? NSTextField } }

@MainActor
func badge(_ w: NSWindow) -> String? {
  fields(w).map(\.stringValue).first { $0.hasPrefix("×") || $0.contains("/") }
}

@MainActor
func bodyFont(_ w: NSWindow) -> NSFont? {
  let body = fields(w).first { $0.stringValue == zikrText }
  return body?.attributedStringValue.attribute(.font, at: 0, effectiveRange: nil) as? NSFont
}

@MainActor
func closeButton(_ w: NSWindow) -> NSView? {
  views(w.contentView).first { $0.identifier?.rawValue == "close" }
}

@MainActor
func clickClose(_ w: NSWindow) {
  guard let b = closeButton(w) else { return }
  click(w, at: b.convert(NSPoint(x: b.bounds.midX, y: b.bounds.midY), to: nil))
}
