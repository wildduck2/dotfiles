import AppKit

/// Counting by click and hotkey, and the × button.
@MainActor
func cardTests() {
  let stack = CardStack()

  // ×3: every click counts, the last one closes it.
  let three = CardWindow(card: card(3), fontSize: 22, hint: "⌃⌥Z")
  stack.push(three)
  let frame = three.frame
  let font = bodyFont(three)
  check(font != nil, "found the zikr text")
  eq(badge(three), "×3", "untouched card shows ×3")
  let middle = NSPoint(x: frame.width / 2, y: frame.height / 2)
  check(
    three.contentView?.hitTest(middle)?.acceptsFirstMouse(for: nil) == true,
    "the card takes the very first click while the app is in the background")

  click(three)
  eq(badge(three), "1/3", "first click counts 1")
  eq(stack.count, 1, "card stays after the first click")
  check(three.isVisible, "card still on screen after the first click")
  eq(three.frame, frame, "clicking does not resize the card")
  eq(bodyFont(three), font, "clicking does not change the text size")
  check(!(three.firstResponder is NSTextView), "clicking does not start text selection")

  click(three, clickCount: 2)  // second half of a quick double-click
  eq(badge(three), "2/3", "a fast second click still counts")

  click(three)
  eq(stack.count, 0, "last click closes the card")
  check(!three.isVisible, "closed card is off screen")

  // ×1: one click closes it.
  let one = CardWindow(card: card(1), fontSize: 22, hint: "⌃⌥Z")
  stack.push(one)
  click(one)
  eq(stack.count, 0, "one click closes a ×1 card")

  // The × button closes a card at once, whatever is left of its count.
  let big = CardWindow(card: card(100), fontSize: 22, hint: "⌃⌥Z")
  let other = CardWindow(card: card(2), fontSize: 22, hint: "⌃⌥Z")
  stack.push(big)
  stack.push(other)
  click(big)
  check(closeButton(big) != nil, "cards have a close button")
  if let b = closeButton(big) {
    let p = b.convert(NSPoint(x: b.bounds.midX, y: b.bounds.midY), to: nil)
    check(
      big.contentView?.hitTest(p)?.acceptsFirstMouse(for: nil) == true,
      "the close button also takes the first click")
  }
  clickClose(big)
  check(!big.isVisible, "× closes a card mid-count (1/100)")
  eq(stack.count, 1, "× closes only that card")
  eq(badge(other), "×2", "and doesn't count on the other card")
  stack.dismissAll()

  // Hotkey path counts on the oldest card only.
  let oldest = CardWindow(card: card(2), fontSize: 22, hint: "⌃⌥Z")
  let newer = CardWindow(card: card(1), fontSize: 22, hint: "⌃⌥Z")
  stack.push(oldest)
  stack.push(newer)
  stack.tapOldest()
  eq(badge(oldest), "1/2", "hotkey counts 1 on the oldest card")
  eq(stack.count, 2, "both cards stay after the first hotkey press")
  stack.tapOldest()
  eq(stack.count, 1, "hotkey's last count closes the oldest card")
  check(!oldest.isVisible && newer.isVisible, "only the oldest card closed")

  // Finishing a count reports a completion (for its sound); partial taps and × don't.
  stack.dismissAll()
  var completions = 0
  stack.onComplete = { completions += 1 }
  let counted = CardWindow(card: card(2), fontSize: 22, hint: "⌃⌥Z")
  let closed = CardWindow(card: card(2), fontSize: 22, hint: "⌃⌥Z")
  let hotkeyed = CardWindow(card: card(1), fontSize: 22, hint: "⌃⌥Z")
  stack.push(counted)
  stack.push(closed)
  stack.push(hotkeyed)
  click(counted)
  eq(completions, 0, "a partial count is not a completion")
  click(counted)
  eq(completions, 1, "the last click completes the zikr")
  clickClose(closed)
  eq(completions, 1, "closing with × is not a completion")
  stack.tapOldest()
  eq(completions, 2, "completing with the hotkey counts too")
  stack.onComplete = nil

  // Clicking the newer card works while an older one is waiting.
  stack.dismissAll()
  let first = CardWindow(card: card(2), fontSize: 22, hint: "⌃⌥Z")
  let second = CardWindow(card: card(2), fontSize: 22, hint: "⌃⌥Z")
  stack.push(first)
  stack.push(second)
  click(second)
  eq(badge(second), "1/2", "clicking a newer card counts on that card")
  eq(badge(first), "×2", "and leaves the older card alone")
  stack.dismissAll()
}
