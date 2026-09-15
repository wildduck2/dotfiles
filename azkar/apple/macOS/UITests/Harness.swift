// A tiny assertion harness for the UI tests.

var passed = 0
var failed = 0

func check(_ ok: Bool, _ name: String, line: UInt = #line) {
  if ok {
    passed += 1
  } else {
    failed += 1
    print("FAIL [ui line \(line)] \(name)")
  }
}

func eq<T: Equatable>(_ got: T, _ want: T, _ name: String, line: UInt = #line) {
  if got == want {
    passed += 1
  } else {
    failed += 1
    print("FAIL [ui line \(line)] \(name): got \(got), want \(want)")
  }
}
