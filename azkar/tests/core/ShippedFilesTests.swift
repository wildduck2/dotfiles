import Foundation

/// The azkar.json and config.json in .config/azkar.
func shippedFilesTests() {
  let pkg = URL(fileURLWithPath: #filePath)  // azkar/tests/core/ShippedFilesTests.swift
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
  do {
    let data = try Data(contentsOf: pkg.appendingPathComponent(".config/azkar/azkar.json"))
    let shipped = try Library.decode(data)
    eq(shipped.sabah.count, 25, "shipped sabah count")
    eq(shipped.masaa.count, 23, "shipped masaa count")
    eq(shipped.general.count, 22, "shipped general count")
    let all = shipped.sabah + shipped.masaa + shipped.general
    check(all.allSatisfy { !$0.text.isEmpty && $0.count >= 1 }, "every shipped zikr has text and a count")
  } catch {
    failed += 1
    print("FAIL shipped azkar.json: \(error)")
  }

  do {
    let data = try Data(contentsOf: pkg.appendingPathComponent(".config/azkar/config.json"))
    // This is the live file the settings window writes to (through stow), so it can differ from the
    // defaults — but it must be valid and in exactly the window's own format.
    let live = try Config.decode(data)
    eq(
      String(decoding: data, as: UTF8.self), String(decoding: live.encode(), as: UTF8.self),
      "config.json is in the format the settings window writes")
  } catch {
    failed += 1
    print("FAIL shipped config.json: \(error)")
  }
}
