---
name: pr-comment
description: Write and post a PR comment the way the user writes them on IRYSS - one finding per comment, addressed to the author, a TL;DR, the code as it stands, the rule or mechanism that makes it wrong, the fix as a diff, and where it was read. Also the shape of a summary review (approve, request changes). Use whenever asked to comment on a PR, post a finding, reply on a thread, or turn an audit finding into a PR comment.
---

# Commenting on a PR

Taken from the user's own comments on #58, #65, #68, #69 and #70 (September 2026). Those are
the reference. Read two of them before writing a long one:
`gh api repos/iryss-platform/iryss/issues/comments --paginate --jq '.[] | select(.user.login=="wildduck2")'`.

Posting is outward-facing, so do it only when the user asked for it in this conversation.

## One finding, one comment

Each finding gets its own PR conversation comment, so each can be answered and resolved on its
own. Fourteen findings means fourteen comments, plus a summary (below), never one wall.

The shape, in this order:

1. **The author's handle, alone on the first line.** Read it, never remember it:
   `gh pr view <n> --json author --jq .author.login`. Hossam is `@mohamedhoss123`; a comment
   addressed to `@mohamedhosaam` notifies nobody.
2. **A `> **TL;DR**` blockquote.** It opens by sizing the point in lowercase ("small one.",
   "a suggestion rather than a finding.", "blocking note on ..."), then states the defect with
   its `file:line` and the fix in one clause. Someone who reads only this knows what to do.
3. **The code as it stands**, in a fenced block with its language, a few lines, no more.
4. **Why it is wrong.** Quote the source that says so, verbatim, as a blockquote with its
   `file:line`: `patterns.md`, `CLAUDE.md`, the ticket, the plan. When the reason is a
   mechanism rather than a rule, quote the mechanism instead, the vendor line included
   (`drizzle-orm/pg-core/dialect.cjs`, the line that skips the migration).
5. **The fix as a `diff`.** The smallest hunk with enough context to find it, one block per
   location. Point to a site already doing it right ("Same placement as
   `authSessions.admin.controller.ts:45`").
6. **What was checked.** Why nothing caught it, what a test cannot see, or the concern that was
   checked and dropped ("I checked, because on the capture `Couleur` sits exactly where a stale
   value would"). This is the part that makes the comment worth more than a lint message.
7. **Fairness, when it is true.** A rule that landed after the branch was cut, a ticket that
   asked for the thing being called wrong, a fork that predates the refactor. Say so plainly:
   "Not a slip on your side either."
8. **How much it matters**, if the TL;DR did not already say: "Please take this one before
   merge.", "Not blocking anything, and it satisfies the ticket as written.", or "yours to take
   or leave with a reason".
9. **Where it was read**, as the last line: "Read at `<sha>`." On someone else's ticket add
   "No patch and no suite run from me: it is your ticket." If something was run, name the tier
   and the result instead.

No headings inside a single-finding comment. Bold only the one sentence that carries the weight.

## The summary review

Posted as the review itself (`gh pr review <n> --approve | --request-changes | --comment
--body-file`), after the per-finding comments:

- Opens with the handle and something specific that is good, not "nice work" alone: the README,
  the constraint that does the work, the call that was right.
- **Before merge**: a short list, each item `file:line` plus the defect in one line.
- **Already fixed** (when the user pushed fixes): a `Where | Was` table.
- **Verified**: a `Gate | Result` table naming the tier, since `bun run test`, integration and
  e2e prove different things.
- **Follow-ups, not blockers**: one line each.
- Anything about merge order or the base branch, and what the next branch has to do because of it.
- A mistake of the reviewer's own is owned in one line, with no action asked of the author.

## Writing

- **Plain ASCII.** No em dashes, curly quotes, arrows or ellipsis characters. Use " - " with
  spaces, a colon, or a full stop. Check before posting:
  `LC_ALL=C grep -n '[^ -~]' <file>` must print nothing.
- Backticks around every identifier, path, code, sha and route.
- Short paragraphs, declarative, British spelling as the docs use it (`organisation`,
  `behaviour`).
- Past tense for what the code did, present for what it does now, and the reader's own
  consequence over the abstract one: "the operator cannot pick another country and cannot
  clear the one they picked", not "the filter has a UX issue".
- Nothing hedged or apologetic, and no praise in a finding. Praise goes in the summary.

## Before posting

1. Re-read every cited line at the PR's current head (`gh pr view <n> --json headRefOid`). A
   rebase or a push since the audit moves line numbers and renames shas.
2. Write the body to a file in the scratchpad and post with `--body-file`, never `--body`, so
   the shell leaves the backticks alone: `gh pr comment <n> --body-file <file>`.
3. Run the ASCII check above.
4. Hand the URL back to the user, and write it beside the finding in
   `docs/mine/pr-audit/pr<n>-<slug>.md` so the report shows what has been raised. Add it to the
   finding's class row in `docs/mine/pr-audit/README.md`, the ledger later audits read first, and
   move the finding's "Still open" row to its new state.

A reply on an existing inline thread goes through
`gh api repos/iryss-platform/iryss/pulls/<n>/comments/<id>/replies -f body=@<file>`, not a new
comment.

## Worked example

https://github.com/iryss-platform/iryss/pull/68#issuecomment-5931723612, the `move` route
answering 201. It has every part above, in order.
