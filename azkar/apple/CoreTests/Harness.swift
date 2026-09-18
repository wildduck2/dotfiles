// A tiny assertion harness, and fixtures shared by the Core tests.
import Foundation

var passed = 0
var failed = 0

func check(_ ok: Bool, _ name: String, line: UInt = #line) {
  if ok {
    passed += 1
  } else {
    failed += 1
    print("FAIL [line \(line)] \(name)")
  }
}

func eq<T: Equatable>(_ got: T, _ want: T, _ name: String, line: UInt = #line) {
  if got == want {
    passed += 1
  } else {
    failed += 1
    print("FAIL [line \(line)] \(name): got \(got), want \(want)")
  }
}

func expectError(_ name: String, mentioning needle: String, line: UInt = #line, _ body: () throws -> Void) {
  do {
    try body()
    failed += 1
    print("FAIL [line \(line)] \(name): expected an error")
  } catch {
    check("\(error)".contains(needle), "\(name): error '\(error)' should mention '\(needle)'", line: line)
  }
}

let cal: Calendar = {
  var c = Calendar(identifier: .gregorian)
  c.timeZone = TimeZone(identifier: "UTC")!
  return c
}()

func at(_ day: Int, _ h: Int, _ m: Int) -> Date {
  cal.date(from: DateComponents(year: 2026, month: 9, day: day, hour: h, minute: m))!
}

func z(_ t: String) -> Zikr { Zikr(text: t, count: 1, note: nil, ref: nil) }
let lib = Library(
  sabah: [z("s1"), z("s2"), z("s3")], masaa: [z("m1"), z("m2")], general: [z("g1"), z("g2"), z("g3")])
let firstIndex: (Int) -> Int = { _ in 0 }

func pick(
  _ date: Date, _ state: inout AppState, config: Config = Config(), library: Library = lib,
  random: (Int) -> Int = firstIndex
) -> Card? {
  Picker.next(at: date, calendar: cal, config: config, library: library, state: &state, random: random)
}
