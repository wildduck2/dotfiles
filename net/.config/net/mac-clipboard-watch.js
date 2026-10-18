// Runs on the Mac (osascript -l JavaScript), sent over ssh by clip-from-mac.sh; nothing is installed there.
// Prints one line per clipboard change, "image <base64 png>" or "text <base64 utf-8>", until ssh closes.
ObjC.import('AppKit')

const board = $.NSPasteboard.generalPasteboard
const out = $.NSFileHandle.fileHandleWithStandardOutput
const PNG = 4 // NSBitmapImageFileTypePNG

function emit(kind, data) {
  const line = `${kind} ${data.base64EncodedStringWithOptions(0).js}\n`
  out.writeData($(line).dataUsingEncoding($.NSUTF8StringEncoding))
}

// A screenshot or a copied image comes as PNG; TIFF only counts when there is no text, since copying a file in
// Finder puts its icon there next to its name.
function read() {
  const png = board.dataForType($.NSPasteboardTypePNG)
  if (!png.isNil()) return ['image', png]
  const text = board.stringForType($.NSPasteboardTypeString)
  if (!text.isNil()) return ['text', text.dataUsingEncoding($.NSUTF8StringEncoding)]
  const tiff = board.dataForType($.NSPasteboardTypeTIFF)
  if (!tiff.isNil()) {
    const image = $.NSBitmapImageRep.imageRepWithData(tiff)
    if (!image.isNil()) return ['image', image.representationUsingTypeProperties(PNG, $({}))]
  }
  return null
}

function run() {
  let seen = board.changeCount
  for (;;) {
    delay(0.3)
    const count = board.changeCount
    if (count === seen) continue
    seen = count
    const found = read()
    if (found) emit(found[0], found[1])
  }
}
