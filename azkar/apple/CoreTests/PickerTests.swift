import Foundation

func pickerTests() {
  do {
    var st = AppState()
    let c1 = pick(at(14, 6, 0), &st)
    eq(c1?.zikr.text, "s1", "sabah window starts at the first morning zikr")
    eq(c1?.session, .sabah, "session is sabah")
    eq(c1?.position, 1, "sabah position 1")
    eq(c1?.total, 3, "sabah total")
    eq(pick(at(14, 6, 3), &st)?.zikr.text, "s2", "second morning zikr")
    eq(pick(at(14, 6, 6), &st)?.zikr.text, "s3", "third morning zikr")
    let after = pick(at(14, 6, 9), &st)
    eq(after?.session, .general, "finished sabah falls back to general")
    eq(after?.position, nil, "general cards have no position")

    // next day restarts the morning list
    eq(pick(at(15, 6, 0), &st)?.zikr.text, "s1", "a new day restarts sabah")
  }

  do {
    var st = AppState()
    eq(pick(at(14, 16, 0), &st)?.zikr.text, "m1", "masaa window starts at the first evening zikr")
    eq(pick(at(14, 16, 3), &st)?.session, .masaa, "session is masaa")
  }

  do {
    var st = AppState()
    var cfg = Config()
    cfg.order = .sequential
    let texts = (0..<4).compactMap { i in pick(at(14, 13, i), &st, config: cfg)?.zikr.text }
    eq(texts, ["g1", "g2", "g3", "g1"], "sequential general wraps around")
  }

  do {
    var st = AppState()
    // A random source that always says 0 must still never show the same zikr twice in a row.
    let texts = (0..<4).compactMap { i in pick(at(14, 13, i), &st)?.zikr.text }
    for (a, b) in zip(texts, texts.dropFirst()) { check(a != b, "random never repeats consecutively (\(texts))") }
  }

  do {
    var st = AppState()
    var cfg = Config()
    cfg.sabah = nil
    eq(pick(at(14, 6, 0), &st, config: cfg)?.session, .general, "disabled sabah window is skipped")
  }

  do {
    // Between the morning and evening windows, and after them, the general azkar show.
    var st = AppState()
    for (h, m) in [(11, 0), (13, 0), (15, 29), (21, 0)] {
      eq(pick(at(14, h, m), &st)?.session, .general, "\(h):\(m) is outside both windows, so a general zikr")
    }
    eq(st.sabah, 0, "general cards don't use up the morning list")
    eq(st.masaa, 0, "general cards don't use up the evening list")
    eq(pick(at(14, 15, 30), &st)?.session, .masaa, "the evening list starts at 15:30")
  }

  do {
    // General azkar are one tap each; only the morning/evening lists keep their counts.
    func counted(_ t: String, _ n: Int) -> Zikr { Zikr(text: t, count: n, note: nil, ref: nil) }
    let lib = Library(sabah: [counted("s", 3)], masaa: [counted("m", 4)], general: [counted("g", 100)])
    var st = AppState()
    eq(pick(at(14, 13, 0), &st, library: lib)?.zikr.count, 1, "a ×100 general zikr is one tap")
    eq(pick(at(14, 6, 0), &st, library: lib)?.zikr.count, 3, "morning azkar keep their count")
    eq(pick(at(14, 6, 3), &st, library: lib)?.zikr.count, 1, "general after the morning list is one tap")
    eq(pick(at(14, 16, 0), &st, library: lib)?.zikr.count, 4, "evening azkar keep their count")
    var cfg = Config()
    cfg.repeatGeneral = true
    eq(pick(at(14, 13, 3), &st, config: cfg, library: lib)?.zikr.count, 100, "repeatGeneral keeps the full count")
  }

  do {
    var st = AppState()
    let empty = Library(sabah: [], masaa: [], general: [])
    eq(pick(at(14, 13, 0), &st, library: empty), nil, "nothing to show")
  }
}
