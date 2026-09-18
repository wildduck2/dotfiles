// Draws the app icon (📿 on a deep teal rounded square).
//   icon <out.iconset>     the sizes iconutil wants for the Mac app
//   icon --ios <out.png>   one 1024 px square for the iPhone app, which iOS masks itself
// (run by build.sh)
import AppKit

/// `full`: edge to edge and opaque, the way iOS wants it. Otherwise the macOS grid: an 824/1024
/// body with a ~185/1024 corner radius, and a shadow under it.
func render(_ px: Int, full: Bool = false) -> Data {
  // Always drawn with alpha: CoreGraphics has no 24-bit bitmap context to draw into.
  let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
    bytesPerRow: 0, bitsPerPixel: 0)!
  rep.size = NSSize(width: px, height: px)
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

  let s = CGFloat(px)
  let inset = full ? 0 : s * 100 / 1024
  let radius = full ? 0 : s * 185 / 1024
  let body = NSBezierPath(
    roundedRect: NSRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset),
    xRadius: radius, yRadius: radius)
  if !full {
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowBlurRadius = s * 24 / 1024
    shadow.shadowOffset = NSSize(width: 0, height: -s * 10 / 1024)
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
    shadow.set()
    NSColor.black.setFill()
    body.fill()
    NSGraphicsContext.restoreGraphicsState()
  }
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
  return full ? opaque(rep) : rep.representation(using: .png, properties: [:])!
}

/// The same picture without its alpha channel, which is what an iPhone icon has to be. The square
/// is opaque anyway, so this only drops the fourth byte of every pixel.
func opaque(_ rep: NSBitmapImageRep) -> Data {
  let px = rep.pixelsWide
  let out = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: rep.pixelsHigh, bitsPerSample: 8,
    samplesPerPixel: 3, hasAlpha: false, isPlanar: false, colorSpaceName: .deviceRGB,
    bytesPerRow: px * 3, bitsPerPixel: 24)!
  let source = rep.bitmapData!
  let target = out.bitmapData!
  let step = rep.bitsPerPixel / 8
  for y in 0..<rep.pixelsHigh {
    for x in 0..<px {
      let from = y * rep.bytesPerRow + x * step
      let to = y * out.bytesPerRow + x * 3
      target[to] = source[from]
      target[to + 1] = source[from + 1]
      target[to + 2] = source[from + 2]
    }
  }
  return out.representation(using: .png, properties: [:])!
}

let args = CommandLine.arguments
if args.count == 3, args[1] == "--ios" {
  let out = URL(fileURLWithPath: args[2])
  try! FileManager.default.createDirectory(
    at: out.deletingLastPathComponent(), withIntermediateDirectories: true)
  try! render(1024, full: true).write(to: out)
} else {
  let out = URL(fileURLWithPath: args[1])
  try? FileManager.default.removeItem(at: out)
  try! FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
  for base in [16, 32, 128, 256, 512] {
    try! render(base).write(to: out.appendingPathComponent("icon_\(base)x\(base).png"))
    try! render(base * 2).write(to: out.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
  }
}
