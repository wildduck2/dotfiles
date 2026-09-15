/// What a reminder tick does: show a card, or skip it and say why.
enum TickDecision: Equatable {
  case show
  case skip(String)
}

func decideTick(paused: Bool, locked: Bool, quiet: Bool, stackCount: Int, maxStack: Int) -> TickDecision {
  if paused { return .skip("paused") }
  if locked { return .skip("screen locked") }
  if quiet { return .skip("quiet hours") }
  if stackCount >= maxStack { return .skip("stack full") }
  return .show
}
