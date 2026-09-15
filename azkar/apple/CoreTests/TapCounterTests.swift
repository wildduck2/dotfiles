/// Each click or hotkey press counts once; the card closes when the count is reached.
func tapCounterTests() {
  do {
    var one = TapCounter(target: 1)
    eq(one.badge, "", "×1 cards show no badge")
    check(one.tap(), "a single tap completes a ×1 zikr")

    var three = TapCounter(target: 3)
    eq(three.badge, "×3", "untouched badge shows the target")
    check(!three.tap(), "first of three taps does not complete")
    eq(three.badge, "1/3", "badge counts taps")
    check(!three.tap(), "second of three taps does not complete")
    eq(three.badge, "2/3", "badge counts taps again")
    check(three.tap(), "third tap completes")
    check(three.isComplete, "complete after reaching the target")
    _ = three.tap()
    eq(three.done, 3, "extra taps do not overshoot")

    var four = TapCounter(target: 4)
    _ = four.tap()
    eq(four.fraction, 0.25, "fraction done")

    var zero = TapCounter(target: 0)
    check(zero.tap(), "a target below 1 behaves like 1")
  }
}
