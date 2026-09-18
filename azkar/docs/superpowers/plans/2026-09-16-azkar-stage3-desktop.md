# Azkar stage 3: the desktop app (Windows and Linux) Implementation Plan

> **For agentic workers:** this plan is executed inline in one session (the user asked for every stage to be built
> without stopping). Each task ends with a test run and a commit; commits stay local.

**Goal:** `kotlin/desktopApp` runs Azkar on Windows and Linux with the same behaviour as the macOS app: a tray icon,
stacked always-on-top cards, the global shortcut, and the five-page window — all built on `kotlin/shared`.

**Architecture:** `shared` grows two layers above `core`: `app` (platform-free state: files, controller, card stack,
key mapping) and `ui` (Compose Material 3 pages and the card view, shared with the phones later). `desktopApp` is a
thin JVM shell: tray, windows, the one-second loop, and the three shortcut backends.

**Tech Stack:** Kotlin 2.4.20, Compose Multiplatform 1.12.0 (Material 3 1.9.0), coroutines 1.11.0,
ComposeNativeTray `dev.nucleusframework:composenativetray:2.1.6`, JNA 5.19.1, dbus-java 5.2.1, jpackage via the
Compose plugin (`.deb`, `.msi`).

**Spec:** `../specs/2026-09-15-azkar-kotlin-multiplatform-design.md` (sections 1, 3 "Shared app layer" and
"Desktop", 4, 5).

## Global Constraints

- The stow package keeps working: only `.config/azkar` is linked into `$HOME`; new build output is gitignored.
- Stage only `azkar/` paths by name when committing; the repo has unrelated uncommitted changes.
- Config and azkar JSON formats stay byte-compatible with the Swift app (`ShippedFilesTest` guards this).
- Pure logic is tested in `commonTest`/`jvmTest`; anything that needs a real desktop is verified in CI or by hand.
- No Xcode locally: iOS targets must still compile (`:shared:compileKotlinIosSimulatorArm64`).

## Deviations from the spec (decided while planning)

- **Tray library:** the spec pinned `io.github.kdroidfilter:composenativetray:1.3.3`; that project moved to
  `dev.nucleusframework:composenativetray`, whose 2.1.6 release is built against exactly Compose 1.12.0 and
  coroutines 1.11.0. Using 2.1.6.
- **Material 3:** newest stable is 1.9.0 (the 1.12.0 line is alpha), so `material3` is pinned separately.
- **The Linux desktop file** (`com.wildduck.azkar.desktop`, needed by the GlobalShortcuts portal registry) is
  written by the app into `~/.local/share/applications` on first run of an installed build, instead of relying on
  what jpackage names its own `.desktop` file. A dev run without it still counts as "no portal", as the spec says.
- **Icons:** the tray icon is drawn in Compose (`iconContent`), so the app ships no icon assets yet.

## File Map

```
kotlin/
  gradle/libs.versions.toml         + compose, material3, tray, jna, dbus-java, coroutines, slf4j
  settings.gradle.kts               + include(":desktopApp"), google() repo
  build.gradle.kts                  + compose plugins (apply false)
  shared/
    build.gradle.kts                + compose plugins, compose deps, resources config
    src/commonMain/composeResources/font/noto_naskh_arabic_{regular,bold}.ttf
    src/commonMain/kotlin/com/wildduck/azkar/
      app/StateFile.kt              state.json (Swift-compatible), PlanFile in stage 5
      app/Storage.kt                Storage, Clocks; problem keys
      app/AzkarController.kt        config/library/state, problems, actions, UiState + Actions
      app/CardStack.kt              cards on screen, tap/dismiss, layout positions (pure)
      app/KeyNames.kt               Compose Key <-> Hotkey key names
      ui/Theme.kt, ui/Card.kt, ui/AzkarScreen.kt, ui/pages/*.kt, ui/Components.kt
    src/commonTest/.../app/*Test.kt, .../ui/*Test.kt (runComposeUiTest)
  desktopApp/
    build.gradle.kts                kotlin("jvm") + compose desktop application, Deb/Msi
    src/main/kotlin/com/wildduck/azkar/desktop/
      Main.kt                       args, single instance, controller, application { }
      DesktopPaths.kt               config/state dirs per OS (pure)
      Files.kt                      Storage on java.io, mtime stamps, open file/folder
      Autostart.kt                  Linux autostart + desktop file text, Windows Run value (pure)
      SingleInstance.kt             lock file + Unix domain socket
      Chime.kt                      synthesised chime through javax.sound
      CardWindows.kt                one undecorated window per card
      TrayMenu.kt                   ComposeNativeTray menu
      Loop.kt                       the one-second tick
      shortcut/Shortcut.kt          interface + pick by OS/session (pure)
      shortcut/Triggers.kt          spec -> VK codes / xkb keysyms / portal trigger (pure)
      shortcut/WindowsShortcut.kt   RegisterHotKey + message loop (JNA)
      shortcut/X11Shortcut.kt       XGrabKey + event poll (JNA)
      shortcut/PortalShortcut.kt    XDG GlobalShortcuts portal (dbus-java)
    src/test/kotlin/...             paths, autostart, single instance, triggers, portal handshake
.github/workflows/azkar.yml         (dotfiles root) Linux/Windows/macOS jobs
```

---

### Task 1: Gradle: Compose in `shared`, a `desktopApp` that opens a window

- [ ] Add the versions and plugins above; `include(":desktopApp")`; fonts into `composeResources/font`.
- [ ] `shared`: compose runtime/foundation/ui/material3/components-resources, coroutines-core; `compose.resources`
      generates `com.wildduck.azkar.resources.Res` (public).
- [ ] `desktopApp`: `compose.desktop.currentOs`, tray, JNA, dbus-java, slf4j-nop, coroutines-swing; a `Main.kt` that
      shows a placeholder window.
- [ ] Verify: `./gradlew :shared:jvmTest :shared:compileKotlinIosSimulatorArm64 :desktopApp:compileKotlin` and
      `:desktopApp:createDistributable` (macOS `.app`, proof jpackage is wired).
- [ ] Commit: "build(azkar): add Compose Multiplatform and the desktop app module".

### Task 2: `app` layer in `shared` (tests first)

- [ ] `StateFile`: decode Swift's `state.json` (any key order, missing keys, `null` count, garbage → fresh state),
      encode without nulls. Tests include the real shipped shape `{"paused":false,"day":"…","masaa":23,…}`.
- [ ] `Storage` interface (config/azkar/state text, plus `configStamp`), `Problem` (text + optional fix action),
      `UiState`, `Features`, `AzkarActions`.
- [ ] `AzkarController`: reload (broken config keeps the last good one and reports a problem; broken azkar.json
      likewise), `setConfig` (applies, writes, records), `pick(now)` (Picker + save state), `setPaused`,
      `restart(session)`, status (`nextIn`, `lastSkip`, `onScreen`).
- [ ] `CardStack`: push/tap/tapOldest/dismiss/dismissAll with a completion callback, and `positions(area, heights)`
      — top-right, 16 margin, 10 gap, overlapping at the bottom when out of room (mirrors `CardStack.swift`).
- [ ] `KeyNames`: Compose `Key` → Hotkey key name for all 64 keys, and back for display.
- [ ] Verify: `./gradlew :shared:jvmTest`; commit "feat(azkar): add the shared app layer for every platform".

### Task 3: `ui` in `shared`

- [ ] `AzkarTheme` (Material 3 dark/light, Arabic font family), `Components` (Row/Tile/Footnote equivalents).
- [ ] `CardView`: dark card, RTL text 1.3 line height, header `أذكار الصباح · 7 من 25`, `×3`/`1/3` badge,
      right-to-left progress bar, `×`, tap to count, hint line.
- [ ] Pages Today, Schedule, Cards, Azkar, General against `UiState`/`AzkarActions`; sidebar on wide layouts,
      bottom tabs on narrow ones; desktop-only rows hidden unless `Features.desktop`.
- [ ] Clock fields as `HH:mm` text fields validated with `parseClock`; shortcut recorder via `onPreviewKeyEvent`
      (hidden when the shortcut isn't editable).
- [ ] Tests with `runComposeUiTest`: every page composes, a tap counts, switching a time window off and on
      restores the remembered times, the recorder rejects a modifier-less key.
- [ ] Verify: `./gradlew :shared:jvmTest`; commit "feat(azkar): add the shared Compose UI".

### Task 4: desktop files, autostart, single instance, chime

- [ ] `DesktopPaths` from an env map + OS: Linux `$XDG_CONFIG_HOME/azkar`, `$XDG_STATE_HOME/azkar` (defaults
      `~/.config`, `~/.local/state`); Windows `%APPDATA%\azkar`, `%LOCALAPPDATA%\azkar`; macOS as today.
- [ ] `Files`: `Storage` on disk, missing `azkar.json` written from the bundled copy, missing `config.json` → defaults,
      mtime stamps, open file/folder (Desktop API, `xdg-open` fallback).
- [ ] `Autostart`: the `.desktop` text (autostart and applications entry) and the Windows `Run` value
      `"<exe>" --background`; enable/disable writes or removes them.
- [ ] `SingleInstance`: lock file + Unix domain socket in the state dir; a second launch asks the first to open its
      window and exits.
- [ ] `Chime`: a short synthesised tone through `javax.sound.sampled`, silent when it can't open a line.
- [ ] Tests: paths for both OSes, autostart text, single instance (two instances in one JVM, temp dir).
- [ ] Verify: `./gradlew :desktopApp:test`; commit "feat(azkar): desktop files, autostart and single instance".

### Task 5: the global shortcut on Windows, X11 and Wayland

- [ ] `Triggers` (pure): Hotkey → Windows `MOD_*` + virtual-key code, X11 keysym name + modifier mask, and the
      portal trigger string (`ctrl+alt+z` → `CTRL+ALT+z`, `cmd` → `LOGO`, `delete` → `BackSpace`, `-` → `minus`…).
- [ ] `Shortcut` interface (`bind(hotkey) -> error?`, `close()`, `mode` = Recorder / SystemSettings(label) / None(reason))
      and `pickShortcut(os, sessionType, installed)`.
- [ ] `WindowsShortcut`: `RegisterHotKey` on its own thread with a `GetMessage` loop, re-binding via
      `PostThreadMessage`; `X11Shortcut`: `XGrabKey` (with the lock-key variants) and an `XPending` poll loop;
      `PortalShortcut`: Registry.Register → CreateSession → BindShortcuts → `Activated`, with `ShortcutsChanged`
      updating the shown trigger, and every failure turned into a problem row.
- [ ] Tests: the trigger tables, the backend choice, and the portal handshake against a fake portal exported on
      dbus-java's `EmbeddedDBusDaemon`.
- [ ] Verify: `./gradlew :desktopApp:test`; commit "feat(azkar): global shortcut on Windows, X11 and Wayland".

### Task 6: the app itself

- [ ] `Main`: parse `--background`, single instance, build the controller on the desktop `Storage`, then
      `application { }`: tray (status line, progress, problems, count/dismiss/show/pause, Open Azkar…, Quit),
      the main window (five pages, opened per `opensWindowAtLaunch`), and one window per card.
- [ ] `Loop`: every second — reload the files every other tick, refresh the status, and on the interval
      `decideTick` → `controller.pick` → push a card (+ chime); first reminder 5 s after launch.
- [ ] Card windows: undecorated, transparent, always-on-top, non-focusable, positioned from `CardStack.positions`
      using each window's measured height.
- [ ] Packaging: `nativeDistributions` for Deb and Msi (plus Dmg for local runs), `packageName = "azkar"`,
      version, vendor, Linux `menuGroup`/`appCategory`, Windows `menu`/`shortcut`/`upgradeUuid`.
- [ ] Verify: `./gradlew :desktopApp:test :desktopApp:createDistributable`, and a short headed smoke run of the
      packaged app started with `--background` (tray only, no card on screen during the run).
- [ ] Commit: "feat(azkar): the Kotlin desktop app for Windows and Linux".

### Task 7: CI, README, stage check

- [ ] `.github/workflows/azkar.yml` (dotfiles root, triggered on `azkar/**`): ubuntu (Kotlin tests, `.deb`),
      windows (Kotlin tests, `.msi`), macos (Swift tests, Kotlin iOS simulator tests) — artifacts uploaded.
- [ ] README: how to run and package the desktop app, the file locations table, the Wayland/GNOME notes and the
      manual checklist.
- [ ] Verify: `apple/build.sh test`, `./gradlew clean jvmTest :desktopApp:test compileKotlinIosArm64
      compileKotlinIosSimulatorArm64 --no-build-cache`, `git status --short .`.
- [ ] Commit: "docs(azkar): document the desktop app and add CI".
