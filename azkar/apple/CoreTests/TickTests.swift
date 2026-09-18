func tickTests() {
  eq(decideTick(paused: false, locked: false, quiet: false, stackCount: 0, maxStack: 5), .show, "normal tick shows")
  eq(decideTick(paused: true, locked: false, quiet: false, stackCount: 0, maxStack: 5), .skip("paused"), "paused")
  eq(
    decideTick(paused: false, locked: true, quiet: false, stackCount: 0, maxStack: 5), .skip("screen locked"), "locked")
  eq(decideTick(paused: false, locked: false, quiet: true, stackCount: 0, maxStack: 5), .skip("quiet hours"), "quiet")
  eq(decideTick(paused: false, locked: false, quiet: false, stackCount: 5, maxStack: 5), .skip("stack full"), "full")
}
