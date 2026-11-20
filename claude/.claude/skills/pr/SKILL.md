---
name: pr
description: Open a PR in this repo end to end - find the real base branch (never assume main), commit the tree one feature per commit, read the Linear tickets, write a short body a reviewer takes in at a glance, and confirm the base, assignee and labels landed. Use whenever asked to make, open or push a PR, or to commit a working tree "by feature" so a PR can follow.
metadata:
  credits:
    skill: show-me
    author: Dex Horthy
    organisation: Humanlayer
    url: "https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md"
---

# Opening a PR in IRYSS

Each step is here because skipping it once produced a wrong PR: the wrong base branch, a 104-file
commit, a made-up label, a 9,000-character body.

## 1. Find the real base branch, never assume `main`

`main` has been 150 commits behind the branch PRs actually merged into. Read what recent PRs
targeted, then confirm with a count:

```bash
gh pr list --state merged --limit 5 --json number,baseRefName,headRefName
git fetch origin <candidate> --quiet
git log --oneline origin/<candidate>..HEAD | wc -l
```

The right base gives a count that matches this branch's own work, single digits for a normal PR.
The wrong one quietly adds someone else's unmerged history to the diff.

## 2. One commit per feature

A PR title makes one claim, and a tree of tangled fixes cannot back it.

1. Map every changed file to its feature with `git status --porcelain=v1` and `git diff`.
2. Stage one feature, check `git diff --cached --stat`, run `bun run check-types` so the commit
   builds on its own, and commit. Repeat.
3. When one file interleaves two features' hunks (there is no `git add -p` here), write feature A's
   version of it, verify, commit, then put B's hunks back on top.
4. Messages follow `CLAUDE.md` "Commits". A body paragraph starts with a word, not a `word:` token,
   or commitlint reads it as a footer. A claim that something "fails without" the change has to be
   true at the commit's parent.

If the tree holds more than the one thing you were told about, say so and propose the split.

## 3. Read the tickets

Read every Linear ticket the work closes or touches, not just its id: `mcp__linear__get_issue`, and
`mcp__linear__list_issues` with `parentId` for sub-issues. One assigned to someone else is theirs
to build.

## 4. Write the body

A reviewer should take it in at a glance: what changed, what to look at, what cannot be undone, and
the proof. Each commit message already carries its own why, so the body does not repeat it.

```markdown
<What this does and for whom, in one or two plain sentences, ticket linked. Why it lands now, if
that is not obvious.>

- <one line per distinct piece of work, only when there are two or more>

Worth a look:

- <a decision or trade-off a reviewer should check, one line each>

Merge danger:

- <something reverting the PR does not undo, or a merge order, one line each>

For later:

- [ ] <what is left out on purpose, one line each>

<The proof in one line: each tier that ran, its count, and the sha it ran at.>
```

Drop a section with nothing to say. Aim under 1,500 characters for one feature and 3,000 for the
largest PR, and cut prose to get there, never the proof.

Leave out:

- the commit list, which GitHub's Commits tab already shows
- a preamble, a `## Summary` heading, "(no ticket)", or praise
- the gate's steps spelled out: "pre-push green at `abc1234`" says it
- how the branch got here, or what was re-run after which commit. The body describes the head.
- a line saying a risk is small. No merge danger means no section.
- a mechanism explained in prose. That belongs to the commit message.

At most one visual, and only when it says the change faster than a sentence: a schema change as a
diff of the column and its CHECK, a module reshaped as the file tree of `modules/{module}/`, a
permission change as the scope ladder it walks.

The proof names its tier, since they prove different things: `bun run test` is hermetic,
`test:integration` and `test:e2e` need a live Postgres, and an e2e pass counts only on a seeded
database. A test that pins the fix is named, with the fact that it failed before. For a visual
change, a screenshot beats both.

Merge danger is for what reverting the PR does not undo:

- a migration, including one whose out-of-order timestamp migrate skips while printing success
- a widened IAM grant, since every session holding it reached more in the meantime
- a regenerated SDK, since consumers compile against it
- a deleted column or a dropped constraint, which takes the data with it
- a stack: which PR merges first, and retargeting to `dev` after

Domain words come from `docs/business-architecture/` and the module's `README.md`. Write "PR #N" or
"issue #N", never a bare `#N`, since the two share one counter. Plain ASCII.

## 5. Assignee and labels come from the repo

```bash
gh api user --jq .login   # for --assignee
gh label list             # the real taxonomy; never invent a label
```

One `type: *` for the dominant change, one `area: *` per app or package meaningfully touched, and a
status label only when earned: a rank or permission-check fix earns `security`, a rename does not.

## 6. Push, create, confirm

```bash
git push -u origin <branch>
gh pr create --base <verified-base> --head <branch> --title "<type>(<scope>): <summary>" \
  --body-file <path> --assignee <login> --label "type: x" --label "area: y"
gh pr view <number> --json title,assignees,labels,baseRefName,headRefName,url
```

Let `pre-push` run. `--no-verify` needs the user's say-so, and whatever it skipped is still owed.
`format` and `fix` write, so read `git status` after a long push.

The final `gh pr view` is not optional: confirm the base, assignee and labels before calling the PR
done.

A later push can make the body wrong: a renamed migration, a "merge PR #N first" that has merged.
Rewrite the body for the new head in the same sitting (`gh pr edit <n> --body-file`), rather than
appending what changed.
