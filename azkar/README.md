# Azkar

A native macOS menu-bar app (Swift, AppKit + SwiftUI, no dependencies) that shows a zikr every
few minutes as an always-on-top card, top-right on the display with the menu bar (it doesn't
follow keyboard focus to other screens). Cards never time out and new ones stack below the old ones.
Click a card or press the global shortcut (default **⌃⌥Z**, counts on the oldest card) to count
one repetition — ×3 goes 1/3, 2/3, and the last one closes it. **×** closes a card straight away.

- **Morning window** (default 05:00–11:00): walks أذكار الصباح in order, one per reminder.
- **Evening window** (default 15:30–21:00): walks أذكار المساء in order.
- **Between and after them**, or once today's list is finished: a zikr from the general list,
  one tap each (switch on "Repeat counts" to keep counts like ×100).
- No new cards while paused, during quiet hours, while the screen is locked/asleep, or when
  `maxStack` cards are already waiting.

Launching the app (or **Open Azkar…** in the 📿 menu) opens its window — Today,
Schedule, Cards, Azkar and General pages with switches for the morning/evening/quiet times, the
interval, a shortcut recorder, text size, open at login, sound and so on. Changes are saved to
`config.json` immediately. While the window is open Azkar has a Dock icon; closing it goes back
to menu-bar only. The login agent starts it with `--background`, so no window at login unless
"Show this window at login" is on.

Hand edits to the JSON files still work and are picked up within ~2 seconds; a broken file keeps
the last good version and shows the error in the menu and on the Today page.

## Other platforms (in progress)

`kotlin/` is becoming a Kotlin Multiplatform version for Android, iOS, Windows and Linux, built in stages (see
`docs/superpowers/`). So far it has the core logic, ported from `apple/Core` and tested with the same cases:

```sh
cd kotlin && ./gradlew jvmTest   # Gradle runs on JDK 17+ and downloads the JDK 21 toolchain if it's missing
```

## Install

```sh
apple/build.sh            # run tests, build, install to ~/Applications, start now and at login
apple/build.sh test       # tests only
apple/build.sh uninstall  # stop and remove the app + LaunchAgent (config stays)
```

`apple/build.sh` also runs `stow azkar` if `~/.config/azkar` doesn't exist yet. Only `.config/azkar`
is linked into `$HOME` (see `.stow-local-ignore`). Needs the Xcode command-line tools (`swiftc`).

## `~/.config/azkar/config.json`

| key               | default                                  | notes                                            |
| ----------------- | ---------------------------------------- | ------------------------------------------------ |
| `intervalMinutes` | `3`                                      | decimals allowed                                 |
| `hotkey`          | `"ctrl+alt+z"`                           | modifiers: ctrl, alt/opt, shift, cmd + one key   |
| `order`           | `"random"`                               | `"random"` or `"sequential"` for the general list |
| `repeatGeneral`   | `false`                                  | `false`: general azkar are one tap each; `true`: full count (×100…) |
| `maxStack`        | `5`                                      | stop adding cards once this many are waiting     |
| `sabah`           | `{"start": "05:00", "end": "11:00"}`     | `null` to disable                                |
| `masaa`           | `{"start": "15:30", "end": "21:00"}`     | `null` to disable                                |
| `quietHours`      | `{"start": "23:30", "end": "05:00"}`     | may wrap past midnight; `null` to disable        |
| `fontSize`        | `22`                                     |                                                  |
| `sound`           | `false`                                  | "Glass" chime when a card pops in and when a count is finished |
| `showCount`       | `true`                                   | `📿 3` in the menu bar while cards are waiting    |
| `openAtLogin`     | `true`                                   | writes/removes `~/Library/LaunchAgents/com.wildduck.azkar.plist` |
| `showWindowAtLogin` | `false`                                | also open the window when starting at login      |

Missing keys use the defaults.

## `~/.config/azkar/azkar.json`

```json
{
  "sabah":   [{ "text": "…", "count": 3, "note": "…", "ref": 86 }],
  "masaa":   [ … ],
  "general": [ … ]
}
```

`count` (defaults to 1) is shown as ×N on the card; `note` and `ref` are optional.

The shipped list is from **حصن المسلم** via the official API at hisnmuslim.com (chapters 27,
34, 35, 85, 129, 130); `ref` is the item number in the book. Evening wordings follow the book's
own "وإذا أمسى قال" notes and were cross-checked against an independent full-text list.
Deliberate changes from the API text: "حسبي الله…" count 1 → 7 (the text says سبع مرات), the
typo نَبَيِّنَا → نَبِيِّنَا, the three Quls split into separate cards, and tatweel removed.

## Layout

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
    Plan                the reminders ahead, for iPhone notifications
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
kotlin/                 Kotlin Multiplatform (Gradle)
  shared/               com.wildduck.azkar.core: apple/Core ported file by file (Hotkey without key codes)
    src/commonTest/     the same test cases as apple/CoreTests
    src/jvmTest/        ShippedFilesTest: the real .config/azkar files
docs/superpowers/       design spec and implementation plans for the Swift + Kotlin Multiplatform apps
```

Swift is formatted with `swift format` (2 spaces, 120 columns, see `apple/.swift-format`):
`apple/build.sh format`.

Kotlin follows the official Kotlin style (4 spaces, 120 columns, see `kotlin/.editorconfig`).

Progress through today's morning/evening lists and the pause state live in
`~/.local/state/azkar/state.json`.
