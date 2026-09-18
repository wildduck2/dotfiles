import Foundation

/// plan.json: what iOS has already been handed (kotlin/shared PlanFileTest has the same cases).
func planFileTests() {
  // In the morning window, so the reminders carry their place in that day's list.
  let plan = Plan.make(
    now: at(14, 6, 0), calendar: cal, config: Config(), library: lib, state: AppState(), limit: 3,
    random: firstIndex)
  eq(plan.count, 3, "three reminders to write down")
  eq(plan.first?.card.position, 1, "the first one is the first zikr of the morning")

  let text = PlanFile.encode(plan)
  eq(PlanFile.decode(text), plan, "a plan comes back as it went")
  check(text.contains("\"session\":\"sabah\""), "every list is written by its own name")
  check(text.contains("2026-09-14T06:03:00Z"), "and every time in UTC, to the second")

  eq(PlanFile.decode(nil), [], "no file yet is no plan")
  eq(PlanFile.decode("not json"), [], "a broken file is no plan either")
  eq(PlanFile.decode("{}"), [], "nor is a file with nothing in it")
  eq(
    PlanFile.decode(#"{"reminders":[{"at":"never","session":"sabah","zikr":{"text":"s1","count":1},"state":{}}]}"#),
    [], "a reminder with a time nobody can read is dropped")
}
