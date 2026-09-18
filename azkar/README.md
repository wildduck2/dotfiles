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

## Windows and Linux

`kotlin/` is the same app in Kotlin Multiplatform: the core logic ported file by file from `apple/Core`, a
shared Compose UI for the five pages and the cards, and a desktop app for Windows and Linux (it runs on
macOS too, for development). It reads and writes exactly the same `config.json`, `azkar.json` and
`state.json`, so the Mac, the PC and the phone all understand each other's files.

```sh
cd kotlin
./gradlew :desktopApp:run                  # run it
./gradlew jvmTest :desktopApp:test         # every test (prefix with `xvfb-run -a` on a Linux box with no display)
./gradlew :desktopApp:createDistributable  # a folder you can run without installing
./gradlew :desktopApp:packageDeb           # on Linux:   desktopApp/build/compose/binaries/main/deb/*.deb
./gradlew :desktopApp:packageMsi           # on Windows: desktopApp/build/compose/binaries/main/msi/*.msi
```

Gradle runs on JDK 17+ and downloads the JDK 21 toolchain if it's missing. jpackage only builds for the
machine it runs on, which is why CI has one job per platform (`.github/workflows/azkar.yml`, at the root of
this repo: Linux tests + `.deb` + the Android `.apk`, Windows tests + `.msi`, macOS Swift tests, the iOS
simulator tests and both iPhone apps). Each job runs the same `./package.sh` a laptop does and keeps what
came out, so between the three of them every package exists — see Packaging. `azkar-release.yml` beside
it turns a pushed `azkar-v*` tag into a GitHub release built from those same three jobs.

Started with `--background` — what the login entry does — Azkar goes straight to the tray: beads, with the
number of waiting cards in the middle, and the same menu as 📿 on macOS (status line, today's progress,
count/dismiss, show one now, pause, Open Azkar…, Quit). A second launch doesn't start a second Azkar; it
asks the one already running to open its window.

### Where the files are

| file                        | Linux                                          | Windows                       | macOS                  |
| --------------------------- | ---------------------------------------------- | ----------------------------- | ---------------------- |
| `config.json`, `azkar.json` | `$XDG_CONFIG_HOME/azkar` (`~/.config/azkar`)   | `%APPDATA%\azkar`             | `~/.config/azkar`      |
| `state.json`                | `$XDG_STATE_HOME/azkar` (`~/.local/state/azkar`) | `%LOCALAPPDATA%\azkar`      | `~/.local/state/azkar` |
| open at login               | `~/.config/autostart/com.wildduck.azkar.desktop` | `HKCU\…\CurrentVersion\Run` → `Azkar` | the LaunchAgent plist |

The first run writes the `azkar.json` that ships with the app next to `config.json`, so it can be edited by
hand as on macOS. `openAtLogin` and `showWindowAtLogin` work the same way; everything else in the config
table above applies unchanged.

### The global shortcut

| session        | how                                      | can Azkar change it?      |
| -------------- | ---------------------------------------- | ------------------------- |
| Windows        | `RegisterHotKey`                         | yes, on the Cards page    |
| Linux, X11     | `XGrabKey` (also with Caps/Num Lock on)  | yes, on the Cards page    |
| Linux, Wayland | the XDG `GlobalShortcuts` portal         | no — the desktop owns it  |

On Wayland the desktop asks once to allow the shortcut and then owns it: Azkar shows the trigger the portal
reports and points at the keyboard settings (GNOME: Settings → Keyboard) instead of recording keys itself.
With no portal at all — a bare compositor — there is no global shortcut, and the settings page says so;
clicking a card still counts it. See-through, frameless cards need a compositor too: without one the card
sits in a plain rectangle.

### What to check by hand

The tests cover everything that isn't the desktop itself. These are the things only a real session shows:

- A card appears ~5 s after launch, top-right, clear of the panel or taskbar, and later ones stack below it.
- Clicking a card counts one repetition (×3 → 1/3, 2/3, gone); **×** closes it; the tray count follows.
- The global shortcut counts the oldest card while another app has the keyboard.
- Editing `config.json` by hand is picked up within ~2 seconds; a broken file becomes a problem in the menu
  and on the Today page, and the last good settings stay in use.
- "Open at login": log out and back in — Azkar starts in the tray with no window.
- Launching Azkar again opens the running app's window instead of starting a second one.

## Android

`kotlin/androidApp` is that same shared code with a notification where the desktop has a card. Point Gradle
at an Android SDK and build it:

```sh
cd kotlin
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools  # wherever the SDK is
./gradlew :androidApp:testDebugUnitTest  # the phone's own tests
./gradlew :androidApp:assembleDebug      # androidApp/build/outputs/apk/debug/androidApp-debug.apk
./gradlew :androidApp:installDebug       # onto a phone or emulator adb can see
```

`com.wildduck.azkar`, minSdk 26 (Android 8). A reminder is a notification: the heading
("أذكار الصباح · 7 من 25"), the zikr, and a **Count** button for a zikr said more than once — each press
moves the badge on (×3 → 1/3 → 2/3) and the last one takes the notification away. Tapping it opens the
same zikr as a full-screen card, which counts the same way. The sound setting picks the chiming or the
silent channel (Android won't let a channel's sound change afterwards, hence two); the interval, the
morning/evening windows, quiet hours, the order and `maxStack` all mean what they mean on the desktop.

Nothing ticks on a phone: Android holds one `AlarmManager` alarm at a time, each reminder sets the next
one, and a reboot or an app update sets it again. Force-stopping Azkar — or a battery optimiser doing it
for you — stops reminders until the app is opened again.

### Where the files are

`config.json`, `azkar.json` and `state.json` sit in the app's own storage
(`/data/data/com.wildduck.azkar/files`), in the same format as everywhere else, where only Azkar (or
`adb shell run-as`) can reach them. The azkar that ship in the APK are copied out on the first run. That is
why the phone's settings pages have no "Show the folder", no "Edit azkar.json" and no "Open at login" — and
why the next alarm and the last notification id are kept in SharedPreferences instead of `state.json`,
which belongs to all three apps.

### What the phone asks for

| permission             | asked                             | refused                                              |
| ---------------------- | --------------------------------- | ---------------------------------------------------- |
| notifications          | at the first launch (Android 13+) | the Today page says so, with a button to the setting |
| `SCHEDULE_EXACT_ALARM` | from the Today page (Android 12+) | reminders still arrive, a few minutes late           |
| start after a reboot   | granted by installing             | —                                                    |

### What to check on a phone

- A reminder arrives an interval after the app is first opened, and keeps coming with it closed.
- **Count** ticks the repetitions off one press at a time; the last press clears the notification.
- Tapping a reminder opens the card: tapping the card counts, **×** clears it, back just puts it away.
- Pause, quiet hours and the morning/evening windows behave as on the desktop, and the Today page
  counts down to the next reminder.
- After a reboot, reminders come back without opening the app.

## iPhone

There are two iPhone apps, and they can be installed side by side: **`apple/iOS`** (SwiftUI, on the same
`apple/Core` the Mac app is built from, `com.wildduck.azkar`) and **`kotlin/iosApp`** (the shared Compose
window, on `kotlin/shared`, `com.wildduck.azkar.kmp`, shown as "Azkar KMP"). They read and write the same
files, so a config.json from either one means the same thing.

```sh
apple/build.sh ios   # check the SwiftUI app, draw the icon, generate apple/iOS/Azkar.xcodeproj
cd kotlin/iosApp && xcodegen generate   # and the Compose one (needs `brew install xcodegen`)
```

Open either `.xcodeproj` in Xcode and run it on a simulator or a phone; both are also built for the
simulator in CI. Neither project is checked in — each is generated from the `project.yml` beside it.

A reminder is a notification: the heading ("أذكار الصباح · 7 من 25") and the zikr. Tapping it opens that
zikr as a full-screen card, and tapping the card counts one repetition — ×3 goes 1/3, 2/3, and the last one
closes it. iOS won't let a delivered notification carry a Count button that does arithmetic, so counting
happens on the card.

Nothing ticks on a phone. iOS holds at most **64** pending notifications per app, so on every launch, when
the app comes back to the front, after a settings change, after "Show a zikr now", and whenever iOS grants a
background refresh, Azkar does the same three things: take today's progress from the reminders that have
already fired, plan the next 64 (up to 48 hours ahead), and hand them over. With a three-minute interval
that is about three hours of reminders, which is why the last one says **"Open Azkar to keep reminders
coming"**.

### Where the files are

`config.json`, `state.json` and `plan.json` live in Application Support inside the app's own container,
in the same format as everywhere else; `azkar.json` ships in the app. `plan.json` is the reminders already
handed to iOS — it is a convenience, not a record, and a missing or broken one simply means no plan yet.
That is why the phone's settings pages have no "Show the folder", no "Edit azkar.json" and no "Open at
login": there is nothing there to open.

### What the phone asks for

| permission             | asked                        | refused                                               |
| ---------------------- | ---------------------------- | ----------------------------------------------------- |
| notifications          | the first time the app plans | the Today page says so, with a button to Settings     |
| Background App Refresh | granted by installing        | reminders still come; they just stop between openings |

### What to check on a phone

- A reminder arrives an interval after the app is opened, and keeps coming with the app closed.
- Tapping a reminder opens the card: tapping it counts, **×** closes it, and the count picks up where the
  badge says it is.
- Pause, quiet hours and the morning/evening windows behave as on the desktop, and the Today page counts
  down to the next reminder.
- Refusing notifications shows the "Needs attention" row, and allowing them again in Settings clears it
  the next time the app is opened.
- Both apps installed at once don't tread on each other: two icons, two containers, two sets of reminders.

## Install

```sh
apple/build.sh            # run tests, build, install to ~/Applications, start now and at login
apple/build.sh test       # tests only
apple/build.sh uninstall  # stop and remove the app + LaunchAgent (config stays)
apple/build.sh ios        # check the iPhone app and generate its Xcode project (see iPhone)
```

`apple/build.sh` also runs `stow azkar` if `~/.config/azkar` doesn't exist yet. Only `.config/azkar`
is linked into `$HOME` (see `.stow-local-ignore`). Needs the Xcode command-line tools (`swiftc`).

## Packaging

`./package.sh` builds every app this machine can build and leaves the results in `dist/` (git-ignored,
throw it away freely) next to a `manifest.txt` of sha256 sums.

```sh
./package.sh          # everything this host can build
./package.sh macos    # or one at a time: macos, desktop, android, ios
./package.sh clean    # throw dist/ away
```

What comes out, by machine:

- **macOS** — `azkar-1.0.0-macos-arm64.dmg`, the menu-bar app, as the drag-to-Applications window; and
  the desktop app as `azkar-1.0.0-macos-desktop-arm64.dmg`. (Two different Azkars: the menu-bar one is
  the macOS app, the desktop one is the Compose app running on a Mac for development.)
- **Linux** — `azkar-1.0.0-linux-x64.deb`, and `azkar-1.0.0-linux-x64.AppImage`: one file that runs
  on any distro, with no installer, no root and no package manager. `chmod +x` it and run it.
- **Windows** — `azkar-1.0.0-windows-x64.msi`.
- **Either desktop** — a `-portable.zip` beside the installer: the same app with no installer and no
  root, unzip it and run it.
- **Any machine with an Android SDK** — `azkar-1.0.0-android.apk`, signed with the debug key so it
  installs as it is, and a release APK next to it for signing with your own.
- **A Mac with Xcode** — `azkar-1.0.0-ios.ipa` and `azkar-1.0.0-ios-compose.ipa`, plus a
  `-simulator.app.zip` for each. The simulator builds are arm64 only: `shared/` has no Intel target
  for the Kotlin framework, and a generic simulator destination would ask for one.

Every desktop package carries the architecture it was built for, because an arm64 `.dmg` will not run on
an Intel Mac and saying so in the filename is cheaper than finding out later.

No machine makes the whole set in one go, and the script doesn't pretend otherwise: jpackage only builds
an installer for the OS it runs on, and iOS needs Xcode rather than the command-line tools. Everything
the host couldn't make is listed at the end of the run with the reason — and where there is a way round
it, the reason says so.

Three machines between them do make the whole set, which is what CI is for: every job runs this same
script and uploads what it produced, so a green run has a `azkar-linux`, `azkar-windows` and
`azkar-macos` artifact covering every platform between them. On CI a skip is a failure rather than a note, since every
package that job builds is one the runner is equipped for.

### Cutting a release

Tag a commit and push the tag. That is the whole of it:

```sh
git tag azkar-v1.0.0
git push origin azkar-v1.0.0
```

`azkar-release.yml` reads the version out of the tag, runs the ordinary build on all three machines with
`AZKAR_VERSION` set to it — so `azkar-v1.2.0` ships `azkar-1.2.0-*` files — and collects everything into
one GitHub release, with notes saying which file is for whom and how to get each OS to trust an app
nobody paid to sign. The tests run as part of it: a release that fails its own tests is not published,
and neither is a partial one, since the release job waits on all three builds.

Two things stay out of the release and in the run's artifacts: the `manifest.txt` files (one per
machine, all with the same name) and the unsigned release APK, which no phone will install and which
the installable `.apk` beside it would only be confused with.

If the tag isn't made yet, Actions > azkar-release > Run workflow takes one and creates it on whatever
commit it builds.

### Linux without a Linux machine

`./package.sh linux` builds the `.deb` and the `.AppImage` inside a container, so a Mac or a PC can
make them:

```sh
./package.sh linux                               # linux/amd64, which is what most Linux desktops are
AZKAR_PLATFORM=linux/arm64 ./package.sh linux    # for an ARM box instead (a Pi, an ARM VM)
```

It needs Docker running **with about 4G of memory** — Docker Desktop's default VM is smaller than the
heap `gradle.properties` asks for, and over that limit the kernel kills the Gradle daemon without a word,
so the script checks the size first and says so rather than failing three minutes in (Settings >
Resources > Memory). Inside the container the heap is sized from `/proc/meminfo` rather than taken from
`gradle.properties`, since the container is usually the smaller machine.

On an Apple Silicon Mac the amd64 build is emulated, so the first run is slow: Gradle fetches everything
again inside the container, into an `azkar-gradle-x64` volume that later runs reuse. The container builds
from a copy of the tree, so its Linux `build/` folders never meet the Mac's — copied with `cp`, because
`tar` is one of the things emulation breaks.

The two `.ipa`s are unsigned — Xcode builds them without a developer certificate, and a phone won't run
them until they are re-signed (Xcode, or a sideloading tool). The simulator builds need nothing:
`xcrun simctl install booted Azkar.app`.

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
package.sh              every app this machine can build, into dist/ (see Packaging)
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
  iOS/                  the SwiftUI iPhone app (project.yml -> Azkar.xcodeproj, XcodeGen)
    App/
      AzkarApp          @main, the notification delegate, the background refresh
      Model             the app without a screen: files, plan, progress, problems, actions
      Files             config.json, state.json and plan.json in Application Support
      Reminders         UNUserNotificationCenter: permission, and a plan as notifications
      Pages             Today, Schedule, Reminders, Azkar, General
      CardSheet         the card a tapped reminder opens; Components: rows, tiles, bindings
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
  shared/               what every platform shares
    core/               apple/Core ported file by file (Hotkey without key codes)
    app/                the app without a screen: AzkarController (files, progress, status, problems),
                        CardStack (cards and where they go), StateFile, Storage, Features, KeyNames
    ui/                 the Compose UI: AzkarWindow (Today, Schedule, Cards, Azkar, General), CardView,
                        Theme, Components, Glyphs (the symbol in each tab's tile), ShortcutRecorder
    src/commonTest/     the same test cases as apple/CoreTests, plus the controller, the cards and the window
    src/jvmTest/        ShippedFilesTest: the real .config/azkar files
    src/iosMain/        the parts of the iPhone app only iOS has: IosApp (the controller, the plan
                        and the notifications), IosStorage, Reminders, NotificationDelegate,
                        Entry (startAzkar + the Compose view controller)
  desktopApp/           the Windows and Linux app (Compose for Desktop, packaged by jpackage)
    Main                --background, single instance, the tray, the window and one window per card
    Loop                one tick a second: reload the files, refresh the status, show the next zikr
    DesktopPaths        where the files live on each desktop
    FileStorage         reading and writing them safely (and the azkar that ship with the app)
    Autostart           the autostart entry, the Windows Run value, the menu entry
    Shortcuts           which backend this session gets: WindowsShortcut, X11Shortcut, PortalShortcut
    Triggers, Portal    the key names and the D-Bus interfaces those backends need
    SingleInstance      one Azkar at a time; a second launch opens this one's window
    Chime, Placement, Tray, CardWindows
    tools/              Icon.java draws the app icon; appimage.sh wraps the build up as an AppImage
  androidApp/           the phone app (the same Compose UI, with notifications instead of cards)
    AzkarApp            the controller, the alarm and the notifications, for whatever woke the process
    MainActivity        the window, the card a tapped reminder opens, and the permissions to ask for
    AlarmReceiver       the alarm, the Count button, and setting it all again after a reboot
    Alarms              one AlarmManager alarm at a time (exact when the phone allows it)
    Notifier            posting a reminder: the two channels, the badge, the progress and the buttons
    Notifications, Reminders, Cards, AndroidStorage, Prefs
  iosApp/               the Swift shell around the Compose one (project.yml -> AzkarKMP.xcodeproj)
docs/superpowers/       design spec and implementation plans for the Swift + Kotlin Multiplatform apps
```

Swift is formatted with `swift format` (2 spaces, 120 columns, see `apple/.swift-format`):
`apple/build.sh format`.

Kotlin follows the official Kotlin style (4 spaces, 120 columns, see `kotlin/.editorconfig`).

Progress through today's morning/evening lists and the pause state live in
`~/.local/state/azkar/state.json`.
