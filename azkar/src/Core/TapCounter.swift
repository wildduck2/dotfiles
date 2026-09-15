/// Repetitions of one zikr: each click or hotkey press is one tap; the card closes at `target`.
struct TapCounter: Equatable {
  let target: Int
  private(set) var done = 0

  init(target: Int) { self.target = max(1, target) }

  var isComplete: Bool { done >= target }

  /// Returns true once the target is reached.
  mutating func tap() -> Bool {
    done = min(done + 1, target)
    return isComplete
  }

  /// "" for ×1, "×3" before the first tap, then "1/3", "2/3"…
  var badge: String {
    if target == 1 { return "" }
    return done == 0 ? "×\(target)" : "\(done)/\(target)"
  }

  var fraction: Double { Double(done) / Double(target) }
}
