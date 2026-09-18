import Foundation

/// azkar.json decoding (kotlin/shared LibraryTest has the same cases).
func libraryTests() {
  do {
    let json = #"""
      {"sabah": [{"text": "a", "source": "x"}, {"text": "b", "count": 3, "note": "n", "ref": 86}], "masaa": null}
      """#
    let l = try Library.decode(Data(json.utf8))
    eq(l.sabah.first?.text, "a", "unknown keys are ignored")
    eq(l.sabah.first?.count, 1, "count defaults to 1")
    eq(l.sabah.first?.note, nil, "note is optional")
    eq(l.sabah.first?.ref, nil, "ref is optional")
    eq(l.sabah.last, Zikr(text: "b", count: 3, note: "n", ref: 86), "a zikr with every field")
    eq(l.masaa, [], "a null list is empty")
    eq(l.general, [], "a missing list is empty")
  } catch {
    failed += 1
    print("FAIL library decode threw \(error)")
  }
  expectError("a zikr needs text", mentioning: "text") {
    _ = try Library.decode(Data(#"{"general": [{"count": 3}]}"#.utf8))
  }
}
