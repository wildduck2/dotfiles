// One zikr card: a floating panel that counts a repetition per click and closes at the end.
import AppKit

/// The × in the card's top-left corner: closes the card at once, whatever is left of its count.
private final class CloseButton: NSImageView {
  var onClose: (() -> Void)?

  init() {
    super.init(frame: .zero)
    image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Close")
    symbolConfiguration = .init(pointSize: 14, weight: .regular)
    contentTintColor = .secondaryLabelColor
    identifier = NSUserInterfaceItemIdentifier("close")
    toolTip = "Close"
  }

  required init?(coder: NSCoder) { fatalError("not used") }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
  override func mouseDown(with event: NSEvent) { onClose?() }
}

/// Lays out top-down, and makes the whole card one click target apart from the ×: the labels
/// never receive the click, so their text can't be selected (selecting re-renders it in the field
/// editor's style, which is what made the text jump in size).
private final class CardContentView: NSView {
  var onClick: (() -> Void)?
  let closeButton = CloseButton()

  override var isFlipped: Bool { true }
  override func hitTest(_ point: NSPoint) -> NSView? {
    guard frame.contains(point) else { return nil }
    return closeButton.frame.contains(convert(point, from: superview)) ? closeButton : self
  }
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
  override func mouseDown(with event: NSEvent) { onClick?() }
}

/// A borderless, non-activating panel that floats above everything (full-screen apps included),
/// shows on every Space, never takes focus, and has no close button or timeout.
@MainActor
final class CardWindow: NSPanel {
  private static let width: CGFloat = 440
  private static let pad: CGFloat = 18
  private static let barHeight: CGFloat = 3
  private static let closeSize: CGFloat = 16

  private let content = CardContentView()
  private var counter: TapCounter
  private let badge: NSTextField
  private let progressFill = NSView()
  private let progressWidth: CGFloat

  var onClick: (() -> Void)? {
    get { content.onClick }
    set { content.onClick = newValue }
  }

  var onClose: (() -> Void)? {
    get { content.closeButton.onClose }
    set { content.closeButton.onClose = newValue }
  }

  init(card: Card, fontSize: CGFloat, hint: String) {
    let inner = Self.width - 2 * Self.pad
    counter = TapCounter(target: card.zikr.count)
    progressWidth = inner
    badge = Self.label(counter.badge, size: 13, weight: .bold, color: card.session.accent, align: .left)
    super.init(
      contentRect: NSRect(x: 0, y: 0, width: Self.width, height: 100),
      styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
    isFloatingPanel = true
    level = .statusBar
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    hidesOnDeactivate = false
    isReleasedWhenClosed = false
    isMovable = false
    backgroundColor = .clear
    isOpaque = false
    hasShadow = true
    appearance = NSAppearance(named: .darkAqua)

    var header = card.session.title
    if let p = card.position, let t = card.total { header += "  ·  \(p) من \(t)" }
    let title = Self.label(header, size: 12, weight: .semibold, color: card.session.accent, align: .right)
    let body = Self.arabic(card.zikr.text, size: fontSize, color: .labelColor)
    let note = card.zikr.note.map { Self.arabic($0, size: 12, color: .secondaryLabelColor) }
    let footer = Self.label("انقر أو \(hint)", size: 11, weight: .regular, color: .tertiaryLabelColor, align: .left)

    func height(_ f: NSTextField) -> CGFloat {
      ceil(f.cell!.cellSize(forBounds: NSRect(x: 0, y: 0, width: inner, height: 10_000)).height)
    }

    var y: CGFloat = 14
    let close = Self.closeSize
    let headerHeight = max(height(title), height(badge), close)
    title.frame = NSRect(x: Self.pad, y: y, width: inner, height: headerHeight)
    content.closeButton.frame = NSRect(x: Self.pad - 2, y: y + (headerHeight - close) / 2, width: close, height: close)
    badge.frame = NSRect(x: Self.pad + close + 4, y: y, width: inner - close - 4, height: headerHeight)
    content.addSubview(title)
    content.addSubview(badge)
    content.addSubview(content.closeButton)
    y += headerHeight + 8
    for (field, gap) in [(body, 0), (note, 6), (footer, 10)] as [(NSTextField?, CGFloat)] {
      guard let field else { continue }
      y += gap
      let h = height(field)
      field.frame = NSRect(x: Self.pad, y: y, width: inner, height: h)
      content.addSubview(field)
      y += h
    }
    if counter.target > 1 {
      y += 10
      let track = NSView(frame: NSRect(x: Self.pad, y: y, width: inner, height: Self.barHeight))
      track.wantsLayer = true
      track.layer?.backgroundColor = card.session.accent.withAlphaComponent(0.2).cgColor
      track.layer?.cornerRadius = Self.barHeight / 2
      progressFill.wantsLayer = true
      progressFill.layer?.backgroundColor = card.session.accent.cgColor
      progressFill.layer?.cornerRadius = Self.barHeight / 2
      track.addSubview(progressFill)
      content.addSubview(track)
      y += Self.barHeight
    }
    y += 12
    updateProgress()

    let background = NSVisualEffectView()
    background.material = .hudWindow
    background.blendingMode = .behindWindow
    background.state = .active
    background.maskImage = Self.roundedMask(radius: 14)
    contentView = background
    setContentSize(NSSize(width: Self.width, height: y))
    content.frame = background.bounds
    content.autoresizingMask = [.width, .height]
    background.addSubview(content)
  }

  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  /// Counts one repetition; returns true once the zikr's count is reached.
  func tap() -> Bool {
    let complete = counter.tap()
    badge.stringValue = counter.badge
    updateProgress()
    NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
    return complete
  }

  /// Fills right-to-left, like the text.
  private func updateProgress() {
    let w = progressWidth * counter.fraction
    progressFill.frame = NSRect(x: progressWidth - w, y: 0, width: w, height: Self.barHeight)
  }

  private static func label(
    _ text: String, size: CGFloat, weight: NSFont.Weight, color: NSColor,
    align: NSTextAlignment
  ) -> NSTextField {
    let f = NSTextField(labelWithString: text)
    f.font = .systemFont(ofSize: size, weight: weight)
    f.textColor = color
    f.alignment = align
    f.isSelectable = false
    return f
  }

  private static func arabic(_ text: String, size: CGFloat, color: NSColor) -> NSTextField {
    let style = NSMutableParagraphStyle()
    style.alignment = .right
    style.baseWritingDirection = .rightToLeft
    style.lineHeightMultiple = 1.3  // room for harakat
    let f = NSTextField(wrappingLabelWithString: "")
    f.isSelectable = false
    f.attributedStringValue = NSAttributedString(
      string: text,
      attributes: [
        .font: NSFont.systemFont(ofSize: size), .foregroundColor: color, .paragraphStyle: style,
      ])
    return f
  }

  private static func roundedMask(radius: CGFloat) -> NSImage {
    let edge = radius * 2 + 1
    let image = NSImage(size: NSSize(width: edge, height: edge), flipped: false) { rect in
      NSColor.black.setFill()
      NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
      return true
    }
    image.capInsets = NSEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
    image.resizingMode = .stretch
    return image
  }
}
