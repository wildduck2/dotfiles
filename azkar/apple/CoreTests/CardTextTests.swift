import Foundation

/// The words on a card, wherever it shows up (kotlin/shared CardTextTest has the same cases).
func cardTextTests() {
  let card = Card(zikr: z("s7"), session: .sabah, position: 7, total: 25)
  eq(cardHeader(card), "أذكار الصباح  ·  7 من 25", "as the card draws it")
  eq(cardHeader(card, separator: " · "), "أذكار الصباح · 7 من 25", "as a notification writes it")
  eq(
    cardHeader(Card(zikr: z("g1"), session: .general, position: nil, total: nil)), "ذِكْر",
    "a general zikr is not part of a list, so it has no place in one")

  eq(cardBody(z("text")), "text", "just the zikr")
  eq(
    cardBody(Zikr(text: "text", count: 1, note: "note", ref: nil)), "text\n\nnote",
    "the note is part of what you read")
  eq(cardBody(Zikr(text: "text", count: 1, note: "  ", ref: nil)), "text", "an empty note is no note")

  eq(notificationBody(z("text")), "text", "a reminder with more coming says nothing extra")
  eq(
    notificationBody(z("text"), last: true), "text\n\nOpen Azkar to keep reminders coming",
    "the last one of a plan says how to keep them coming")
}
