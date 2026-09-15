// Draws the app icon (📿 on a deep teal rounded square) into an .iconset folder for iconutil.
// Usage: icon <out.iconset>   (run by build.sh)
import AppKit

let out = URL(fileURLWithPath: CommandLine.arguments[1])
try? FileManager.default.removeItem(at: out)
try! FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)

func render(_ px: Int) -> Data {
  let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
    bytesPerRow: 0, bitsPerPixel: 0)!
  rep.size = NSSize(width: px, height: px)
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

  // macOS icon grid: an 824/1024 body with a ~185/1024 corner radius.
  let s = CGFloat(px)
  let inset = s * 100 / 1024
  let body = NSBezierPath(
    roundedRect: NSRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset),
    xRadius: s * 185 / 1024, yRadius: s * 185 / 1024)
  NSGraphicsContext.saveGraphicsState()
  let shadow = NSShadow()
  shadow.shadowBlurRadius = s * 24 / 1024
  shadow.shadowOffset = NSSize(width: 0, height: -s * 10 / 1024)
  shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
  shadow.set()
  NSColor.black.setFill()
  body.fill()
  NSGraphicsContext.restoreGraphicsState()
  NSGradient(
    starting: NSColor(srgbRed: 0.10, green: 0.55, blue: 0.50, alpha: 1),
    ending: NSColor(srgbRed: 0.02, green: 0.20, blue: 0.26, alpha: 1))!.draw(in: body, angle: -90)

  let emoji = NSAttributedString(
    string: "📿",
    attributes: [
      .font: NSFont(name: "Apple Color Emoji", size: s * 0.46) ?? .systemFont(ofSize: s * 0.46)
    ])
  let size = emoji.size()
  emoji.draw(at: NSPoint(x: (s - size.width) / 2, y: (s - size.height) / 2))

  NSGraphicsContext.restoreGraphicsState()
  return rep.representation(using: .png, properties: [:])!
}

for base in [16, 32, 128, 256, 512] {
  try! render(base).write(to: out.appendingPathComponent("icon_\(base)x\(base).png"))
  try! render(base * 2).write(to: out.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
}
