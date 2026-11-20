---
name: code-review
description: "Review a diff against a fixed point on two axes - Standards (does it follow what this repo documents?) and Spec (does it do what the ticket asked?) - kept separate so neither masks the other. Carries the Fowler smell baseline plus the findings that have actually recurred in IRYSS audits. Use to review a branch, a PR, work in progress, or \"review since X\"."
---

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to what this repo documents?
- **Spec**: does the code faithfully implement the originating ticket?

Run both axes inline by default. **This repo's standing preference is no subagents**, so
fan out to parallel sub-agents only when the user asks for it or the diff is too large to
hold at once; when you do, keep the two briefs separate so they cannot pollute each other.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`).
If they didn't specify one, ask.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison
is against the merge-base). Also note the list of commits via
`git log <fixed-point>..HEAD --oneline`.

Confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty
before going further.

**`main` is routinely the wrong fixed point here.** Branches stack on a feature branch, and
`main` has been 150 commits behind the branch every recent PR targeted. The `pr` skill, step 1,
is how you find the real one: check what merged PRs actually based on, then confirm with a
commit count that matches the work on the branch rather than someone else's history.

### 2. Identify the spec source

The issue tracker is **Linear**, reached through its MCP tools. Look for the spec in this
order:

1. An `IRY-` id in the branch name, the commit messages, or the PR body, read with
   `mcp__linear__get_issue`.
2. A path the user passed as an argument.
3. A plan under `docs/business-architecture/`, which is where a module's intended behaviour
   is written down before it is built.
4. Ask the user. If they say there is no spec, the Spec axis reports "no spec available".

A ticket assigned to someone else is still a valid spec to review against. Check `assignee`
before proposing code, because writing it is that person's job.

**Read the plan as it stands on the base, never as the branch edits it.** A plan step rewritten
on the branch to match what was built, by the person building it, is a Spec finding in its own
right. That is how a plan stops being a check: PR #68 rewrote step 5 and wrote a route nobody
asked for into both plan documents. Diff the branch's edits to `docs/business-architecture/`
against the base before using them.

**Read the PR body against the branch.** It goes stale with every push. Check migration names,
"needs #N first", and claims about how a read works.

**A scope wider than the ticket is a one-way door, even when it is deliberate.** An example is
a write authorized at a market where the ticket says company. Flag it for the reviewer's
explicit yes, and check whether `dev` has since answered the same question the other way.

### 3. Identify the standards sources

This repo documents its standards in four places, and they are the authority:

| Source | Owns |
|---|---|
| `CLAUDE.md` | toolchain, imports, test placement, gates, env vars, commits, the comment policy |
| `building-a-module` skill | the order the work has to happen in, the schema and IAM rules |
| `docs/business-architecture/modules/01-commerce-api/patterns.md` | the internal shape every module follows |
| `tdd` skill | which layer a test belongs at, the harnesses, the coverage ratchet |
| `pr` skill | base branch, the commit split, commit message rules |

A module's own `README.md` is the local authority for that module.

**Skip anything tooling already enforces.** Biome is the only linter and formatter, and
`check-types` reads the types, so formatting, import order, unused symbols and type errors
are not review findings here. Report what a human has to notice.

**Read the ledger before the diff.** `docs/mine/pr-audit/README.md` is local and gitignored, so
it may be absent. It lists the finding classes that recur across PRs, with the comment that raised
each and the rule it lives in, the findings withdrawn before, and what is still open. Check its
classes by name, and its open rows against the code under review.

On top of the repo's sources, the Standards axis always carries the two baselines below. Both
are labelled heuristics ("possible Feature Envy"), never hard violations, and a documented
repo standard always overrides them.

#### The local baseline: what IRYSS audits keep finding

Each of these was a real defect here more than once. Match them against the diff first,
because they cost more than the generic smells:

- **Fail-open catch**: a `catch` that swallows and continues, so a refusal becomes a pass. A
  fail-closed catch is deliberate and fine; a fail-open one is a security bug.
- **Hand-thrown ORM error**: `.orNull()` plus a hand-thrown error, or catch-and-rethrow,
  instead of the `errors()` rename table that turns a generated code into a module code.
- **A null for a state nothing reaches**: an `.orNull()` or `?? null` whose null no request can
  produce, so a broken invariant answers as an empty result. Name the request; with none, use
  `.get()` and rename the miss to a module 500. Ruled 2026-10-02, `patterns.md` "Error codes".
- **Drizzle at a call site**: raw drizzle, or a bespoke wrapper around a table (a status
  setter, a filter-scoped list). Widen the ORM instead, never through the query DTO. That
  includes a drizzle relational query (`$drizzle.query.*`, a `relations.ts` that exists only
  for it), which skips the soft-delete rail at every level it nests. It also includes a filter
  hand-writing `exists`, where `has.some` / `has.none` keep the other table's rails, and a join
  condition written as `on.sql(inArray(...))`, where `on.is(column, list)` is the IN. `on.sql`
  stays for a condition neither `eq` nor `is` can express.
- **A route that grants nobody**: a capability no role holds is a dead route that type-checks
  and whose tests pass. Also check `action` then `resource` come first in the decorator
  object, in single quotes, or the coverage test stops seeing the route at all.
- **`unscoped()` with no reason beside it**: it takes the tenant rail off one call, which is
  a decision that has to be written down. A comment saying what the call does is not a reason;
  the reason says why the actor's reach must not decide which rows it touches. "Capabilities on
  routes".
- **A cast that structural typing would have handled**: prefer the structural type, and keep
  an `as X` only where `check-types` proves it is needed.
- **A destructured parameter on a decorated service method**, which makes `ttsc-nestia` panic
  during `bun run sdk` and names no file when it does.
- **A body DTO that is not an `interface`**: a long `Partial<Pick<...>>` prints truncated
  into invalid SDK code and every e2e suite then fails to collect.
- **A test colocated beside its source** rather than in `__tests__/`, which is silently never
  run.
- **A comment that restates the code**, narrates the change, or banners a section. The
  comment policy in `CLAUDE.md` is that most code gets none. A banner per resource in a file
  serving more than one resource is the exception it names, not a finding.
- **In `admin-portal`**: a filter missing `single: true`, and a mutation with no settle after
  it. Those two were the repeated findings of the portal sweep.

The 2026-09-27 backend audit added these. Each is written up, with the incident, in the named
section of `docs/business-architecture/modules/01-commerce-api/patterns.md`:

- **A rule with one door**: an invariant checked in one service while a write elsewhere (another
  module's delete, a grant write) produces the same effect. "One rule, every door".
- **A restore that lifts more than it closed**: a reinstate or re-add undoing a closure it did
  not make, or handing back roles the rank check never saw. "A restore undoes one closure".
- **An unlocked read-then-write**: a transition reading its row without `for update`, a child
  write not share-locking its parent, two writers taking one pair of rows in opposite orders.
  "Locks, and the order they are taken in".
- **A 500 the caller caused**: a duplicate or a CHECK a request can trip, answered `*_FAILED`.
  "Error codes".
- **A vendor's strings from memory**: a CHECK or code list over a vendor's values not read off
  the vendor's own types. "Rules that belong in the database", "Error codes".
- **Reach decided by one side**: an unrailed model's list with no reach filter, a guard and a
  service reading different values, a `.get()` on "the actor's row" with no id. "Capabilities
  on routes".
- **A soft delete that releases nothing**, or a join that keeps the rail on a retired row.
  "Soft delete".
- **A bulk write that skips silently**, answering 200 without the items it passed over.
  "Refuse rather than cascade".
- **One hook, many side effects**: several emits in one `afterCommit` hook. "Events".
- **A client claim taken as proof**: `Host` or another header deciding security alone, a write
  that can raise a trust flag. "Trust".

The 2026-10-01 audit of PR #68, the category tree, added these. A quoted name is again a
section of `patterns.md`; the rest name their source.

- **A `POST` that creates nothing answering 201**: a move, a transition or a revoke with no
  `@HttpCode(200)`. "The three layers".
- **A new child its parent's delete guard does not count**: a foreign key onto another module's
  row, while that row's delete still answers 200 with the child live. "One rule, every door".
- **A foreign module's code crossing**: an `assert*` from another module whose code is missing
  from this module's `rename` table, so a categories route answers `MARKETPLACES_NOT_FOUND`.
  "Reaching another module".
- **A seed that revives or throws**: `onConflictDoNothing` over a partial unique index revives a
  retired row, and a seed reading only live rows throws once an admin retires one. A child hung off
  the id its parent's insert tried, rather than what the insert answered and the read holds, throws
  when a partial unique index takes that insert. A mock test cannot see the first two, so retire,
  reseed with `--force` and count on the test database, since an unchanged seed prints `skipped,
  unchanged`, runs nothing and proves nothing. "Rules that belong in the database".
- **A response DTO written field by field**: a mirror, not a `Pick` off the row type. "Contracts
  are derived from the row". So is a service flattening a joined row into a hand-built view.
- **A route read through private helpers**: `list` and `get` calling a `_hostLocale()` or a query
  builder, a single-caller helper, a `private static`, or two independent reads awaited in turn
  outside a transaction. "A route method reads top to bottom".
- **One rule read two ways**: an inheritance or filter one surface applies and another skips,
  so admin and partner disagree about the same row. "Shared logic goes in `<name>.lib.ts`".
- **Events named nowhere**: a README with no events row and no `domain-events.md` entry, while
  the plan lists them. "Events".
- **An assertion a wrong answer satisfies**: `res.ok && res.data.x` under `.not.toBeNull()`,
  `.toBe(false)` or `.not.toContain()`, and `expect([200, 400]).toContain(status)`. `toContain`
  runs `Array.from(false)`, which is `[]`, so the negative form passes on any refusal. Fix with
  the envelope, and a list that must lack a row as its exact contents. "Tests".
- **A lock, constraint or grant only the mock has seen**: no-op the lock or delete the grant
  line, then run the integration and e2e tiers. Green means unproven. "Tests".
- **Checklist 6.4 not read row by row**: tab, newline, padding, very long, a name carrying
  unicode or SQL, a float or a value past int32, null or an array for a scalar, an id in another
  market, enabling what is enabled, a limit past `PAGE_MAX`, a revoked session. About half were
  missing. `building-a-module` 6.4.
- **Two columns recording one fact with no CHECK between them**, such as `path` and
  `parent_id`. A psql fix to one passes every constraint. Ruled 2026-10-01: add the CHECK, and
  write both columns in one statement, since a CHECK runs after each. "Rules that belong in the
  database"; `building-a-module` 3.2.
- **An indexed text column with no bound**: a btree entry cannot pass 2704 bytes, so a deep
  `path` or a long `handle` is a 500 the caller caused. Ruled 2026-10-02: bound it with a CHECK
  and rename it to a 4xx, as `chk_categories_path_depth` does. "Rules that belong in the database".
- **A justified departure with no reason beside it**: a deliberate break from a rule needs its
  line, or the next reader simplifies it away. `CLAUDE.md` "Comments". First ask whether the
  departure earns its keep: PR #68's one `.orNull()` plus hand-throw was ruled bloat and deleted,
  not commented. "Error codes".
- **A top-level constant in a service, model or controller file**, an `alias()` included. It
  goes in `<name>.constants.ts`, as `categoryChildren` did. "Files".
- **A company-wide write asked at a market**: a route writing a row with no tenant rail, the
  tree, the vocabulary or a label on either, whose `at` is a market or is missing. Ask it at
  `company`. #152 A47 repeated it on a language's status, which a market admin could set for every
  market. "Capabilities on routes".
- **A rename for a CHECK no request reaches**: when the body type is the same closed set as the
  CHECK, the README says so in one line instead. "Error codes".
- **The same claim in two comments**, or in a comment and the README, or a doc comment
  restating the name. Each copy has to be kept true separately. Ruled 2026-10-02: the README
  section keeps the reasoning, and a comment keeps only what its line needs. Also a comment a
  refactor carried onto code it no longer describes. `CLAUDE.md` "Comments"; "Files".
- **A stale number**: a README test count, a `test-map.json` total, a file count. Recount at
  the head from the runner's JSON, as `building-a-module` 7.1 describes; never trust the doc's
  number.
- **`test-map.json` missing the module's files**. `building-a-module` 6.6.
- **A commit body whose reason is false**: when a commit says something failed without it,
  read the file at the commit's parent (`git show <sha>^:<path>`). `CLAUDE.md` "Commits".
- **In `admin-portal`**: a refusal sentence written for a moment the refusal cannot happen in.
  Read the condition that raises the code, not the code's name.

The 2026-10-06 work on PR #152 added these:

- **A lock filtered on the status it guards.** `for share` behind `status = 'active'` holds no row
  in review, so a language went into service under a label delete that had read it as out of
  service. A lock keeping a row from entering a set takes it by key; only one keeping it from
  leaving may filter. Read every `.lock(` whose `where` names a status. "Locks, and the order they
  are taken in".
- **A gate renamed mechanically when a flag became a ladder.** `isActive: true` became
  `status: 'active'` at every gate, so a language being back-filled could take no words and never
  be put into service. Ask of each gate which rungs it means. "One rule, every door".
- **A seed whose row is keyed by an id but whose content is derived from another table**, written
  with `onConflictDoNothing`. The row is frozen at whatever the other table said when it was first
  seeded, nothing fails, nothing warns, and a mock test cannot see it. It takes `onConflictDoUpdate`
  with `sql`excluded.<column>``. "Rules that belong in the database".
- **A foreign key with no computed name, on a model that already has one.** "A row answers the word,
  not only the id" is written down, and `marketplaces` still answered a bare `legalEntityId` beside
  `regionName`. Check the model's keys one at a time rather than whether the module knows the rule.
- **In `admin-portal`**: a detail sheet that can only be opened on a whole row, so a reference from
  another module cannot be followed. `DetailSource` is the documented shape for it.
  `module-structure.md` "Screens".
- **In `admin-portal`**: a msgid whose shape changed, such as a placeholder going from a name to a
  number. `extract --clean` drops the old entry and its translations in every locale, and
  `lingui check sync` still passes; only `check missing` catches it. Restore from `HEAD` rather than
  retranslating. The reverse also bites: `check sync` compares the `#:` reference comments, so using
  an existing string from a new file fails `bun run build` with "out-of-sync catalog file(s)" and
  nothing to fix but a re-run of `bun run extract`.
- **In `admin-portal`**: a reference to another module's row shown as a name with its id beside it.
  The id is noise once the name is there; the value itself is the control, with the eye after it.
  A code is shown only where the code is the name, and then uppercase. `module-structure.md`
  "Screens".
- **In `admin-portal`**: a detail sheet drawing its own uuid in its first card, beside the name and
  the status. It belongs in the closing `Record` card, which `RecordSection` draws from `idLabel`
  and `idCopy`. A code that is what the row is called is not an id and stays where the name is.
  `module-structure.md` "A row's own id is in the record, at the bottom".
- **In `admin-portal`**: a general word naming a narrower surface. A version's content is "words and
  facts"; one language's rendering of it is a translation, and ten files said words. Read which of
  the two a surface holds before naming it. `style.md` "A word names the narrower thing where the
  surface is narrower".
- **In `admin-portal`**: a long value taken off the row grid, as a caps eyebrow over a full-width
  paragraph, a section over one field, or a lookalike of another product's UI. The locale sheet's
  search fields drawn as a search engine's result spent `primary` on a line that is not a link and
  needed a caption to say what it was; it was rejected on sight. A long value is `DetailRow`
  with `block`. `style.md` "A long value stays on the row grid".
- **In `admin-portal`**: `text-muted-foreground` on a sheet's secondary text: a row's icon or
  label, a `None`, a caption, a count. It is `text-accent-foreground`; the 2026-10-11 swap to muted
  greyed every sheet and was reverted on the user's ruling. Do not raise accent's dark-mode
  `0.985` again. Same section.
- **In `admin-portal`**: a refusal translated outside `REFUSALS`: a module function turning a code
  or its issue list into sentences, a toast in `onSettled` behind `meta: { toast: false }`, or a
  branch for a code the server never sends. `REFUSALS` holds the sentence and `placeRefusal` puts a
  field-bound one on its field, as `users` does. `module-structure.md` "A refusal is translated
  once, in `REFUSALS`".
- **In `admin-portal`**: anything but a `use*` hook at the top level of a `*.mutations.ts`: a
  toast, a write helper, an input type. `module-structure.md` "A mutation file is its hooks".
- **In `admin-portal`**: a `select` that re-sorts or re-numbers what the server answered, or a
  predicate named for one comparison (`isEditable` for `status === 'draft'`). A `select` adds only
  what the server cannot answer. `module-structure.md` "A read hands on what the server answered";
  `dead-code.md`.
- **In `admin-portal`**: a hook outside `hooks/<name>.hooks|queries|mutations.ts`, a component
  importing a `.mutations.ts` file rather than the bundle, and a keys factory with an `ALL`
  constant beside it. `module-structure.md` "A module's hooks are in `hooks/`".
- **In `admin-portal`**: a local read once in its scope. Count per scope with comments stripped,
  since a whole-file count missed two dozen; a Lingui placeholder, a hoisted value and the other
  kinds `style.md` "A name read once is the expression" lists stay.
- **In `admin-portal`**: a type alias renaming one SDK type whole, `type Brand = BrandsAdmin.Fields`.
  #152 had twenty. `dead-code.md`.
- **In `admin-portal`**: a shared primitive drawn again: a raw `Switch` in a form, a `Field` trio,
  a second `nonBlank`, a direction ternary, a filter menu written as an array rather than
  `toneOptions` over a tuple, or a test fixture (`refused`) beside the one in `query.fixtures`.
  `reuse.md`, `style.md`.
- **In `admin-portal`**: what a move or a fix leaves behind: a helper whose last caller went, an
  export only its own file reads, a barrel export nothing imports. Run the `dead-code.md` loops
  after every refactor, ours included.
- **In `admin-portal`**: a function that returns its own argument to give it a type, as
  `dataKey<TData>(key)` did around every query key, and the conditional types only it fed. A key is
  a plain tuple; what a write patches is pinned by its test reading the cache back. `dead-code.md`.
- **In `admin-portal`**: a function that only calls another with an argument fixed or passed
  through, such as `retiredSlugsTableConfig(i18n)` for `slugsBase(i18n, true)`, or a lib
  `toUpdateRequest` that is `changedFields` with the keys written in. A boolean choosing between
  two configs is the same thing. #152 A44 deleted nineteen; `dead-code.md` "A function that only
  calls another is the call" has a Check that prints only the ones that stay, but not one whose
  argument is itself a call, which two of ours were.
- **In `admin-portal`**: one `outdated` list in `constants.ts` shared by several writes. Read each
  route's guards and write its own codes in its hook; #152's shared list named codes some routes
  never send and missed two removals. The cache goes back on every error whatever the list says,
  so `outdated` decides only the re-read. `module-structure.md` "The codes are written in the hook".
- **Any Check, in either app**: one that cannot fail, whose grep matches nothing the code writes.
  `style.md`'s header-width Check read `<DataTableColumnHeader>` text while every header is drawn
  from `meta.label`, and printed nothing over 145 columns. Run a new Check on the commit before its
  fix. `portal/README.md` "Running an audit".
- **In `admin-portal`**: a column keeping an accessor only to turn its sort off, on a computed name
  or any value a server table cannot order by. It is an `id` and a `cell`, which TanStack never
  offers a sort for. `module-structure.md` "And where `Intl` cannot answer, the name is a column".
- **In `admin-portal`**: a page arrow reshaping `mutateAsync` to fit a handler type,
  `(id, patch) => update.mutateAsync({ id, ...patch })`. Type the handler with the mutation's
  variables, build them in the table and pass `mutateAsync`; an arrow stays only where the page adds
  what the table lacks. `module-structure.md` "A handler that reaches a memoised config keeps one
  identity".
- **In `admin-portal`**: an `outdated` code only another module's route raises, as
  `PRODUCTS_STALE_VERSION` was on the products writes. A code's prefix names the row, not the route.
  `module-structure.md` "The codes are written in the hook".
- **In `admin-portal`**: a refusal sentence asking for a reload on a code the hook lists in
  `outdated`, so the screen has read itself again before the toast shows. Say what the screen now
  shows. `module-structure.md` "A code the screen reads again on never asks for a reload".
- **In `admin-portal`**: an id standing in for a name where `style.md`'s grep cannot see it: a
  ternary in a cell or a `rowLabel`, or a row menu headed by `getRowId` in a table with no
  `rowLabel`. `style.md` "And never by its id".
- **In `admin-portal`**: a translations table labelling its rows by language code, `fr` for French.
  `style.md` "A language or a country code is shown as the thing it names".
- **In `admin-portal`**: another module's row named through a component reading it per row, as
  `OrganisationName` did, or found by id in a picker's first page, as hosts and invites did. Ask the
  API for the computed name. `module-structure.md` "And where `Intl` cannot answer, the name is a
  column", whose Check prints what is left.
- **Any file, tests included**: a comment copying a rule a patterns doc keeps, such as why a filter
  is `single: true` or that the `MutationCache` toasts a refusal. Each copy goes stale on its own.
  `CLAUDE.md` "Comments".

The fixes that followed PR #68's audit, on 2026-10-01, added these:

- **A second answer to a question already answered**: a filter the tenant rule already applies,
  a literal restating a declared return type, a code only a hand-throw can raise. PR #61 9 and 10,
  PR #68 19. A judgement call.
- **A fix bigger than its finding**: a new helper, branch or test where tightening the existing
  one would do. PR #68 14's first fix was cut back in review to one join and one filter, and a
  redundant test went with it. A judgement call, and it applies to our own fixes too.
- **A module's tables split over per-table model files, or a `#region` pair**: a module has one
  `<module>.model.ts`, and a multi-resource file opens each resource with a banner. "Files",
  `CLAUDE.md` "Comments".
- **A migration timed before one already applied**, which migrate skips while printing success.
  PR #70 and PR #68 each added an `0017`. "Migrations".
- **In `admin-portal`**: a hand-rolled `SheetContent` rather than `StackedSheet` or `FormSheet`.
  `apps/admin-portal/docs/patterns/module-structure.md` "Screens".
- **In `admin-portal`**: a number asked for in a text box (`inputMode="numeric"`), or a `<form>`
  without `noValidate`, so the browser's own bubble answers before the schema's message can. PR
  #108, raised with Omar before review and still open at it. `docs/patterns/style.md` "A number
  is asked for with a number input".
- **In `admin-portal`**: a panel handed a read it could make itself (`locales={...}` down a
  sheet, a `Panels` wrapper feeding one panel while its siblings call their own hooks), and a
  `useCallback` reshaping `mutateAsync` where the handler type could take its variables. PR #108
  S14, PR #69 U13. `module-structure.md` "A panel reads its own data".
- **In `admin-portal`**: a form reading other rows to refuse what the server already refuses,
  which costs a request every time the sheet opens. PR #108 S12. `module-structure.md` "A
  refusal lands on its field".
- **In `admin-portal`**: one field's hint worded differently in its tooltip, its detail row and
  its form. PR #69 U14. `style.md` "A fact reads the same wherever it is shown".
- **In `admin-portal`**: a mutation hook making two SDK calls, a create falling back to an update
  on a refusal. One hook per route; the caller chooses. PR #108 S16. `module-structure.md` "A
  hook is one route".
- **In `admin-portal`**: a read that filters on the flag a row action flips, such as
  `isVisible`, so a row hidden on purpose vanishes and reads as never set, and Hide is faked as a
  delete. PR #108 S17. `module-structure.md` "A row hidden on purpose stays listed".
- **In `admin-portal`**: a table whose first row action writes, so a row click opens a confirm
  or an edit. The first is a View with a detail sheet. Check a shared table keeps the View its
  copies had, and a table inside a sheet too: where the row's subject has a sheet in another
  module, the View opens that one by id. PR #108 S18, PR #152 A23. `module-structure.md` "A row
  opens its view".
- **In `admin-portal`**: an add and an un-hide both called Show, or a confirm that drops its
  object ("Hide"). Add/Remove is membership, Show/Hide is visibility. PR #108 S19. `style.md`
  "A fact reads the same wherever it is shown".
- **In `admin-portal`**: a picker, row label or toast reading `code - name` or the code alone.
  PR #108 S20. `style.md` "A row is named by its name, not its code".
- **In `admin-portal`**: a fixed form value printed as text under a bare `<FieldLabel>`, a
  `readOnly` input, or a `Select` disabled on an edit, which still reads as a choice and shows
  whatever its items render. It is a disabled `Input` in a `FormField` with `htmlFor`, and the
  picker mounts only when there is a choice. PR #108 S21, #152 A41. `style.md` "A fixed value is
  a disabled input".

The 2026-10-02 backend sweep, after the categories label race and the actor columns, added these:

- **An actor column typed `text`**: `created_by`, `updated_by` or any `*_by` on a table we own.
  It is `uuid`; a vendor's `auth_*` or `iam_*` column stays as the vendor wrote it. "Rules that
  belong in the database".
- **A type change with no `USING`**: drizzle-kit writes a bare `SET DATA TYPE`. Read the
  generated SQL for it and dry-run it in a rolled-back transaction. "Migrations".
- **A check keying a read by a raw route param**: the guard runs before the pipe, so a malformed
  id is a driver 500, or a refusal when a ternary skips the read. `assertUuid` first, which
  answers 400. "Capabilities on routes"; `common/iam/README.md`.
- **A request rule inside `common/orm`**: a shape check, a uuid test or a body field read in the
  engine. The ORM knows tables; the pipe and `assertUuid` know requests. "The three layers".
- **Two writers breaking one rule from opposite sides with no lock in common** (write skew):
  each reads the other's table and writes its own. Name the row the other writer locks, lock it
  too in the documented order, and hold each writer open in an integration test. "Locks, and the
  order they are taken in".
- **One cascade written in two surfaces' services**: a side effect copied rather than called
  from the lib, so the copies drift. "Shared logic goes in `<name>.lib.ts`".
- **A surface reading another's answer**: a marketplace read selecting `admin`, calling an admin
  service or deriving its DTO from an admin one, and an admin read leaving out a column that is
  not a secret. "A surface folder is named for its audience".
- **A surface service holding its own whole answer**: the column list a `marketplace/` or
  `storefront/` read returns, written at the call site rather than named `$marketplace` or
  `$storefront` in the model. A guard read and a nested one-column join stay literals. Check the
  newest module first: `brands` and `products/marketplace` both landed after the sweep that set
  this rule and both missed it. "A surface folder is named for its audience".
- **In `admin-portal`**: a table or sheet naming an actor with no date beside it, and a comment or
  test saying a row "carries no timestamp". Every admin row answers both dates, so that claim is
  stale wherever it still appears. `docs/patterns/style.md` "An actor is named beside its date".

The 2026-10-04 audit of PR #107, the product and its words, added these:

- **A comment citing a decision number, a chunk, a ticket or a date**: `// Decision 9:`,
  `per decision 12`, `chunk 4's variants`. It is bookkeeping, it goes stale, and the plan is the
  name of record for a numbered decision. The comment states the reason its own line needs, and the
  README or the plan keeps the cross-reference. `CLAUDE.md` "Comments".
- **A company route whose rows are staff-only with no `at:`**: a company-source route is asked at
  every scope the actor holds, partner scopes included, so `admittedStaffScopes` is what keeps a
  partner role out of a staff-only read. "Capabilities on routes".
- **Do not raise a session-to-host binding.** The host registry is the audience gate:
  `SERVED_BY` and `hostResolverMiddleware` serve a path family from its own applications only,
  answering anything else with the same 404 an unregistered hostname gets, and a cookie cannot
  cross hostnames. Withdrawn on #107 S3 after an issue and a ticket had been opened for it. Read
  `SERVED_BY` and the `viaHost` cases in `partner-door.e2e.test.ts` first.

The 2026-10-04 audit of PR #152, the brands, products and versions screens, added these. All
are `admin-portal`, and each names the portal pattern document that now carries it:

- **A write whose `outdated` is `true` rather than a list of codes**: every refusal then
  invalidates every key the write names, so a routine content refusal or a 403 costs four reads a
  refusal cannot have changed. `outdated` names the codes whose own sentence says the screen was
  read before someone else's write landed. `module-structure.md` "A refused write reads nothing
  again".
- **A form that holds its own submit on a rule the server applies later**: filing a category is
  refused for content only after the first approval, so a browser copy of the rule locked the
  operator out of the step that comes first, and cost five reads per open to do it. The stronger
  form of the pre-check class. `module-structure.md` "A refusal lands on its field".
- **A row labelled by its id**: a `rowLabel`, a cell, a toast or a confirm sentence falling back
  to a uuid (`product.brandReference ?? product.id`), so a confirm asks about `0192f3a1-...`. Fall
  back to something a person can read. `style.md` "A row is named by its name, not its code".
- **A write that moves a counter another module shows, and names neither `refresh` nor `stale`**:
  a product create moves its brand's `productCounter`, which the brands table has a column for.
  `module-structure.md` "A write another module shows reads that module's key again".
- **A button whose seam can never answer**: a translate call that returns nothing for every
  language in the shipped app, mocked to answer in its tests, so the only reachable behaviour is
  the warning. Delete the button, not the warning. `dead-code.md`; baseline "A rule proven only
  against the mock".
- **A counter a write determines, held in a provider and read back**: an optimistic-concurrency
  number carried in a React context with a refetch in `onSettled`, so every write costs a second
  request for a number it already decided, the module cannot mount without the provider, and a
  second quick write sends the old value. The write patches the row it moved instead, through a
  second `writeRows` write on that row's own key. `module-structure.md` "A counter a write moves is
  patched, not read back".
- **A documented grep narrower than its rule.** Two Checks printed nothing while the breach was
  in the diff: `inputMode="numeric"` against an `inputMode="decimal"`, and `.queries'` against a
  read imported from another module's barrel. When a finding slips past a Check, widen the Check
  in the same pass; it is worth more than the finding.

The 2026-10-05 fixes to PR #152's sheets, asked for after the review, added these:

- **A row that carries an id and no word**: a list whose reader has to read one row per id to print
  a name, and fetches a whole category or a definition's whole vocabulary to do it. The route
  answers the name on the row, as a `Pick` off the related row type under the relation's own key;
  the catalogue stays where it is picked from. An embed built in SQL names its keys inside the
  `json_build_object`, which no mock test can read, so its key list is an integration assertion.
  `patterns.md` "A row answers the word, not only the id"; `portal/module-structure.md` "A row
  carries the name it shows". Where the same type is what a write answers, it is a computed column
  rather than a join: RETURNING has one table in it, so a joined name is on the list and missing
  from the `update`. The screen's column then says `enableSorting: false`, because `_sort` drops a
  term naming anything but a real column.
- **A whole reference table read client side to name one row**: `RegionName` fetched all 200 regions
  on every marketplaces list load, and a row whose id is not in the first 200 reads Unknown. Add the
  name to the API row; keep the id-only component for the surface that genuinely has nothing else.
  `portal/module-structure.md` "A panel reads its own data".
- **A name read from the server that `Intl` already knows**: a locales or regions read to turn `de`
  into German on a screen that only displays it. `displayName` and `localeLabel` answer offline,
  and the catalogue read answers a different question - which languages may be offered - that only a
  picker asks. `portal/module-structure.md` "A row carries the name it shows". The same holds for a
  code handed down beside its row (`locale={byCode.get(code)}`, `language=`), which makes every
  table of labels hold the catalogue, and for a country printed as `<span className="uppercase">`:
  `countryLabel` names it. The code shows only where the code is the subject.
- **A claim inferred from a catalogue's absence**: a "No longer offered" badge drawn because the
  offerable read does not hold the row, which is also what a code the platform never had and a
  catalogue still loading look like. Either the route says the language was retired or the screen
  does not claim it. `portal/style.md` "Copy says only what is true".
- **A reference read in the panel that mounts the picker**: `useLocales` in a translations panel so
  the table knows whether to offer an Add, or a count of what is left in a read-only panel's title.
  The request then fires when the sheet opens, for a button or a badge. The read goes inside the
  picker, which mounts when the operator opens it, and the picker says there is nothing left rather
  than the panel paying to hide the action. `portal/module-structure.md` "A panel reads its own
  data".
- **A sheet reading the row it was opened on**: a panel re-reading `get(id)` for one field of the
  row the list handed it. Seed the query with the row (`initialData`), so a write still refetches by
  invalidating the key, and gate the read off entirely where the panel offers no write.
  `portal/module-structure.md` "A sheet opens on the row".
- **A detail row whose height is its value's**: `DetailRow` with no floor renders a line of text at
  40px, a `ToneBadge` at 42 and an id with a copy button at 48, so one card has three row heights.
  `min-h-11` on the row; a value too tall for one line is not a `DetailRow`. `portal/style.md` "A
  card's rows are one height".
- **A tree drawn with a computed indent**: `paddingInlineStart: base + depth * step` over a flat
  list, so nothing in the markup says a link is under another and a screen reader reads siblings.
  The child goes inside its parent's `li` under one shared guide line, in the read view and the
  editor both. `portal/module-structure.md` "A tree is drawn nested, not indented".
- **A thing the shopper will see, shown as the fields it is stored as**: the storefront menu as 17
  label-and-target rows. Draw it as they will meet it, with the component this app already ships
  for it - a menu is `NavigationMenu`, not a bar and a grid built by hand - inside
  `PreviewPanelDialog`, which zooms, pans and opens full screen. The fields belong in the editor.
  `portal/style.md` "A thing the shopper will see is shown the way they will see it".
- **A preview whose chrome floats in two corners, or whose caption sits outside its frame**: use the
  `actions` slot for the caller's button and the `footer` for the caption. Same section.
- **Half a shared component**: its trigger used and its panel drawn by hand as a `div`. The hand
  half gets none of the behaviour and drifts when the shared one changes. Same section.
- **A preview frame sized by its content**: opening a bigger branch pushes every section under it
  down the sheet. Fix the height and scroll inside it. Same section.
- **A sheet named for one of the things it writes**: a `PUT` carrying two fields is one document,
  so a sheet titled for the half the operator came for saves something its title never mentions.
  `module-structure.md` "A sheet is named for what it saves".
- **One fact read in one section and changed in another**: a badge in an Overview card whose switch
  lives inside another section's editor. Same section.
- **A create or edit sheet at its own width**: it is `sm:max-w-2xl` in every module, and wider only
  for a sheet holding a table or an editor. `module-structure.md` "A sheet is one width".
- **A preview that opens itself, or wears a frame the real screen has not got**: a branch held open
  on mount shows one part as though it were the whole, and a bordered box the shopper never sees
  reads as an empty card. Open nothing, and give a surface only to what the shopper sees. Same
  section.
- **A pan-zoom surface inside a scrolling sheet that is not locked**: the wheel zooms and
  `preventDefault` swallows the scroll, so the sheet stops moving. `defaultLocked`, with the state
  read through a ref inside the listeners so a toggle does not re-subscribe them.
- **Seed data hand-written beside the table it describes**: a storefront menu of 117 words in nine
  languages next to a catalogue of 485 already-translated categories. Derive it, and if the derive
  would close an import cycle, move the derived rows into their own module rather than reaching
  back - a cycle through a module whose constants evaluate at import is a `ReferenceError`.
- **A section that becomes its own editor**: an Edit button swapping a read-only view for a form in
  place, with its own Done and Discard buttons, so one click throws an edited draft away. A write
  opens a `DraftSheet`, which is what every other write in this app opens into and what brings the
  dirty guard with it. `portal/module-structure.md` "Screens".
- **An embed joined where the answer is assembled elsewhere**: a join cannot name what a frozen
  snapshot holds. Read the names after the content is assembled, `withDeleted()`, so a row that
  named something since retired still says what it named - and prefer `leftJoin` to `innerJoin`,
  which answers a retired row by dropping its parent out of the list. `patterns.md` "A row answers
  the word, not only the id".
- **In `admin-portal`**: a cell drawing more than one badge, which reads as one fact wearing two
  labels and pushes the column past its `w-*`. `ToneBadges` shows the first and `+{count}`.
  `style.md` "A cell shows one badge and a count".
- **In `admin-portal`**: a second column left with no `w-*`. The table is `table-fixed`, so the
  unsized ones split what the sized ones leave: a column added with a width takes room from every
  column without one, and two of them in a sheet render at 60px with their headers overlapping.
  Size all but the flexible one, and count the total against the sheet the table opens in.
  PR #152 A23. `style.md` "A column is as wide as its header".
- **In `admin-portal`**: two panels on one sheet answering the same question, such as a `Slug`
  column in the words table above a table of those slugs. Each panel has one job.
  `portal/module-structure.md` "A sheet's sections run in the order the operator asks them".
- **A column labelled for a thing the row is not**: `SKU` over a product's number, when a SKU
  identifies what ships and that is a variant. `style.md` "A column is named for the fact in its
  cell".
- **In `admin-portal`**: a form mounted where nothing is written. A table whose rows are the
  questions rather than the answers - a row per linked definition, stated or not, Required beside it
  - belongs to the sheet that writes them, and a read-only mount hands a reader a checklist of empty
  rows and pays the reads behind it. A component whose `editable` prop is false at every call site
  but one has a mount that should not exist; delete the mount, keep the row's own state as the gate.
  `portal/module-structure.md` "A form is mounted where the writing happens".

The 2026-10-06 replacement of the per-market language list, PR #152 A30 to A32, added these:

- **A platform-wide rule asked one tenant at a time**: a completeness check that takes the tenant as
  a parameter and narrows one of its surfaces to it, because the tenant is the row being written.
  `marketplaceLocales._assertCatalogueServes` asked whether the catalogue read in a language, with
  the categories narrowed to `shownIn` the market and products not asked about at all, so a market
  could offer a language no product was named in and the refusal answered 200. When the fact is
  true of the platform, hold it once and leave the tenant only the part that is genuinely its own:
  a per-market default is a `NOT NULL` column with a foreign key, not a flag on one of many rows
  under a partial unique index. `patterns.md` "One rule, every door".
- **A transition table with no earned rung, or an earned rung that counts outside its own lock**:
  the ladder is a `Readonly<Record<Status, readonly Status[]>>`, and a rung the row has to earn
  counts inside the transaction that holds the row under `lock('update')`, or a label written
  between the count and the write is not counted. One line at the gate says what earns it.
  `patterns.md` "Locks, and the order they are taken in".
- **A mirrored constant table with no test tying the two halves**: the portal's `LOCALE_NEXT`
  mirrors the API's `LOCALE_TRANSITIONS` by hand, so the screen offers what the server allows. The
  drift is a bug in the copy, not a hole in the server, and the README says which direction it runs.
- **In `admin-portal`**: a `writeRows` declaration with neither `where` nor `reread` on a write that
  answers an existing row. `writeRows` reads that as a create and `place` appends the answer to a
  list held whole, so a status write shows the row twice, once under the value it has just left,
  and the `refetchType: 'none'` on `keys` never corrects it. `portal/module-structure.md` "A write
  that moves a row between lists reads them again".
- **In `admin-portal`**: a row-action condition no row can fail, such as a reachability check over a
  table whose every entry is non-empty. It reads as care, it is dead, and the README sentence
  written to explain it describes a state the data cannot hold. `portal/module-structure.md` "A
  branch no row can reach is not a guard".
- **A test that passes because the fixture withholds the thing it names**: a row-actions assertion
  built from a config constructed with no write handler, which then reads as a check on a write it
  never saw. Build the fixture both ways, and name in the test which one each case is.
  `patterns.md` "An assertion a wrong answer satisfies".

The 2026-10-06 rename of `storefrontConfiguration`, PR #152 A33 to A34, added these:

- **A response DTO that accepts a column on a write and does not answer it on a read**: the field
  is in `CreateRequest` and `UpdateRequest` and missing from the `Pick` that is `AdminFields`. No
  test on either side fails, because the API's own suites never read the row back, and the defect
  surfaces as a portal reading a field the SDK has no type for. `patterns.md` "Contracts are
  derived from the row".
- **A fixture whose import is unused**: a value put in a request body while the call that seeds its
  foreign key was never added. Biome's `noUnusedImports` is what reports it, so an unused import in
  a test is read as a half-applied fixture rather than a tidying job. PR #152 A33.
- **An assertion naming a column `check-types` cannot check**: `apps/marketplace-api` mocks its
  database, so a row in a test is a literal the test wrote, and a dropped or renamed column leaves
  every such assertion green. A column rename is grepped through the mocks by hand.
  `patterns.md` "Tests".
- **A table rename generated rather than written**: drizzle-kit prompts to tell a rename from a drop
  and a create, so it writes nothing without a TTY, and the wrong answer to that prompt is a `DROP
  TABLE` that passes every gate. Hand-write the `RENAME`, build the snapshot from the previous one,
  and prove it with a `generate` that reports no changes. `patterns.md` "Migrations".
- **A rename that stops at the names we chose**: Postgres keeps `<old>_pkey` and each
  `<old>_<column>_not_null` when the table is renamed, and those are the names its errors print.
  drizzle's snapshot tracks neither. `patterns.md` "Migrations".
- **In `admin-portal`**: a changed msgid with no catalogue behind it. The portal's build is
  `i18n:check && vite build`, so `lint`, `format` and `check-types` all pass and `build` is what
  fails; one new string is 43 translations the gate then requires. Renaming a type is free, renaming
  operator copy is not, and they are separate decisions.
- **A skip list written as a directory name**: a rename or codemod that excludes `locales` to
  protect the catalogues also skips every module of that name, and the miss looks like a file the
  script simply did not reach. Exclude the path, not the component. PR #152 A34.

The 2026-10-06 test round on PR #152, A47, added these:

- **In `admin-portal`**: a key named in both `keys` and `refresh`, such as `localesKeys.list()`
  beside `localesKeys.all`. Each marks the list on screen for a read, so one write fetches it twice
  and the second request cancels the first; only a test counting the `queryFn` calls sees it.
  `portal/module-structure.md` "A key is named once".
- **In `admin-portal`**: a msgid placeholder written as a property access. `${current.slug}`
  extracts as `{0}`, which `copy.test` refuses and a translator cannot read. `portal/style.md` "A
  name read once is the expression".
- **In `admin-portal`**: a date taken at module scope, a top-level `const` holding `new Date()`,
  `Date.now()` or a series built from either. A server keeps its modules past midnight, so its page
  differs from the browser's and hydrates mismatched; 24 charts files did this until A47.
  `portal/rendering.md` "The clock is read as the page renders, never as a module loads".
- **In `admin-portal` Playwright**: a seeded row read off the first page of a list. A fitted page
  shows five rows, and a reseed or a run's own rows push a seeded one past it, so the test fails
  for a reason the code never had. Search for the row first. `portal/tests.md` "A seeded row is
  searched for".

The 2026-10-07 comment pass on PR #152, A48, added this:

- **A test comment copying the comment at the code it tests**, usually reworded. The test's name
  says what it pins, and the reason stays at the code. A read by eye compares a test comment with
  its own test and passes these: A46 read every one, and A48 then found 44. `portal/comments.md`
  has a Check that matches words rather than lines.

The 2026-10-10 review of the translation create split, and the round-trip pass after it, added these:

- **A write that reads back the row it wrote**: an insert selecting `only: ['id']`, the rows
  around it written, then a `get` of the same row to answer it, although nothing changed it. The
  write selects the set its route answers, and a column its RETURNING cannot see yet is spread from
  the value just written. `patterns.md` "A write answers its own row".
- **A write answering more than its row**: a count of what it moved, or the rows it touched beside
  its own, read only by tests. Ask what reads it; with no screen or consumer, the row is the answer.
  `patterns.md` "A write answers its own row".
- **A row locked or read only to compare its version**: a `.lock('update').get()` of `version`, a
  compare in code, then an update by id. The version goes in the update's `where`, and no row
  answered is the refusal. A status gate that answers the row when it already holds, as `archive`
  does, and a guard that reads only on a miss are not this. `patterns.md` "A version check rides in
  the write".
- **A parent read only to prove it exists**: a `.select({ only: ['id'] }).where({ id }).get()` of
  the parent, then a `list()` of its children, two statements for one answer. The list is the
  parent's `get` with a `joinMany`, and its NOT_FOUND is the 404; one child the parent scopes joins
  it in the same read. A parent read only when the list comes back empty, where the engine has no
  join for the shape, and a reach check before an unscoped engine call are not this. `patterns.md`
  "A child list reads through its parent".

The 2026-10-11 audit of PR #206, the storefront product page, added these:

- **A mock that is not JSON its queries import**: in any app, a mock is JSON files in the
  module's `data/` folder, photos as links, and each `queryFn` returns its import. Flag fetch
  functions or a `.fixtures.ts` between the two, images downloaded into `public/` (which ship with
  every build and stay in history once merged), a component importing the mock rather than a
  query, and a cast on an import whose type should check it. List `public/` and grep for the
  mock's imports. Whose content a mock holds is the user's call: #206 cloned the reference on their
  instruction.
- **A section built as fixed children or as copies**: any of these, where the ticket asked for
  slots or for one component with a prop:
  - a layout rendering, as its own children, the sections the ticket asked to be slots;
  - nested settings standing in for those slots;
  - N sections over one component;
  - a section importing a neighbour's id.
  Read each ticked item against the code, not against the checklist.
- **Offer data as page props**: the seller, a delivery estimate or a return window as a section prop
  with a default. They belong to the offer, per variant (`05-b2c-marketplace.md` section 5), and the
  default ends up claiming who sells every product.
- **Money formatted with a fixed exponent**: `amount / 100` whatever the currency. 39 seeded
  currencies have no minor unit and 6 have three. The exponent is the currency's `decimal_digits`.
- **A count without a plural**: `{count} items` in a message. Use `<Plural>` or `plural()`; Arabic
  has six forms.
- **A context holding what a query already caches**: a provider wrapping a page so its sections can
  read a row the route's `useSuspenseQuery` already holds. The hook reads the cached query, and no
  section needs a provider to render. #206 S8, the class of #152 S9.
- **Client state in a context**: a provider holding what the server never sees, a picked size, an
  open list or a basket before there is a cart API, often keyed to reset and carrying a callback in
  a ref. The repo's client store is zustand: a store keyed by what the state belongs to, holding
  intents rather than callbacks. #206 S9.
- **A type in the namespace that one file reads**: a module's types file naming every shape, most
  with one reader or none, or one shape under two names (`Crumb` and `Site.Link`). The file holds
  the read's answers, shaped as the API will send them, and what two files share; a part is read
  through its answer, `Product.Summary['price']`. Grep each `Namespace.Type` for files other than
  the types file, the fixtures and the tests. #206 S10.
- **One derivation in several components**: the same template or test written in each file that
  needs it, as a product's name in five and a sold-out `every` in two. It is one helper in the
  module's lib. #206 S10.
- **Motion unlike the reference**: where a ticket copies a reference's behaviour, tally every
  `transition`, `duration-`, `ease-` and `delay-` class the diff adds. Flag several timings on one
  interaction, a property that changes outside its transition list and snaps, `ease-in` on a
  hover reveal, and no `motion-reduce:`. A screenshot cannot show motion, so the check is against
  the live reference. #206 P13.
- **In `storefront`**: a hook outside `hooks/` or a store outside `stores/`, as in the portal, and a
  page section the ticket numbers placed among the shared pieces in `components/`. #206 S9, S10.
- **In `storefront`**: site copy kept as plain fixture strings and printed raw. No catalogue holds
  them, and `i18n:check` cannot see them, so grep the catalogues for the strings themselves.

The 2026-10-18 audit of PR #154, variants and the marketplace SKU, added these:

- **A child write asking the parent's `create` or `delete`**: adding or removing a row that is
  part of its parent (an axis, a value, an identifier, a slug, a filing) asks the parent's
  `update`. A variant is what is sold and takes its own `create`, `disable` and `delete`. Read
  each nested write's `action` against the plan's route table; `grantCRUD` hides the mistake
  until a role holds one action without the other. `patterns.md` "Capabilities on routes".
- **A delete that retires what the plan says it refuses on**: a delete that cascades a dependant,
  or refuses only one status of it, where the plan refuses while any live one names the row. An
  archived child is live. `patterns.md` "Refuse rather than cascade".
- **A transition reached through another write with no event**: a soft delete that archives, a
  cascade that disables, so the archive happens without the `*.archived` its listeners wait for.
  Read the status the row had before the write; RETURNING shows it after. `patterns.md` "Events".
- **A PR hunk restoring what dev corrected**: a branch built on a fix that carries the older line
  back, so its diff against the base reverts dev. Check every `+` line against the lines
  `git log -p <base>` removed; the merge looks clean and nothing fails.

The 2026-10-25 audit of PR #227, the file and reference schema, added these:

- **An either-or over two CHECKs that a rename re-sorted**: Postgres tests a row's CHECKs in name
  order, so a test accepting the wide CHECK or the narrow one holds only while the wide one sorts
  first. After a rename it may not, and the either-or then passes with the narrow CHECK missing.
  Sort the names again after any constraint rename; where the narrow one sorts first, assert it
  alone. `patterns.md` "Tests".
- **A ticket item deferred to a later PR that does not build it**: "the gallery adds it back with
  its reader", while the gallery PR on the same stack says it has none. Read the PR a deferral names
  before withdrawing it as a decision with its rationale. Baseline "A commit body whose reason is
  false".
- **A column a decision already placed elsewhere**: a `jsonb` on a link row carrying a field the
  plan keeps in another module's reviewed words, such as alt text. `building-a-module` 3.1, "Every
  column earns its place".
- **A plan section replaced by a pointer at the code**: the model block a ticket points the code at,
  deleted for "see `files.ts`". The plan then describes the build and checks nothing. Step 2's plan
  rewritten on the branch, in its strongest form.

The 2026-10-26 clean-up of PR #304, the S3 adapter and the file-objects queue, added these. Each
was the user's ask on the branch:

- **A vendor's name on an interface**: `infrastructure/bunny`, `BunnyStorage` and `BUNNY_*` for an
  adapter that speaks S3. A vendor fact keeps the vendor's name. `patterns.md` "An adapter is named
  for what it is".
- **One module's prefix spelled two ways**: `TRANSLATION_JOB` beside `TRANSLATIONS_QUEUE`, or a
  queue over `file_objects` naming its constants `FILES_*`. Same section.
- **An off switch on a subsystem the app needs**: a `*_WORKER` flag, a provider value `off`, a
  constructor that throws unless a variable enables it, a providers list read off env. The
  variable picks a provider; one capability stopped for an incident is plan 17's decision 21 and
  stays. `patterns.md` "The env is one nested type".
- **An env shaped by hand**: camelCase keys over the variables, a `groups` list, a helper that
  validates one group apart from the rest. A group is a key of the one nested type. Same section.
- **A miss answered as a sentinel**: an adapter method answering a missing object as `false` or
  `undefined` through a `.catch()`, or carrying no `@Throws`. `patterns.md` "Error codes".
- **A transient-failure test our own bug passes**: an errno match such as `/^E[A-Z_]+$/`, which
  Node's `ERR_*` codes pass too, so our bug answers as the provider down. Same section.
- **A comment claiming what a vendor does that no probe or test shows**. `CLAUDE.md` "Comments"
  keeps a measured fact.
- **A new adapter copied from its neighbour, faults and all**: match `infrastructure/translations`,
  and raise where it is wrong rather than copying it.

The 2026-10-27 backend sweep for bloat and spacing added these:

- **A name read once**: a local, or a module-level `const` only one function reads, such as a
  provider only `@Module` lists. Count per scope with comments stripped. Before raising one, check
  whether it is one of the kinds that keep their name. `patterns.md` "A value lives where it is read".
- **A method's phases run together**: a lock, a read, a check and a write with no blank line
  between them. `patterns.md` "A method's phases are spaced".

The 2026-11-01 render audit of every admin-portal page and sheet added these:

- **In `admin-portal`**: a form root that reads `isDirty` or `isSubmitting` for its footer. Either
  one renders every field again when it flips, 840 components for the host form's first edit. The
  form hands `FormSheet` its `control`, and the footer reads both. `portal/performance.md` "A
  form's state is read by what draws it".
- **In `admin-portal`**: a `watch()` at a form's root on a field the operator types into, which
  redraws the whole form a letter. The part that draws the value watches it with `useWatch`. Same
  section.
- **In `admin-portal`**: a `React.memo` row handed an array or object its parent builds each
  render, with no comparator that compares it by value, or a memoised row whose handler builds the
  next state from its own props, which edits a stale copy once the row skips a render.
  `portal/performance.md` "A memoised component takes fields".

The 2026-11-06 render audit of opening and closing a sheet added these:

- **In `admin-portal`**: a form body behind its memo reading through the root: `form.watch`,
  `form.formState`, `useFormContext().formState`. It goes stale with no error and a same-props
  `rerender` cannot see it, so read the body rather than trust its test. `portal/performance.md` "A
  form's host calls `useForm`, and a memo holds the form".
- **In `admin-portal`**: a `useForm` whose body is not a memo, so its mount redraw draws every field on
  each open, or a host holding state its body draws. A seat the body does not draw is the state a
  host may hold. Same section.
- **In `admin-portal`**: a bare `clearErrors`, which tells every reader of the errors with nothing to
  lift. `liftError`. Same section.
- **In `admin-portal`**: a raw `Select`, `DropdownMenu`, `ContextMenu`, `Popover` or `Combobox` where
  the lazy ones exist, or a sheet or alert dialog drawn closed on a row. `portal/performance.md` "A
  closed overlay is its trigger alone".
- **In `admin-portal`**: a subscription above a memo that blocks it. A preference subscribed to above
  `RowCells` left dates stale behind Settings, and nothing failed. `portal/performance.md` "A row's
  colour draws no cell".
- **In `admin-portal`**: a read at a sheet's root that one panel draws, or a flag whose only reader is
  one button and its sheet held at a section's root. Check that a read moved down still reaches
  Refresh. `portal/performance.md` "A read or a flag sits in the leaf that draws it".
- **In `admin-portal`**: a draw-count test that cannot go red: a table with a new `useCan` check per
  render, or a barrel mock losing to an import cycle and counting 0. `portal/tests.md` "A draw count
  proves a memo".
- **In `admin-portal`**: a row or a cell reading `useDataTableQuery`, which moves on with every keystroke
  and page turn. `portal/performance.md` "A row is held through a search and a save".
- **In `admin-portal`**: a memo comparator that drops something a draw reads. Holding a row by `original`
  left a hidden column's cells on it, and only a table test with a stable `useCan` could see it. Same
  section.
- **In `admin-portal`**: a library mounted by the event it answers, tested with no
  `{ wrapper: StrictMode }`. The second pass cancels a timer set during that mount, in dev alone, so a
  first-hover tooltip does nothing while every test passes. `portal/tests.md` "The client runs under
  Strict Mode, and a test does not".

The 2026-11-02 audit of PR #317 to PR #320, account mail, added these:

- **A catch-all over a union**: a `default`, a last `else`, a chained ternary or a
  `Partial<Record<...>>` taking union members the code never names, so a member added later is
  served as whichever case it falls into. Every member is named and checked by a type, never a
  branch: no `default` where every case returns and the return type refuses `undefined` (so not
  `async` over `Promise<void>`), the rest typed where a `switch` falls through, a table a whole
  `Record`. A `default: x satisfies never` is a branch no test reaches. A
  two-member yes-or-no stays a ternary. `patterns.md` "A union is handled member by member".
- **One accessor called once per field**: `requestContext()?.marketplaceId` on one line and
  `requestContext()?.defaultLocaleCode` on the next, or `span?.spanContext()` twice. One destructure,
  `const { a, b } = requestContext() ?? {}`. `patterns.md` "A value lives where it is read".

The 2026-11-03 audit of PR #198, the stock mirror, added these:

- **A route contract outside its surface's dto**: a query, body or answer named in
  `<name>.types.ts`, or one namespace serving both surfaces, and no dto beside the controller.
  `page-query.e2e.test.ts` reads the dto beside every controller, so a missing one fails the whole
  sweep at collection. A shape a root service builds may stay in `.types.ts`, aliased by the dto.
  `patterns.md` "Files".
- **A surface split across two controllers**: a second admin controller for one more resource of
  the module, where the surface is one controller with a banner per resource. `patterns.md` "Files".

The 2026-11-04 review of PR #321, which organisation owns a brand, added these:

- **A plain `tx` call inside a transaction**: `tx.<model>` on a chain with no `.lock(`, or
  `tx.afterCommit`, where `this._db` joins the transaction on its own, in a callback or a method
  alike; and a helper typed `tx: OrmTx` that does not lock. One client either way, so no test or
  type check catches it. Only a static or free function that locks, which has no `this._db`, uses
  its one handle for the rest, and where its lock and its write can be two statics they are.
  `patterns.md` "Locks, and the order they are taken in".

The 2026-11-05 audit of all 14 admin-portal screens not yet read, against what each route and guard
does, added these:

- **A permission answer wider than the route**: `useCan` saying yes from any scope held, on a route
  asked only at the company. A market admin was offered writes that ended in a 403. Read the
  route's `at` beside the gate, and `companyOnly` in `app.checks.ts`. Likewise a form shown to a role
  whose grant the route refuses, as Account was to support and read-only.
- **A write with no word on what else draws its row**: a rename leaving the old name on another
  module's screen, a delete releasing rows another list still shows, a self-edit leaving the session's
  copy and so the sidebar old. For each write, list every module whose row carries the name, a count or
  a readiness worked out from it. `module-structure.md` "A write another module shows".
- **A column search cannot find**: read the `search` function or `q` columns against what the table
  draws, labels and joined names too, not the raw key. Four screens had one; a session's person takes
  `searchVia`.
- **A refusal saying the row is gone that puts the row back**: `*_NOT_FOUND` not in `outdated`, so the
  rollback restores what the sentence calls ended. `module-structure.md` "A refused write".
- **A delete dialog naming what the guard does not count**: read the tables the service counts, not
  the module's habit. The market dialog said locales, unchecked, and left out categories, checked.
- **A queue holding a row nobody can act on**: an overdue filter counting a frozen row, which then
  stays overdue for ever.
- **A form offering from the live row**: a re-read moving the row under an open sheet, so it submits
  a step no longer on offer. Offer from the row the form opened on.
- **One permission pair shared by routes with different reach**: a company-only route and a market
  route asking the same `action` and `resource`, so the map cannot answer for both and the screen is
  offered what one of them refuses. The route takes its own action, held by the same roles.
- **A computed column tested only on a direct read**: a stored column the vendor's table does not
  declare answers there and fails with 42703 through a join, since a joined model is a sub-select of
  the declared columns. Unit tests cannot see it. Run every set holding it through the read that embeds
  it. `common/orm/README.md` "Computed columns".
- **A computed name on a read with no actor**: `rails.from` keeps the other model's tenant rule and
  `.unscoped()` on the outer read does not lift it, so the read raises `<MODEL>_NO_MARKET`.
- **A person picked from one page**: an action able to reach anyone reads `personReferenceSource`,
  which searches the server. `Picker` holds one page, and the 201st person is not offered.

The 2026-11-05 audit of PR #164, offers and prices, added these:

- **A route that prints badly in the SDK**: a hyphen in a path, which nestia prints as `_`; a method
  repeating its path or saying more than it, so the accessor reads
  `identity.revoke.revokeAllForIdentity`; `:id` beside `:productId` in one controller; `_query` on a
  parameter. Run `bun run sdk` and read the accessors. `patterns.md` "Files".
- **A source-parsing e2e a moved controller walks out of**: `page-query.e2e.test.ts` matched
  `@Controller('admin/<x>')`, so merging a module under `@Controller('admin')` dropped its list and
  nothing failed; `admin/stockAllocations` had already escaped the same way. When a controller's
  base moves, grep the tests that read source.
- **A computed column typed non-null that a request can empty**: a scalar subquery is `SQL<string>`
  in the type and NULL once its row is gone, and the response check then fails the whole list, so one
  row takes the screen down for everyone. Deleting a draft product with a flagged translation does it
  to `ownerNameOf` on `admin/translations/failures`. Name the request that empties the subquery; with
  one, type it nullable.

#### The generic baseline: Fowler's smells

From _Refactoring_ ch.3, for anything the local baseline does not cover. Each reads *what it
is* -> *how to fix*:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. -> rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. -> extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. -> move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). -> bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. -> give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. -> replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. -> gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. -> split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. -> delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. -> hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. -> cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. -> drop the inheritance, use composition.

### 4. Run the two axes

**Standards brief**: report, per file or hunk, (a) every place the diff breaks something the
sources in step 3 document, citing the file and the rule; and (b) any baseline finding, named
and quoted. Distinguish a documented breach, which can be hard, from a baseline finding,
which is always a judgement call. Under 400 words.

**Spec brief**: report (a) requirements the spec asked for that are missing or partial;
(b) behaviour in the diff nobody asked for; (c) requirements that look implemented but look
wrong. Quote the spec line for each finding. Under 400 words.

If there is no spec, skip the Spec axis and say so.

### 5. Check a finding before reporting it

A deliberate decision looks identical to a defect in a diff. Before reporting, run
`git log -S` or `git blame` on the hunk and read what the commit message claimed. Two
findings from the last audit round turned out to be decisions with a written rationale, and
one of them had a ticket filed against it.

A refused write answering 403 for a row that does not exist is a ruling, authorization before
existence, and not a finding.

Two things in a diff are the user's and are reported, never edited: a `@ts-expect-error`,
and a failing test that pins a bug the user knowingly left unfixed.

Read the PR files' withdrawn lists and the ledger's "Withdrawn before" too. A class withdrawn
twice already is checked against its reason before it is raised a third time.

### 6. Aggregate

Present the two reports under `## Standards` and `## Spec`, verbatim or lightly cleaned. Do
**not** merge or rerank findings across axes, because the two are deliberately separate.

End with a one-line summary: total findings per axis, and the worst issue _within each axis_.
Don't pick a single winner across axes: that's the reranking the separation exists to
prevent.

A PR's report goes to `docs/mine/pr-audit/pr<N>-<slug>.md`. Then update the ledger: the PR's
row, the PR added to each class row it hit (a new class gets its own row once it is seen a second
time), and a "Still open" row per finding until it closes. Every new class also goes into the
source a later audit reads, `patterns.md` or this baseline, in the same change.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing -> **Standards pass, Spec fail.**
- Code that does exactly what the ticket asked but breaks the project's conventions -> **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
