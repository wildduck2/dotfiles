# Azkar on every device: Apple (Swift) + Kotlin Multiplatform

Date: 2026-09-15 · Status: approved design, awaiting spec review

## Goal

Azkar today is a native macOS menu-bar app in Swift. Make it available on **iOS, Android, Windows and Linux**,
organised as two folders:

- `apple/` — Swift: the existing macOS app, a new native SwiftUI iPhone app, and the Swift Core they share.
- `kotlin/` — one Compose Multiplatform project for Android, iOS, Windows and Linux, sharing core logic and UI.

Both implementations read and write the same JSON formats and behave the same way, as far as each platform allows.

## Non-goals

- Syncing settings or progress between devices.
- Editing `azkar.json` on phones (it is bundled, read-only).
- A packaged Kotlin build for macOS (the Swift app is the Mac app; `:desktopApp:run` on macOS is for development).
- Detecting a locked screen on Windows/Linux (cards stop at `maxStack` while you're away).
- UI tests for the iOS apps.

## Decisions

| Question | Decision |
| --- | --- |
| Folder layout | `apple/{Core,CoreTests,macOS,iOS}` + `kotlin/{shared,androidApp,desktopApp,iosApp}` |
| Reminders on phones | Local notifications on both; Android gets a **Count** button; iOS opens the card on tap |
| What Kotlin shares | Core logic **and** Compose UI in `shared`; apps are thin platform shells |
| Wayland shortcut | Yes, through the XDG GlobalShortcuts portal (works on KDE/Hyprland, not GNOME 50) |
| Local toolchain | Install `android-commandlinetools` + `temurin@21`; no Xcode (iOS is compiled in CI) |

## 1. Layout, build, CI, delivery

```
azkar/                              stow package; only .config/azkar is linked into $HOME
├── .config/azkar/                  config.json + azkar.json (unchanged; the one copy of the list)
├── README.md                       both apps
├── docs/superpowers/specs/         this file
├── apple/
│   ├── Core/                       from src/Core (Foundation only; also builds for iOS)
│   ├── CoreTests/                  from tests/core
│   ├── macOS/                      main.swift, App/, Window/, UITests/ (from tests/ui), tools/icon.swift
│   ├── iOS/                        SwiftUI iPhone app + project.yml (XcodeGen)
│   ├── build.sh                    today's script, new paths; adds `ios` (generate the Xcode project)
│   └── .swift-format
└── kotlin/                         package com.wildduck.azkar
    ├── settings.gradle.kts, gradlew, gradle/libs.versions.toml
    ├── shared/                     core + ui (commonMain), platform code per source set
    ├── androidApp/
    ├── desktopApp/                 Windows + Linux
    └── iosApp/                     Xcode wrapper (XcodeGen project.yml)
```

- `.stow-local-ignore`: `^/docs` is already added; stage 1 adds `^/apple`, `^/kotlin` and drops the `src`, `tests`,
  `tools`, `build.sh`, `.swift-format`, `.build` entries. `.gitignore` gains Gradle/Kotlin build output,
  `local.properties`, `apple/.build/` and the generated `*.xcodeproj`.
- The macOS app installs and behaves exactly as today. `apple/build.sh` keeps `install | test | build | uninstall |
  format`; its stow call becomes `stow -d "$here/../.." -t "$HOME" azkar`. `ShippedFilesTests` still walks three
  directories up from its own file to reach `azkar/`.
- Versions (latest stable on 2026-09-15, pinned in `libs.versions.toml`): Kotlin 2.4.20, Gradle 9.7.1 (wrapper),
  JDK 21 toolchain, Compose Multiplatform 1.12.0, AGP 9.4.0 with `com.android.kotlin.multiplatform.library`,
  kotlinx-serialization-json 1.11.0, kotlinx-datetime 0.8.0, kotlinx-coroutines 1.11.0, JNA 5.19.1,
  dbus-java 5.2.1, ComposeNativeTray 1.3.3.
- Commands (from `kotlin/`): `./gradlew jvmTest`, `:desktopApp:run`, `:desktopApp:packageDistributionForCurrentOS`
  (`.msi` on Windows, `.deb` on Linux — jpackage only builds for the OS it runs on), `:androidApp:assembleDebug`.
- CI: `dotfiles/.github/workflows/azkar.yml`, triggered by changes under `azkar/**`:
  - `ubuntu-latest`: Kotlin JVM tests, `.deb`, Android debug APK.
  - `windows-latest`: Kotlin JVM tests, `.msi`.
  - `macos-26` (Xcode 26.4.1): `apple/build.sh test`, build `apple/iOS` for the simulator, Kotlin
    `iosSimulatorArm64Test`, build `kotlin/iosApp` for the simulator.
  - Installers and the APK are uploaded as workflow artifacts.

**Delivery order** — five stages. Each stage gets its own implementation plan and is verified before the next
starts; the first plan covers stage 1 only.

1. Restructure into `apple/`; every existing Swift test still passes; `apple/build.sh build` produces the app
   bundle. (Not `install` — that would replace the copy you're running; you run `install` when you're ready.)
2. `kotlin/shared` core port + tests (parity with the Swift tests), and `Plan` in both cores.
3. Desktop app (Windows, Linux) including the Wayland portal shortcut.
4. Android app.
5. iOS: `apple/iOS` (SwiftUI) and `kotlin/iosApp`; compiled in CI until Xcode is installed locally.

## 2. Core logic and parity

**Ported** to `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/`, one file per Swift file with the same
names and behaviour: `Clock`, `Hotkey`, `Config`, `Library`, `Picker`, `Tick`, `TapCounter`, and
`opensWindowAtLaunch` from `Startup`. (`launchAgentPlist` is macOS-only and stays in Swift.)

- Dependencies: `kotlinx-serialization-json`, `kotlinx-datetime`.
- `Picker.next(at: LocalDateTime, config, library, state, random: (Int) -> Int)` — a local date-time replaces
  `Date` + `Calendar`; `AppState`, `Card`, `Session` are unchanged.
- `Config.decode` walks the JSON tree by hand: missing keys keep defaults, `null` disables a time window, and error
  messages use the same words as Swift. `Config.encode` produces **byte-identical** text to the Swift encoder.
- `Hotkey` is platform-neutral: the `"ctrl+alt+z"` spec as a modifier set + key name, with `spec`, and `display` in
  two styles (`⌃⌥Z` on Apple, `Ctrl+Alt+Z` elsewhere; `cmd` is the Win/Super key). Native key codes live in the
  desktop app.

**Fix in both cores:** Swift currently accepts JSON booleans as numbers (`{"maxStack": true}` → 1,
`{"intervalMinutes": true}` → 1 minute; verified). Both implementations reject booleans for numeric keys, with a
test on each side.

**New in both cores: `Plan`** (for iOS, which cannot run code every few minutes).

- `Plan.make(now, config, library, state, limit = 64, horizon = 48h) -> [PlannedReminder]` steps forward one
  interval at a time; the first entry is at `now + interval`. Ticks inside quiet hours are skipped (time still advances); a paused state gives an
  empty plan; `maxStack` does not apply. Each entry has the fire time, the `Card`, and the `AppState` after it.
  Stops at `limit` entries or `horizon`, whichever comes first.
- The plan is persisted. `Plan.commit(plan, now) -> AppState` returns the state of the last entry whose fire time
  is ≤ `now` (or the current state if none fired). The app commits, then makes a fresh plan.
- The last entry's notification body ends with "Open Azkar to keep reminders coming".

**Keeping Swift and Kotlin in step**

- Kotlin tests (`kotlin.test`, `commonTest`) copy every Swift test case one-for-one, with the same fixtures (UTC,
  the `s1…/m1…/g1…` library, a random source that always returns 0) and the same case names. `PlanTests` exist on
  both sides with the same cases.
- `ShippedFilesTest` (JVM source set, since it reads files) loads the real `.config/azkar/azkar.json` (25/23/22)
  and asserts that `.config/azkar/config.json` equals what the Kotlin encoder writes. The Swift suite already
  asserts the same for its encoder, so if the two encoders diverge one suite fails on the real file.

## 3. Platforms

### Shared app layer and UI (`kotlin/shared`)

- `AzkarController` (commonMain) holds config, library, state and problems; exposes a `StateFlow` for the UI and
  actions (`showNow`, `setPaused`, `restart(session)`, `setConfig`, `tap`, `dismiss`). It plays the role of the
  macOS `AppDelegate` + `SettingsModel`.
- Platform services are plain interfaces in commonMain, implemented in each app: `Storage` (read/write
  config/state/plan text), `Reminders`, `GlobalShortcut`, `Chime`, `LoginItem`. `expect`/`actual` only where a
  Kotlin API itself differs.
- Compose Material 3 pages: **Today, Schedule, Cards, Azkar, General** — sidebar on desktop, bottom tabs on phones.
  On phones, desktop-only settings are hidden: shortcut, open at login, show window at login, show count.
- Card view: dark card, right-to-left zikr text with 1.3 line height, header `أذكار الصباح · 7 من 25`, `×3` →
  `1/3` badge, progress bar filling right-to-left, `×` to close. A bundled Arabic font (Noto Naskh Arabic, OFL)
  so harakat render well on Windows/Linux.

### Desktop — Windows, Linux (`kotlin/desktopApp`)

- **Loop:** every second, like `AppDelegate.tick`: reload the JSON files when their modification time changes
  (every 2 s), then `decideTick(paused, locked = false, quiet, stackCount, maxStack)` → `Picker.next` → card.
  First reminder 5 s after launch.
- **Cards:** undecorated, transparent, always-on-top, non-focusable Compose windows, stacked top-right of the
  primary screen's usable area (16 margin, 10 gap, overlapping at the bottom when out of room). The stack layout is
  a pure function with tests. Click counts; `×` closes; chime on appear and on completion when `sound` is on.
- **Tray:** ComposeNativeTray. Menu: status line, morning/evening progress, problems, Count on oldest, Dismiss
  oldest, Dismiss all, Show one now, Pause/Resume, Open Azkar…, Quit. Waiting-card count in the tooltip when
  `showCount` is on. GNOME needs the AppIndicator extension; if no tray is available the window opens at launch.
- **Linux display:** runs under XWayland (the default for a standard JDK). Native Wayland would not allow
  positioned, always-on-top cards.
- **Global shortcut** (`GlobalShortcut` implementations; any failure is shown on the Cards page and Today):
  - Windows: `RegisterHotKey` via JNA.
  - Linux X11 session: `XGrabKey` via JNA.
  - Linux Wayland session (`XDG_SESSION_TYPE=wayland`): GlobalShortcuts portal via dbus-java (native Unix-socket
    transport):
    1. `org.freedesktop.host.portal.Registry.Register("com.wildduck.azkar")` — once, before any portal call; needs
       `com.wildduck.azkar.desktop` installed (the `.deb` installs it). If this fails (e.g. a dev run without the
       desktop file), treat it as "no portal".
    2. `CreateSession`, then `BindShortcuts` with id `count-oldest`, description "Count on the oldest Azkar card",
       `preferred_trigger` converted from the spec: `ctrl+alt+z` → `CTRL+ALT+z` (`cmd` → `LOGO`; keys use xkb
       keysym names, e.g. `return` → `Return`, `delete` → `BackSpace`, `-` → `minus`).
    3. `Activated` with `count-oldest` → tap the oldest card. `ShortcutsChanged` / the `BindShortcuts` response
       update the trigger shown on the Cards page.
    - The desktop owns the binding. On Wayland the Cards page shows **Change in System Settings** (portal v2
      `ConfigureShortcuts`; on v1, text saying where to change it) instead of the recorder.
    - No portal (GNOME 50, wlroots compositors) or a portal error → no shortcut; the Cards page says why; card
      click and the tray still work.
  - macOS dev runs: no-op.
- **Files:**

  | | Linux | Windows |
  | --- | --- | --- |
  | config.json, azkar.json | `$XDG_CONFIG_HOME/azkar/` (default `~/.config/azkar/`) | `%APPDATA%\azkar\` |
  | state.json | `$XDG_STATE_HOME/azkar/` (default `~/.local/state/azkar/`) | `%LOCALAPPDATA%\azkar\` |

  Missing `azkar.json` → write the bundled copy. Missing `config.json` → defaults (written on first change).
  "Edit azkar.json" / "Show config folder" open the file / folder with the system handler.
- **Start at login:** Linux `~/.config/autostart/com.wildduck.azkar.desktop`; Windows `HKCU\Software\Microsoft\
  Windows\CurrentVersion\Run`. Both launch with `--background`; `opensWindowAtLaunch` decides whether the window
  opens.
- **Single instance:** a lock plus a Unix domain socket in the state directory; a second launch asks the running one
  to open its window and exits.

### Android (`kotlin/androidApp`)

- minSdk 26. `applicationId` `com.wildduck.azkar`.
- **Scheduling:** one alarm at a time. On fire, a `BroadcastReceiver` runs the tick with the real state:
  `decideTick(paused, locked = false, quiet, stackCount = active Azkar notifications, maxStack)` → `Picker.next` →
  post the notification → set the next alarm at now + interval. `BOOT_COMPLETED` and app start re-arm it.
- **Exact alarms:** `SCHEDULE_EXACT_ALARM`, requested from the Schedule page → `setExactAndAllowWhileIdle`.
  Without it: `setAndAllowWhileIdle`, and the Schedule page says reminders may arrive several minutes late.
- **Notification:** big-text zikr, header `أذكار الصباح · 7 من 25`; for counts > 1 a **Count** action that updates
  the same notification (`1/3`, progress bar) and cancels it at the end. Tap opens the card in the app.
- `POST_NOTIFICATIONS` requested at first launch (Android 13+).
- **Sound:** two notification channels (chime, silent), chosen by `sound`, because a channel's sound can't be
  changed after creation.
- Storage: `config.json`, `state.json` in the app's files directory, same formats. `azkar.json` from assets.

### iOS — `kotlin/iosApp` (Compose) and `apple/iOS` (SwiftUI), same behaviour

- Up to 64 local notifications from `Plan` via `UNUserNotificationCenter`, grouped by session thread.
- Re-plan (commit, then make) when the app becomes active, when a setting changes, after "Show a zikr now", and on
  `BGAppRefreshTask` when iOS grants one.
- Tapping a notification opens its card in the app, where you count. No Count action: iOS cannot edit a delivered
  notification. `maxStack` does not apply.
- Storage: `config.json`, `state.json`, `plan.json` in Application Support, same formats. `azkar.json` bundled.
- Bundle IDs: `apple/iOS` → `com.wildduck.azkar`; `kotlin/iosApp` → `com.wildduck.azkar.kmp` (so both can be
  installed side by side). CI builds for the simulator without signing; running on a device needs your Apple team.

**`apple/iOS` specifics:** iOS 18+, SwiftUI, built from `apple/Core` sources through XcodeGen; `azkar.json` is
referenced from `.config/azkar/` as a resource. Tabs Today, Schedule, Cards, Azkar, General, modelled on the macOS
pages but not shared with them (those use AppKit). Full-screen card: tap anywhere to count, progress bar, `×`.

## 4. Errors

- Broken `config.json` / `azkar.json` on desktop: keep the last good version; show the error on Today and in the tray
  status line (as the macOS menu does).
- Unreadable `state.json` (any platform): start from a fresh `AppState`, as macOS does.
- Phones write their own config; a file that fails to decode resets to defaults and shows a one-time notice on Today.
- Denied notifications or exact alarms, a shortcut already taken, no tray, no portal: a "Needs attention" row on
  Today, with a button to the relevant system setting where one exists.

## 5. Testing

- **Swift (here):** `apple/build.sh test` — existing Core and UI tests, plus `PlanTests` and the boolean-as-number
  tests.
- **Kotlin (here):** `./gradlew jvmTest` — the ported core tests, `PlanTests`, `ShippedFilesTest`; desktop: stack
  layout, file paths, autostart file/registry value contents, trigger conversion, and the portal handshake against a
  fake portal on dbus-java's embedded D-Bus daemon; Android: notification text / badge / channel choice as pure
  functions with JVM tests, and `:androidApp:assembleDebug`.
- **CI:** everything above on its runner, plus iOS simulator tests and both iOS app builds.
- **Manual checklist in the README:** Windows shortcut and tray; Linux X11 shortcut; KDE Wayland portal shortcut;
  GNOME tray with AppIndicator; Android alarms after reboot and the Count button; iOS notifications and re-planning.

## Risks and things to confirm during planning

- **ComposeNativeTray on Linux:** its README doesn't state the tray protocol. Confirm it shows on KDE and on GNOME
  with AppIndicator; otherwise fall back to Compose's built-in `Tray`.
- **dbus-java** is in its sunset period (bug fixes only, support ending around winter 2026). Contained to the one
  portal `GlobalShortcut` implementation.
- **No local Xcode:** iOS code is only compiled in CI until Xcode is installed.
- **AppKit UI tests on GitHub's macOS runner** may not have a usable window server; if not, CI runs the Core tests
  only and UI tests stay local.
- **Android Doze** delays alarms even with exact-alarm permission when the phone is idle for long periods.
- **iOS** reminders stop when the 64-notification plan runs out and the app isn't opened or refreshed.
- The `azkar/` folder is not yet committed to git; commit it before stage 1 so the restructure can be reviewed and
  reverted.
