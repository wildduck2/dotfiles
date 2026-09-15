# Azkar Stage 1: Move the Swift App into `apple/` — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the existing Swift macOS app from `src/`, `tests/`, `tools/` into `apple/` without changing its behaviour, so `kotlin/` can sit beside it in later stages.

**Architecture:** A pure move with `git mv` (history kept), then repointing the paths in `build.sh`, three comments, the README and the stow ignore list. The existing test suites (218 Core + 53 UI tests) are the safety net: they must pass with the same counts before and after.

**Tech Stack:** Swift 5 (`swiftc -swift-version 5` from the Xcode Command Line Tools), bash, `swift format`, GNU Stow 2.4.1, git.

**Spec:** `docs/superpowers/specs/2026-09-15-azkar-kotlin-multiplatform-design.md` (section 1, delivery stage 1)

## Global Constraints

- The macOS app installs and behaves exactly as today. No Swift source changes other than the comments listed below.
- Only `.config/azkar` is linked into `$HOME` by stow.
- `apple/build.sh` keeps `install | test | build | uninstall | format`; its stow call becomes `stow -d "$here/../.." -t "$HOME" azkar`.
- `ShippedFilesTests` still walks three directories up from its own file to reach `azkar/`.
- Verify with `apple/build.sh test` / `apple/build.sh build`. **Never run `install`** — it would replace the copy the user is running.
- Commits go on `main` and contain only `azkar/` paths: always `git commit ... -- .` from inside `azkar/`. The dotfiles repo has unrelated uncommitted changes that must stay out.
- Out of scope for stage 1: `build.sh ios`, anything under `kotlin/`, `apple/iOS/`, and new `.gitignore` entries (the existing `.build/` pattern already ignores `apple/.build/`).
- All commands run from `/Users/wildduck/dotfiles/azkar` unless a step says otherwise.
- Baseline on commit `88f94eb`: `218 passed, 0 failed`, `ui: 53 passed, 0 failed`; `swift format lint -r src tests tools` prints nothing and exits 0.
- The UI tests briefly show cards in the top-right corner of the screen. That is expected.

---

### Task 1: Move the Swift sources into `apple/` and repoint `build.sh`

**Files:**
- Move: `src/Core/` → `apple/Core/`
- Move: `tests/core/` → `apple/CoreTests/`
- Move: `src/main.swift` → `apple/macOS/main.swift`
- Move: `src/App/` → `apple/macOS/App/`
- Move: `src/Window/` → `apple/macOS/Window/`
- Move: `tests/ui/` → `apple/macOS/UITests/`
- Move: `tools/icon.swift` → `apple/macOS/tools/icon.swift`
- Move: `build.sh` → `apple/build.sh`
- Move: `.swift-format` → `apple/.swift-format`
- Modify: `apple/build.sh` (source paths, format paths, stow directory)
- Modify: `apple/CoreTests/main.swift:1`, `apple/CoreTests/ShippedFilesTests.swift:5`, `apple/macOS/UITests/main.swift:3` (comments only)
- Modify: `README.md` (Install commands, Layout block, formatting note)
- Test: the existing suites, run by `apple/build.sh test`

**Interfaces:**
- Consumes: nothing (first task).
- Produces: the `apple/` tree above; `apple/build.sh` with the same subcommands as before; build output in `apple/.build/` (`apple/.build/Azkar.app`). Task 2 relies on `apple/` existing and the old root `.build/` no longer being used.

- [ ] **Step 1: Record the baseline**

Run:
```bash
./build.sh test
swift format lint -r src tests tools; echo "lint exit=$?"
```
Expected, at the end of the test output:
```
218 passed, 0 failed
ui: 53 passed, 0 failed
```
and the lint prints only `lint exit=0`. If the counts differ, write the actual numbers down and use them in Step 6 instead.

- [ ] **Step 2: Move the files with `git mv`**

```bash
mkdir -p apple/macOS/tools
git mv src/Core apple/Core
git mv tests/core apple/CoreTests
git mv src/main.swift apple/macOS/main.swift
git mv src/App apple/macOS/App
git mv src/Window apple/macOS/Window
git mv tests/ui apple/macOS/UITests
git mv tools/icon.swift apple/macOS/tools/icon.swift
git mv build.sh apple/build.sh
git mv .swift-format apple/.swift-format
for d in src tests tools; do [ ! -e "$d" ] || rmdir "$d"; done
git status --short . | grep -c '^R'
```
Expected: the last command prints `49`. `rmdir` must not fail; if it does, the directory still holds something — list it with `ls -la <dir>` and stop.

- [ ] **Step 3: Confirm the old paths are now broken**

Run: `apple/build.sh test`
Expected: FAIL, exiting non-zero with a `swiftc` error such as `error: no such file or directory: '/Users/wildduck/dotfiles/azkar/apple/src/Core/*.swift'`. This shows the script still points at the old layout, so the passing run in Step 6 really uses the new paths.

- [ ] **Step 4: Repoint the paths in `apple/build.sh`**

Make exactly these replacements (each old line appears once):

```bash
# old
core=("$here"/src/Core/*.swift)
# new
core=("$here"/Core/*.swift)
```

```bash
# old
lib=("${core[@]}" "$here"/src/App/*.swift "$here"/src/Window/*.swift)
# new
lib=("${core[@]}" "$here"/macOS/App/*.swift "$here"/macOS/Window/*.swift)
```

```bash
# old
  "${swiftc[@]}" "${core[@]}" "$here"/tests/core/*.swift -o "$build/tests"
# new
  "${swiftc[@]}" "${core[@]}" "$here"/CoreTests/*.swift -o "$build/tests"
```

```bash
# old
  "${swiftc[@]}" -framework AppKit -framework Carbon "${lib[@]}" "$here"/tests/ui/*.swift -o "$build/ui-tests"
# new
  "${swiftc[@]}" -framework AppKit -framework Carbon "${lib[@]}" "$here"/macOS/UITests/*.swift -o "$build/ui-tests"
```

```bash
# old
  if [ "$icns" -nt "$here/tools/icon.swift" ]; then return; fi
  "${swiftc[@]}" -framework AppKit "$here/tools/icon.swift" -o "$build/icon"
# new
  if [ "$icns" -nt "$here/macOS/tools/icon.swift" ]; then return; fi
  "${swiftc[@]}" -framework AppKit "$here/macOS/tools/icon.swift" -o "$build/icon"
```

```bash
# old
  "${swiftc[@]}" -O -framework AppKit -framework Carbon "${lib[@]}" "$here/src/main.swift" -o "$out/Contents/MacOS/Azkar"
# new
  "${swiftc[@]}" -O -framework AppKit -framework Carbon "${lib[@]}" "$here/macOS/main.swift" -o "$out/Contents/MacOS/Azkar"
```

```bash
# old
  [ -e "$HOME/.config/azkar" ] || stow -d "$here/.." -t "$HOME" azkar
# new
  [ -e "$HOME/.config/azkar" ] || stow -d "$here/../.." -t "$HOME" azkar
```

```bash
# old
  format) swift format -i -r "$here/src" "$here/tests" "$here/tools" ;;
# new
  format) swift format -i -r "$here/Core" "$here/CoreTests" "$here/macOS" ;;
```

Then check that nothing still points at the old layout:

Run: `grep -n -E '\$here"?/(src|tests|tools)|\$here/\.\." ' apple/build.sh; echo "grep exit=$?"`
Expected: only `grep exit=1` (no matches).

- [ ] **Step 5: Update the three comments**

In `apple/CoreTests/main.swift`, line 1:
```swift
// old
// Tests for src/Core. Run with: ./build.sh test
// new
// Tests for apple/Core. Run with: apple/build.sh test
```

In `apple/CoreTests/ShippedFilesTests.swift`, line 5 (code unchanged, comment only):
```swift
// old
  let pkg = URL(fileURLWithPath: #filePath)  // azkar/tests/core/ShippedFilesTests.swift
// new
  let pkg = URL(fileURLWithPath: #filePath)  // azkar/apple/CoreTests/ShippedFilesTests.swift
```

In `apple/macOS/UITests/main.swift`, line 3:
```swift
// old
// Run with: ./build.sh test
// new
// Run with: apple/build.sh test
```

- [ ] **Step 6: Run the tests from the new layout**

Run: `apple/build.sh test`
Expected, at the end:
```
218 passed, 0 failed
ui: 53 passed, 0 failed
```
(the same counts as Step 1). If a line `FAIL shipped azkar.json` or `FAIL shipped config.json` appears, `ShippedFilesTests` is no longer reaching `azkar/` — check that the file is at `apple/CoreTests/ShippedFilesTests.swift` (three levels below `azkar/`).

- [ ] **Step 7: Build the app bundle (no install)**

Run:
```bash
apple/build.sh build
codesign -v apple/.build/Azkar.app && echo "codesign ok"
ls apple/.build/Azkar.app/Contents/MacOS/Azkar apple/.build/Azkar.app/Contents/Resources/AppIcon.icns
git check-ignore apple/.build
```
Expected: the tests pass again (same counts), then `codesign ok`, both paths listed, and `apple/.build` printed by `git check-ignore`.

- [ ] **Step 8: Confirm the moved format config is still picked up**

Run: `swift format lint -r apple/Core apple/CoreTests apple/macOS; echo "lint exit=$?"`
Expected: only `lint exit=0`. (102 lines are longer than swift-format's default of 100 columns, so a clean lint means `apple/.swift-format` with `"lineLength": 120` was found.)

- [ ] **Step 9: Update `README.md`**

Replace the Install commands:
````markdown
<!-- old -->
```sh
./build.sh            # run tests, build, install to ~/Applications, start now and at login
./build.sh test       # tests only
./build.sh uninstall  # stop and remove the app + LaunchAgent (config stays)
```

`build.sh` also runs `stow azkar` if `~/.config/azkar` doesn't exist yet. Only `.config/azkar`
<!-- new -->
```sh
apple/build.sh            # run tests, build, install to ~/Applications, start now and at login
apple/build.sh test       # tests only
apple/build.sh uninstall  # stop and remove the app + LaunchAgent (config stays)
```

`apple/build.sh` also runs `stow azkar` if `~/.config/azkar` doesn't exist yet. Only `.config/azkar`
````

Replace the whole code block under `## Layout` (from the line `src/main.swift       entry point …` through `tools/icon.swift     draws the app icon at build time`) with:
```
apple/                  the Swift apps
  build.sh              build, test, install (see Install)
  Core/                 pure logic, no AppKit (tested by CoreTests)
    Clock               HH:mm parsing/formatting, time windows
    Hotkey              "ctrl+alt+z" <-> key code + modifiers
    Config              config.json decoding and the canonical encoding the window writes
    Library             azkar.json
    Picker              which zikr comes next, and today's progress
    Tick                show a card now, or skip (paused, locked, quiet hours, stack full)
    TapCounter          ×N repetitions on one card
  CoreTests/            Core tests, one file per area
  macOS/
    main.swift          entry point (single instance; a second launch opens the running one's window)
    App/                AppKit
      AppDelegate       timer, actions; +Files (reload/save), +Window, +Menus (📿 menu, app menu)
      CardWindow        one card: panel, ×, count badge, progress bar
      CardStack         cards top-right on the primary display
      GlobalHotkey      Carbon RegisterEventHotKey
      Paths, Session+Style
    Window/             the app window (SwiftUI)
      SettingsModel     what the window shows and edits
      MainWindow        the NSWindow; Dock icon while open
      AzkarView         sidebar + TodayPage, SchedulePage, CardsPage, AzkarPage
      Components        Tile, Row, Footnote;  ShortcutRecorder
    UITests/            clicks, ×, hotkey, placement and settings-model tests on the real AppKit classes
    tools/icon.swift    draws the app icon at build time
docs/superpowers/       design spec and implementation plans for the Swift + Kotlin Multiplatform apps
```

Replace the formatting note:
```markdown
<!-- old -->
Swift is formatted with `swift format` (2 spaces, 120 columns, see `.swift-format`):
`./build.sh format`.
<!-- new -->
Swift is formatted with `swift format` (2 spaces, 120 columns, see `apple/.swift-format`):
`apple/build.sh format`.
```

Run: ``grep -n -E '`\./build\.sh|^\./build\.sh|^src/|^tests/|^tools/|see `\.swift-format`' README.md; echo "grep exit=$?"``
Expected: only `grep exit=1` (no old paths left).

- [ ] **Step 10: Commit**

```bash
git add -A .
git commit -m "refactor(azkar): move Swift app into apple/" -- .
git show --stat --format='%h %s' HEAD | tail -1
git show --name-only --format= HEAD | grep -v '^azkar/'; echo "outside azkar exit=$?"
```
Expected: `51 files changed, …` (the 49 renames, `README.md`, and this plan file `docs/superpowers/plans/2026-09-15-azkar-stage1-apple-restructure.md`), then only `outside azkar exit=1` (every committed path is under `azkar/`).

---

### Task 2: Update the stow ignore list for the new layout

**Files:**
- Modify: `.stow-local-ignore`
- Delete: `.build/` at the `azkar/` root (old, git-ignored build output from before the move; the installed app lives in `~/Applications` and is not affected)
- Test: `stow -n -v` (simulation only)

**Interfaces:**
- Consumes: from Task 1, the `apple/` directory and `apple/build.sh` whose stow call is `stow -d "$here/../.." -t "$HOME" azkar`.
- Produces: an ignore list under which stow links only `.config/azkar`, now and after `kotlin/` is added in stage 2.

- [ ] **Step 1: Show that stow would now link the new folder**

Run: `stow -n -v -d "$(cd apple/../.. && pwd)" -t "$HOME" azkar 2>&1; echo "stow exit=$?"`
Expected: output mentioning `apple` (stow plans to link `~/apple`, because `^/apple` isn't ignored yet). This is the failing check. It also uses the same directory `apple/build.sh` resolves (`apple/../..` = `/Users/wildduck/dotfiles`). If stow reports a conflict instead, that's also a failure of this check — continue to Step 2.

- [ ] **Step 2: Remove the old root build output**

Run:
```bash
git check-ignore .build && ls .build
```
Expected: `.build` then `AppIcon.icns  AppIcon.iconset  Azkar.app  check  icon  tests  ui-tests` (build output only). Then:
```bash
rm -rf .build
```

- [ ] **Step 3: Write the new ignore list**

Replace the whole contents of `.stow-local-ignore` with:
```
# Only .config/azkar is linked into $HOME; the rest is the app's source.
^/\.stow-local-ignore
^/\.gitignore
^/apple
^/kotlin
^/docs
^/README\.md
\.DS_Store
```
(`^/kotlin` doesn't exist yet; it's listed now so stage 2 can't forget it.)

- [ ] **Step 4: Verify stow links nothing new**

Run:
```bash
stow -n -v -d "$(cd apple/../.. && pwd)" -t "$HOME" azkar 2>&1; echo "stow exit=$?"
readlink "$HOME/.config/azkar"
```
Expected:
```
WARNING: in simulation mode so not modifying filesystem.
stow exit=0
../dotfiles/azkar/.config/azkar
```

- [ ] **Step 5: Commit**

```bash
git add -A .
git commit -m "chore(azkar): update stow ignore list for apple/ layout" -- .
git show --stat --format='%h %s' HEAD | tail -2
```
Expected: one file changed, `azkar/.stow-local-ignore`.

---

## Stage 1 done when

- `apple/build.sh test` → `218 passed, 0 failed` and `ui: 53 passed, 0 failed`.
- `apple/build.sh build` produces a signed `apple/.build/Azkar.app`.
- `swift format lint -r apple/Core apple/CoreTests apple/macOS` is clean.
- The stow simulation prints only its warning.
- `git log --oneline -3` shows the two commits above on top of `88f94eb`.

After review, the user runs `apple/build.sh install` themselves to reinstall from the new location. The app, its LaunchAgent and `~/.config/azkar` stay the same.
