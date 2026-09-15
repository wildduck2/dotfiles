# Azkar Stage 2: Kotlin Core + Plan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port the Swift Core to `kotlin/shared` with the same test cases, add `Plan` to both cores, and make both
cores reject JSON booleans where a number is expected.

**Architecture:** A new Gradle project in `azkar/kotlin/` with one Kotlin Multiplatform module, `shared`, targeting
JVM and iOS. Each Swift Core file becomes one Kotlin file in `com.wildduck.azkar.core` with the same behaviour and
error wording; each Swift test case is repeated in `commonTest`, using the Swift case names as assertion messages.
Swift and Kotlin value types map to immutable Kotlin data classes; where Swift mutates `inout` state, Kotlin returns
the new state.

**Tech Stack:** Kotlin 2.4.20, Gradle 9.7.1 (wrapper), JDK 21 toolchain (downloaded by the foojay plugin 1.0.0),
kotlinx-serialization-json 1.11.0, kotlinx-datetime 0.8.0, kotlin.test; Swift 5 mode for `apple/Core`.

**Spec:** `azkar/docs/superpowers/specs/2026-09-15-azkar-kotlin-multiplatform-design.md` (section 2, "Core logic and
parity"; delivery stage 2).

## Global Constraints

- Paths in this plan are relative to `azkar/` (the stow package at `/Users/wildduck/dotfiles/azkar`). Kotlin commands
  run in `azkar/kotlin`; Swift commands run in `azkar/`.
- Kotlin package `com.wildduck.azkar.core`; sources in `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/`,
  tests in `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/`, file-reading tests in
  `kotlin/shared/src/jvmTest/kotlin/com/wildduck/azkar/core/`.
- Targets in stage 2: `jvm()`, `iosArm64()`, `iosSimulatorArm64()`. No Android, Compose or desktop yet (stages 3–4).
- Versions, pinned in `kotlin/gradle/libs.versions.toml`: Kotlin 2.4.20, kotlinx-serialization-json 1.11.0,
  kotlinx-datetime 0.8.0. Gradle wrapper 9.7.1 with
  `distributionSha256Sum=acd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a`. `jvmToolchain(21)`.
- Kotlin style: official (4 spaces, 120 columns). Swift style: `apple/.swift-format` (2 spaces, 120 columns); run
  `apple/build.sh format` after Swift edits.
- Error messages keep the Swift wording exactly, e.g. `intervalMinutes must be a number > 0`.
- `Config.encode()` output is byte-identical between Swift and Kotlin.
- Test parity: every Swift Core test case exists in Kotlin with the same name (as the assertion message). A case for
  shared behaviour added to one suite in this plan is added to the other. Exceptions: APIs that exist on one side
  only (Carbon key codes and `launchAgentPlist` in Swift; `KeyStyle` display in Kotlin).
- No Xcode on this Mac: local Kotlin verification is `./gradlew :shared:jvmTest` plus
  `./gradlew :shared:compileKotlinIosSimulatorArm64`. iOS tests run in CI later.
- Gradle prints one line per test, `ClassName > method() PASSED` (Kotlin Multiplatform may add `[jvm]` to the names);
  failures print the assertion message, which is the Swift case name.
- Git: the dotfiles repo has unrelated uncommitted changes (nvim, tmux, zsh). Stage only `azkar/` paths by name;
  never `git add -A`, `git add .` or `git commit -a`. Commit on `main`. Do not push.

## Not in this stage

- JSON persistence of `AppState` and `Plan` (stage 3 desktop storage, stage 5 iOS).
- The notification body, including "Open Azkar to keep reminders coming" (stage 5).
- Native key codes and `Hotkey.from(keyCode:)` for Kotlin (stage 3 desktop).
- The CI workflow (added with the first stage that is pushed).

## File Map

| File | Responsibility |
| --- | --- |
| `.gitignore` | adds Gradle/Kotlin build output |
| `kotlin/settings.gradle.kts`, `kotlin/build.gradle.kts`, `kotlin/gradle.properties`, `kotlin/.editorconfig` | Gradle project |
| `kotlin/gradle/libs.versions.toml` | pinned versions |
| `kotlin/gradlew`, `kotlin/gradlew.bat`, `kotlin/gradle/wrapper/*` | Gradle wrapper 9.7.1 |
| `kotlin/shared/build.gradle.kts` | the `shared` module: targets, dependencies, jvmTest settings |
| `core/Clock.kt` | `parseClock`, `formatClock`, `minuteOfDay`, `dayKey`, `TimeWindow` |
| `core/Hotkey.kt` | `Modifier`, `KeyStyle`, `Hotkey` (spec parsing, `spec`, `display`) |
| `core/Config.kt` | `Order`, `ConfigError`, `Config` (`decode`, `encode`), Swift-style number formatting |
| `core/Library.kt` | `Zikr`, `Library` (`decode`) |
| `core/Picker.kt` | `Session`, `Card`, `AppState`, `Pick`, `Picker.next` |
| `core/Tick.kt` | `TickDecision`, `decideTick` |
| `core/TapCounter.kt` | `TapCounter` |
| `core/Startup.kt` | `opensWindowAtLaunch` |
| `core/Plan.kt` | `PlannedReminder`, `Plan.make`, `Plan.commit` |
| `commonTest/.../Fixtures.kt` | the Swift `Harness.swift` fixtures: `at`, `instant`, `lib`, `firstIndex`, `Picks`, `expectError` |
| `commonTest/.../*Test.kt` | one test class per core file |
| `jvmTest/.../ShippedFilesTest.kt` | the real `.config/azkar/azkar.json` and `config.json` |
| `apple/Core/Config.swift` | boolean fix |
| `apple/Core/Plan.swift` | `PlannedReminder`, `Plan.make`, `Plan.commit` |
| `apple/CoreTests/ConfigTests.swift`, `ClockTests.swift`, `HotkeyTests.swift` | new parity cases |
| `apple/CoreTests/LibraryTests.swift`, `PlanTests.swift`, `main.swift` | new test files, registered in `main.swift` |
| `README.md` | Kotlin section and layout |

(`core/` = `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/`)

---

### Task 1: Kotlin project and Clock

**Files:**
- Modify: `.gitignore`
- Create: `kotlin/.editorconfig`, `kotlin/settings.gradle.kts`, `kotlin/build.gradle.kts`, `kotlin/gradle.properties`,
  `kotlin/gradle/libs.versions.toml`, `kotlin/shared/build.gradle.kts`
- Create (generated): `kotlin/gradlew`, `kotlin/gradlew.bat`, `kotlin/gradle/wrapper/gradle-wrapper.jar`,
  `kotlin/gradle/wrapper/gradle-wrapper.properties`
- Create: `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Clock.kt`
- Test: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/Fixtures.kt`,
  `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/ClockTest.kt`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `fun parseClock(s: String): Int?`
  - `fun formatClock(minutes: Int): String`
  - `fun minuteOfDay(time: LocalDateTime): Int`
  - `fun dayKey(time: LocalDateTime): String`
  - `data class TimeWindow(val start: Int, val end: Int)` with `operator fun contains(minuteOfDay: Int): Boolean`
  - test fixture `fun at(day: Int, h: Int, m: Int): LocalDateTime` (September 2026)

- [ ] **Step 1: Ignore Gradle and Kotlin build output**

Replace the contents of `.gitignore` with:

```
.build/
.gradle/
.kotlin/
build/
local.properties
```

- [ ] **Step 2: Write the Gradle project files**

`kotlin/.editorconfig`:

```
root = true

[*.{kt,kts}]
indent_style = space
indent_size = 4
max_line_length = 120
```

`kotlin/gradle/libs.versions.toml`:

```toml
[versions]
kotlin = "2.4.20"
kotlinx-serialization = "1.11.0"
kotlinx-datetime = "0.8.0"

[libraries]
kotlin-test = { module = "org.jetbrains.kotlin:kotlin-test", version.ref = "kotlin" }
kotlinx-serialization-json = { module = "org.jetbrains.kotlinx:kotlinx-serialization-json", version.ref = "kotlinx-serialization" }
kotlinx-datetime = { module = "org.jetbrains.kotlinx:kotlinx-datetime", version.ref = "kotlinx-datetime" }

[plugins]
kotlinMultiplatform = { id = "org.jetbrains.kotlin.multiplatform", version.ref = "kotlin" }
kotlinSerialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
```

`kotlin/settings.gradle.kts`:

```kotlin
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}

plugins {
    // Downloads the JDK 21 toolchain into ~/.gradle/jdks when it isn't installed.
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

dependencyResolutionManagement {
    repositories {
        mavenCentral()
    }
}

rootProject.name = "azkar"

include(":shared")
```

`kotlin/build.gradle.kts`:

```kotlin
plugins {
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.kotlinSerialization) apply false
}
```

`kotlin/gradle.properties`:

```properties
kotlin.code.style=official
org.gradle.jvmargs=-Xmx3g -Dfile.encoding=UTF-8
org.gradle.caching=true
org.gradle.configuration-cache=true
```

`kotlin/shared/build.gradle.kts`:

```kotlin
import org.gradle.api.tasks.testing.logging.TestExceptionFormat

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.kotlinSerialization)
}

kotlin {
    jvmToolchain(21)

    jvm()
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        commonMain.dependencies {
            api(libs.kotlinx.datetime)
            implementation(libs.kotlinx.serialization.json)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
}

tasks.named<Test>("jvmTest") {
    testLogging {
        events("passed", "failed")
        exceptionFormat = TestExceptionFormat.FULL
    }
}
```

(`kotlinx-datetime` is `api` because `Picker.next` and `Plan.make` take its types.)

- [ ] **Step 3: Generate the Gradle wrapper**

Any Gradle 9 can generate the wrapper. If none is installed, download 9.7.1 and check its SHA-256 first:

```bash
cd /Users/wildduck/dotfiles/azkar/kotlin
tmp=$(mktemp -d)
curl -fsSL -o "$tmp/gradle.zip" https://services.gradle.org/distributions/gradle-9.7.1-bin.zip
echo "acd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a  $tmp/gradle.zip" | shasum -a 256 -c
unzip -q "$tmp/gradle.zip" -d "$tmp"
"$tmp/gradle-9.7.1/bin/gradle" wrapper --gradle-version 9.7.1 --distribution-type bin \
  --gradle-distribution-sha256-sum acd53f1edaf02f1a8ff99879f8a34b302661a057d9b063ae9e35b552f804d20a
./gradlew --version
```

Expected: `shasum` prints `OK`; `./gradlew --version` prints `Gradle 9.7.1`. The files `gradlew`, `gradlew.bat`,
`gradle/wrapper/gradle-wrapper.jar` and `gradle/wrapper/gradle-wrapper.properties` now exist, and the properties file
contains the `distributionSha256Sum` line.

- [ ] **Step 4: Write the failing Clock tests**

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/Fixtures.kt`:

```kotlin
// Fixtures shared by the core tests, the same as apple/CoreTests/Harness.swift.
package com.wildduck.azkar.core

import kotlinx.datetime.LocalDateTime

/** A time on a day in September 2026 (the tests use UTC wherever a time zone is needed). */
fun at(day: Int, h: Int, m: Int): LocalDateTime = LocalDateTime(2026, 9, day, h, m)
```

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/ClockTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

class ClockTest {
    @Test
    fun parsing() {
        assertEquals(330, parseClock("05:30"), "parses HH:mm")
        assertEquals(330, parseClock("5:30"), "parses H:mm")
        assertEquals(0, parseClock("00:00"), "parses midnight")
        assertNull(parseClock("24:00"), "rejects hour 24")
        assertNull(parseClock("12:60"), "rejects minute 60")
        assertNull(parseClock("noon"), "rejects garbage")
        assertEquals(930, minuteOfDay(at(14, 15, 30)), "minute of day")
        assertEquals("2026-09-04", dayKey(at(4, 23, 59)), "day key is yyyy-MM-dd")
    }

    @Test
    fun timeWindows() {
        val morning = TimeWindow(start = 300, end = 660)
        assertTrue(300 in morning, "window includes its start")
        assertTrue(659 in morning, "window includes the minute before its end")
        assertFalse(660 in morning, "window excludes its end")
        assertFalse(299 in morning, "window excludes before start")

        val night = TimeWindow(start = 1410, end = 300) // 23:30 -> 05:00
        assertTrue(1425 in night, "overnight window includes 23:45")
        assertTrue(10 in night, "overnight window includes 00:10")
        assertFalse(300 in night, "overnight window excludes 05:00")
        assertFalse(720 in night, "overnight window excludes noon")
    }

    @Test
    fun formatting() {
        assertEquals("05:30", formatClock(330), "formats minutes as HH:mm")
        assertEquals("00:00", formatClock(0), "formats midnight")
        assertEquals("23:59", formatClock(1439), "formats the last minute")
    }
}
```

(The Swift suite gains the same `day key is yyyy-MM-dd` case in Task 3.)

- [ ] **Step 5: Run the tests to verify they fail**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest`
Expected: FAIL in `:shared:compileTestKotlinJvm` with `Unresolved reference 'parseClock'` (and the other Clock
names). The first run downloads the Kotlin plugin, dependencies and, if missing, JDK 21.

- [ ] **Step 6: Write Clock.kt**

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Clock.kt`:

```kotlin
// Clock times (minutes after midnight) and the daily time windows made from them.
package com.wildduck.azkar.core

import kotlinx.datetime.LocalDateTime

/** "HH:mm" (or "H:mm") -> minutes after midnight. */
fun parseClock(s: String): Int? {
    val parts = s.split(":")
    if (parts.size != 2 || parts[1].length != 2) return null
    val h = parts[0].toIntOrNull() ?: return null
    val m = parts[1].toIntOrNull() ?: return null
    if (h !in 0..23 || m !in 0..59) return null
    return h * 60 + m
}

/** Minutes after midnight -> "HH:mm". */
fun formatClock(minutes: Int): String =
    (minutes / 60).toString().padStart(2, '0') + ":" + (minutes % 60).toString().padStart(2, '0')

fun minuteOfDay(time: LocalDateTime): Int = time.hour * 60 + time.minute

/** "yyyy-MM-dd": the day that today's morning/evening progress belongs to. */
fun dayKey(time: LocalDateTime): String = time.date.toString()

/** [start, end) in minutes after midnight; wraps past midnight when end < start. */
data class TimeWindow(val start: Int, val end: Int) {
    operator fun contains(minuteOfDay: Int): Boolean =
        if (start <= end) minuteOfDay >= start && minuteOfDay < end else minuteOfDay >= start || minuteOfDay < end
}
```

- [ ] **Step 7: Run the tests and the iOS compile**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest :shared:compileKotlinIosSimulatorArm64`
Expected: `BUILD SUCCESSFUL`; the log shows `ClockTest > parsing() PASSED`, `timeWindows() PASSED` and
`formatting() PASSED`. The iOS compile checks that common code uses no JVM-only API; it works without Xcode.

- [ ] **Step 8: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/.gitignore azkar/kotlin
git status --short azkar
git commit -m "feat(azkar): add Kotlin Multiplatform project with Clock"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `git status` lists only files under `azkar/kotlin` plus `azkar/.gitignore`, and no `build/`, `.gradle/`
or `.kotlin/` directories; the last command prints `only azkar/ files`.

---

### Task 2: Hotkey

**Files:**
- Create: `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Hotkey.kt`
- Test: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/HotkeyTest.kt`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `enum class Modifier { Ctrl, Alt, Shift, Cmd }` with `val names: List<String>` (first name is canonical)
  - `enum class KeyStyle { Apple, Windows, Linux }`
  - `data class Hotkey(val modifiers: Set<Modifier>, val key: String)` with `val spec: String`,
    `fun display(style: KeyStyle): String`, `companion object { val keys: List<String>; fun parse(s: String): Hotkey? }`

The Swift `Hotkey` stores Carbon key codes. The Kotlin one stores the key name (`"z"`, `"f5"`, `"return"`); the
desktop app maps names to native key codes in stage 3. The Swift key-code cases (`kVK_*`, `Hotkey.from`) move to
stage 3; the parse, spec and display cases are repeated here.

- [ ] **Step 1: Write the failing Hotkey tests**

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/HotkeyTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class HotkeyTest {
    @Test
    fun parsesTheDefaultShortcut() {
        val hk = Hotkey.parse("ctrl+alt+z")
        assertEquals("z", hk?.key, "ctrl+alt+z key")
        assertEquals(setOf(Modifier.Ctrl, Modifier.Alt), hk?.modifiers, "ctrl+alt+z modifiers")
        assertEquals("⌃⌥Z", hk?.display(KeyStyle.Apple), "ctrl+alt+z display")
    }

    @Test
    fun modifierNamesAndAliases() {
        assertEquals(
            setOf(Modifier.Shift, Modifier.Cmd),
            Hotkey.parse("Command+Shift+1")?.modifiers,
            "modifier names are case-insensitive",
        )
        assertEquals("space", Hotkey.parse("cmd+opt+control+space")?.key, "aliases and named keys")
        assertEquals("ctrl+z", Hotkey.parse(" ctrl ++ z ")?.spec, "spaces and empty parts are ignored")
    }

    @Test
    fun rejectsIncompleteShortcuts() {
        assertNull(Hotkey.parse("z"), "a hotkey needs a modifier")
        assertNull(Hotkey.parse("ctrl+foo"), "unknown key")
        assertNull(Hotkey.parse("ctrl+alt"), "a hotkey needs a key")
        assertNull(Hotkey.parse("ctrl+z+x"), "only one key")
    }

    @Test
    fun specIsNormalized() {
        assertEquals("shift+cmd+1", Hotkey.parse("Command+Shift+1")?.spec, "spec is normalized, in display order")
        assertEquals("ctrl+alt+z", Hotkey.parse("ctrl+alt+z")?.spec, "default spec")
    }

    @Test
    fun everyKeyParsesAndRoundTrips() {
        assertEquals(64, Hotkey.keys.size, "the same 64 keys as the macOS app")
        for (name in Hotkey.keys) {
            val h = Hotkey.parse("ctrl+$name")
            assertEquals(name, h?.key, "key for '$name'")
            assertEquals(h, h?.let { Hotkey.parse(it.spec) }, "spec round-trips for '$name'")
        }
    }

    @Test
    fun displayStyles() {
        assertEquals("Ctrl+Alt+Z", Hotkey.parse("ctrl+alt+z")?.display(KeyStyle.Windows), "Windows display")
        assertEquals("Shift+Win+1", Hotkey.parse("cmd+shift+1")?.display(KeyStyle.Windows), "cmd is the Windows key")
        assertEquals("Shift+Super+1", Hotkey.parse("cmd+shift+1")?.display(KeyStyle.Linux), "cmd is Super on Linux")
        assertEquals("Ctrl+Enter", Hotkey.parse("ctrl+return")?.display(KeyStyle.Linux), "named keys on Windows/Linux")
        assertEquals("⌃↩", Hotkey.parse("ctrl+return")?.display(KeyStyle.Apple), "named keys on Apple")
        assertEquals("⌘F5", Hotkey.parse("cmd+f5")?.display(KeyStyle.Apple), "function keys")
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest --tests 'com.wildduck.azkar.core.HotkeyTest'`
Expected: FAIL in `:shared:compileTestKotlinJvm` with `Unresolved reference 'Hotkey'`.

- [ ] **Step 3: Write Hotkey.kt**

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Hotkey.kt`:

```kotlin
package com.wildduck.azkar.core

/** Shortcut modifiers, in the order they are written and displayed. `names[0]` is the one config.json uses. */
enum class Modifier(val names: List<String>, private val symbol: String, private val label: String) {
    Ctrl(listOf("ctrl", "control"), "⌃", "Ctrl"),
    Alt(listOf("alt", "opt", "option"), "⌥", "Alt"),
    Shift(listOf("shift"), "⇧", "Shift"),
    Cmd(listOf("cmd", "command"), "⌘", "Super");

    fun display(style: KeyStyle): String = when {
        style == KeyStyle.Apple -> symbol
        this == Cmd && style == KeyStyle.Windows -> "Win"
        else -> label
    }
}

/** How a shortcut is shown: Apple symbols (⌃⌥Z), or key names joined with + (Ctrl+Alt+Z). */
enum class KeyStyle { Apple, Windows, Linux }

/** A global shortcut such as "ctrl+alt+z": one or more modifiers plus one key, by name. */
data class Hotkey(val modifiers: Set<Modifier>, val key: String) {
    /** Canonical "ctrl+alt+z" form, as written to config.json. */
    val spec: String
        get() = (Modifier.entries.filter { it in modifiers }.map { it.names[0] } + key).joinToString("+")

    fun display(style: KeyStyle): String {
        val mods = Modifier.entries.filter { it in modifiers }.map { it.display(style) }
        return if (style == KeyStyle.Apple) {
            mods.joinToString("") + (appleKeyLabels[key] ?: key.uppercase())
        } else {
            (mods + (pcKeyLabels[key] ?: key.uppercase())).joinToString("+")
        }
    }

    companion object {
        /** Every key a shortcut can use: the keys the macOS app has key codes for. */
        val keys: List<String> =
            ('a'..'z').map { it.toString() } + ('0'..'9').map { it.toString() } +
                listOf("=", "-", "]", "[", "'", ";", "\\", ",", "/", ".", "`") +
                listOf("return", "tab", "space", "delete", "escape") + (1..12).map { "f$it" }

        private val appleKeyLabels =
            mapOf("return" to "↩", "tab" to "⇥", "space" to "Space", "delete" to "⌫", "escape" to "⎋")
        private val pcKeyLabels =
            mapOf("return" to "Enter", "tab" to "Tab", "space" to "Space", "delete" to "Backspace", "escape" to "Esc")

        /** Parses "ctrl+alt+z": one or more modifiers plus exactly one key, case-insensitive. */
        fun parse(s: String): Hotkey? {
            val mods = mutableSetOf<Modifier>()
            var key: String? = null
            for (part in s.lowercase().split("+").filter { it.isNotEmpty() }.map { it.trim() }) {
                val modifier = Modifier.entries.firstOrNull { part in it.names }
                when {
                    modifier != null -> mods += modifier
                    key == null && part in keys -> key = part
                    else -> return null
                }
            }
            if (mods.isEmpty() || key == null) return null
            return Hotkey(mods, key)
        }
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest :shared:compileKotlinIosSimulatorArm64`
Expected: `BUILD SUCCESSFUL`; all six `HotkeyTest` methods and the three `ClockTest` methods `PASSED`.

- [ ] **Step 5: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/kotlin/shared/src
git commit -m "feat(azkar): port Hotkey spec parsing to Kotlin"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `only azkar/ files`.

---
### Task 3: Swift: booleans are not numbers, and the new parity cases

**Files:**
- Modify: `apple/Core/Config.swift` (the `intervalMinutes`, `maxStack` and `fontSize` checks in `decode`)
- Modify: `apple/CoreTests/ConfigTests.swift`, `apple/CoreTests/ClockTests.swift`, `apple/CoreTests/HotkeyTests.swift`,
  `apple/CoreTests/main.swift`
- Create: `apple/CoreTests/LibraryTests.swift`

**Interfaces:**
- Consumes: nothing new.
- Produces: no new API. `Config.decode` now throws for `{"intervalMinutes": true}`, `{"maxStack": true}` and
  `{"fontSize": true}` (today it reads them as 1). New test cases that Tasks 1, 2, 4 and 5 repeat in Kotlin:
  `day key is yyyy-MM-dd`, `only one key`, `spaces and empty parts are ignored`, the boolean/string/whole-number
  cases, `defaults are written in the settings window's layout`, the `fontSize … is written as Swift writes it`
  table, and `libraryTests`.

- [ ] **Step 1: Write the new Swift test cases**

In `apple/CoreTests/ClockTests.swift`, after `eq(minuteOfDay(at(14, 15, 30), cal), 930, "minute of day")`, add:

```swift
  eq(dayKey(at(4, 23, 59), cal), "2026-09-04", "day key is yyyy-MM-dd")
```

In `apple/CoreTests/HotkeyTests.swift`, after `eq(Hotkey.parse("ctrl+alt"), nil, "a hotkey needs a key")`, add:

```swift
  eq(Hotkey.parse("ctrl+z+x"), nil, "only one key")
  eq(Hotkey.parse(" ctrl ++ z ")?.spec, "ctrl+z", "spaces and empty parts are ignored")
```

In `apple/CoreTests/ConfigTests.swift`, after the line
`expectError("not json", mentioning: "JSON") { _ = try Config.decode(Data("{nope".utf8)) }`, add:

```swift

  // JSON booleans and strings are not numbers; whole numbers may be written with a fraction or an exponent.
  expectError("a boolean is not an interval", mentioning: "intervalMinutes") {
    _ = try Config.decode(Data(#"{"intervalMinutes": true}"#.utf8))
  }
  expectError("a boolean is not a max stack", mentioning: "maxStack") {
    _ = try Config.decode(Data(#"{"maxStack": true}"#.utf8))
  }
  expectError("a boolean is not a font size", mentioning: "fontSize") {
    _ = try Config.decode(Data(#"{"fontSize": true}"#.utf8))
  }
  expectError("a string is not a number", mentioning: "fontSize") {
    _ = try Config.decode(Data(#"{"fontSize": "22"}"#.utf8))
  }
  do {
    eq(try Config.decode(Data(#"{"maxStack": 3.0}"#.utf8)).maxStack, 3, "3.0 is a whole number")
    eq(try Config.decode(Data(#"{"maxStack": 1e2}"#.utf8)).maxStack, 100, "1e2 is a whole number")
  } catch {
    failed += 1
    print("FAIL whole numbers threw \(error)")
  }
```

At the end of `configTests()` (after the `encode round-trip` do/catch, before the closing `}`), add:

```swift

  // The exact bytes. kotlin/shared ConfigTest has the same text and number table, so both apps write the same file.
  let defaults = """
    {
      "intervalMinutes": 3,
      "hotkey": "ctrl+alt+z",
      "order": "random",
      "repeatGeneral": false,
      "maxStack": 5,
      "sabah": { "start": "05:00", "end": "11:00" },
      "masaa": { "start": "15:30", "end": "21:00" },
      "quietHours": { "start": "23:30", "end": "05:00" },
      "fontSize": 22,
      "sound": false,
      "showCount": true,
      "openAtLogin": true,
      "showWindowAtLogin": false
    }

    """
  eq(String(decoding: Config().encode(), as: UTF8.self), defaults, "defaults are written in the settings window's layout")

  let numbers: [(Double, String)] = [
    (3, "3"), (0.5, "0.5"), (26.5, "26.5"), (0.1 + 0.2, "0.30000000000000004"), (0.0001, "0.0001"),
    (0.00001, "1e-05"), (1.5e-7, "1.5e-07"), (12345678.5, "12345678.5"), (99999999999999.5, "99999999999999.5"),
    (1e15, "1000000000000000.0"), (9_007_199_254_740_992, "9007199254740992.0"),
    (9_007_199_254_740_994, "9.007199254740994e+15"), (1.25e16, "1.25e+16"), (1e100, "1e+100"),
  ]
  for (n, text) in numbers {
    var c = Config()
    c.fontSize = n
    check(
      String(decoding: c.encode(), as: UTF8.self).contains("\n  \"fontSize\": \(text),\n"),
      "fontSize \(text) is written as Swift writes it")
  }
```

(The line before the closing `"""` of `defaults` is empty, so the text ends with a newline like the encoder's.)

Create `apple/CoreTests/LibraryTests.swift`:

```swift
import Foundation

/// azkar.json decoding (kotlin/shared LibraryTest has the same cases).
func libraryTests() {
  do {
    let json = #"""
      {"sabah": [{"text": "a", "source": "x"}, {"text": "b", "count": 3, "note": "n", "ref": 86}], "masaa": null}
      """#
    let l = try Library.decode(Data(json.utf8))
    eq(l.sabah.first?.text, "a", "unknown keys are ignored")
    eq(l.sabah.first?.count, 1, "count defaults to 1")
    eq(l.sabah.first?.note, nil, "note is optional")
    eq(l.sabah.first?.ref, nil, "ref is optional")
    eq(l.sabah.last, Zikr(text: "b", count: 3, note: "n", ref: 86), "a zikr with every field")
    eq(l.masaa, [], "a null list is empty")
    eq(l.general, [], "a missing list is empty")
  } catch {
    failed += 1
    print("FAIL library decode threw \(error)")
  }
  expectError("a zikr needs text", mentioning: "text") {
    _ = try Library.decode(Data(#"{"general": [{"count": 3}]}"#.utf8))
  }
}
```

In `apple/CoreTests/main.swift`, after `configTests()`, add the line `libraryTests()`.

- [ ] **Step 2: Run the Swift tests to verify the boolean cases fail**

Run (in `azkar/`): `apple/build.sh test`
Expected: exit status non-zero, with exactly these three failures and every other case passing:

```
FAIL [line …] a boolean is not an interval: expected an error
FAIL [line …] a boolean is not a max stack: expected an error
FAIL [line …] a boolean is not a font size: expected an error
… passed, 3 failed
```

(The other new cases describe what Swift already does, so they pass now; they are there so Kotlin has to match.)

- [ ] **Step 3: Reject booleans in Config.decode**

In `apple/Core/Config.swift`, add this helper inside `struct Config`, directly above
`/// Missing keys keep their defaults; \`null\` disables a time window.`:

```swift
  /// JSONSerialization returns booleans as NSNumber too, so `true as? Double` is 1. Only real numbers count.
  private static func isNumber(_ v: Any) -> Bool {
    guard let n = v as? NSNumber else { return false }
    return CFGetTypeID(n) != CFBooleanGetTypeID()
  }

```

Then change the three numeric checks in `decode`:

```swift
      guard let n = v as? Double, n > 0 else { throw ConfigError("intervalMinutes must be a number > 0") }
```
becomes
```swift
      guard isNumber(v), let n = v as? Double, n > 0 else { throw ConfigError("intervalMinutes must be a number > 0") }
```

```swift
      guard let n = v as? Int, n >= 1 else { throw ConfigError("maxStack must be a whole number >= 1") }
```
becomes
```swift
      guard isNumber(v), let n = v as? Int, n >= 1 else { throw ConfigError("maxStack must be a whole number >= 1") }
```

```swift
      guard let n = v as? Double, n > 0 else { throw ConfigError("fontSize must be a number > 0") }
```
becomes
```swift
      guard isNumber(v), let n = v as? Double, n > 0 else { throw ConfigError("fontSize must be a number > 0") }
```

- [ ] **Step 4: Format, then run all Swift tests**

Run (in `azkar/`): `apple/build.sh format && apple/build.sh test && git status --short .`
Expected: the Core tests print `… passed, 0 failed`, the UI tests pass, the script exits 0, and `git status` lists
only the six files of this task (formatting may re-wrap the lines you added, and nothing else).

- [ ] **Step 5: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/apple/Core/Config.swift azkar/apple/CoreTests
git commit -m "fix(azkar): reject JSON booleans as numbers in config.json"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `only azkar/ files`.

---

### Task 4: Config in Kotlin

**Files:**
- Create: `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Config.kt`
- Modify: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/Fixtures.kt` (adds `expectError`)
- Test: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/ConfigTest.kt`

**Interfaces:**
- Consumes: `parseClock`, `formatClock`, `TimeWindow` (Task 1); `Hotkey`, `Modifier` (Task 2).
- Produces:
  - `enum class Order(val raw: String) { Random, Sequential }`
  - `class ConfigError(message: String) : Exception(message)`
  - `data class Config(intervalMinutes: Double = 3.0, hotkey: Hotkey, order: Order, repeatGeneral: Boolean,
    maxStack: Int = 5, sabah: TimeWindow?, masaa: TimeWindow?, quietHours: TimeWindow?, fontSize: Double = 22.0,
    sound: Boolean, showCount: Boolean, openAtLogin: Boolean, showWindowAtLogin: Boolean)`, all `val`, with the Swift
    defaults, `fun encode(): String` and `companion object { fun decode(text: String): Config }`
  - test fixture `fun expectError(name: String, mentioning: String, block: () -> Unit)`

Notes for the implementer:
- `Json.parseToJsonElement` accepts unquoted words such as `abc`, `Infinity` or `3d` as values, which Swift's
  `JSONSerialization` rejects. `number()` therefore only accepts text matching the JSON number grammar.
- `JsonPrimitive("22").doubleOrNull` is 22.0 even though it is a string, so always check `isString`.
- Swift writes non-whole numbers with `String(Double)`. Kotlin's `Double.toString()` gives the same shortest digits
  in a different layout (`1.0E-4` for Swift's `0.0001`), so `swiftDescription` takes the digits apart and lays them
  out as Swift does. Checked on the JVM for all values in the test table and more. Kotlin/Native is not checked
  locally (no Xcode); the same table runs on the iOS simulator in CI later.
- `maxStack` above `Int.MAX_VALUE` is rejected in Kotlin (Swift's `Int` is 64-bit). No test.

- [ ] **Step 1: Add expectError to the fixtures**

Replace `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/Fixtures.kt` with:

```kotlin
// Fixtures shared by the core tests, the same as apple/CoreTests/Harness.swift.
package com.wildduck.azkar.core

import kotlin.test.assertFailsWith
import kotlin.test.assertTrue
import kotlinx.datetime.LocalDateTime

/** A time on a day in September 2026 (the tests use UTC wherever a time zone is needed). */
fun at(day: Int, h: Int, m: Int): LocalDateTime = LocalDateTime(2026, 9, day, h, m)

/** `block` must throw a ConfigError whose message mentions `mentioning`. */
fun expectError(name: String, mentioning: String, block: () -> Unit) {
    val error = assertFailsWith<ConfigError>(name) { block() }
    assertTrue(
        error.message.orEmpty().contains(mentioning),
        "$name: error '${error.message}' should mention '$mentioning'",
    )
}
```

- [ ] **Step 2: Write the failing Config tests**

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/ConfigTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class ConfigTest {
    @Test
    fun emptyConfigUsesDefaults() {
        val c = Config.decode("{}")
        assertEquals(Config(), c, "empty config uses defaults")
        assertEquals(3.0, c.intervalMinutes, "default interval")
        assertEquals(5, c.maxStack, "default max stack")
        assertEquals(Order.Random, c.order, "default order")
        assertEquals(Hotkey.parse("ctrl+alt+z"), c.hotkey, "default hotkey")
        assertEquals(TimeWindow(300, 660), c.sabah, "default sabah window")
        assertEquals(TimeWindow(930, 1260), c.masaa, "default masaa window")
        assertEquals(TimeWindow(1410, 300), c.quietHours, "default quiet hours")
        assertEquals(false, c.repeatGeneral, "general azkar are one tap by default")
    }

    @Test
    fun repeatGeneral() {
        assertEquals(true, Config.decode("""{"repeatGeneral": true}""").repeatGeneral, "repeatGeneral override")
        expectError("repeatGeneral must be a bool", mentioning = "repeatGeneral") {
            Config.decode("""{"repeatGeneral": 1}""")
        }
    }

    @Test
    fun generalPageSwitches() {
        val c = Config()
        assertEquals(true, c.openAtLogin, "starts at login by default")
        assertEquals(false, c.showWindowAtLogin, "starts quietly in the menu bar by default")
        assertEquals(true, c.showCount, "shows the card count next to 📿 by default")
        assertEquals(false, c.sound, "no sound by default")
        val o = Config.decode("""{"openAtLogin": false, "showWindowAtLogin": true, "showCount": false, "sound": true}""")
        assertEquals(false, o.openAtLogin, "openAtLogin override")
        assertEquals(true, o.showWindowAtLogin, "showWindowAtLogin override")
        assertEquals(false, o.showCount, "showCount override")
        assertEquals(true, o.sound, "sound override")
        for (key in listOf("openAtLogin", "showWindowAtLogin", "showCount", "sound")) {
            expectError("$key must be a bool", mentioning = key) { Config.decode("""{"$key": "yes"}""") }
        }
    }

    @Test
    fun partialConfig() {
        val c = Config.decode(
            """{"intervalMinutes": 0.5, "order": "sequential", "quietHours": null, "sabah": {"start": "04:30", "end": "10:00"}}""",
        )
        assertEquals(0.5, c.intervalMinutes, "interval override")
        assertEquals(Order.Sequential, c.order, "order override")
        assertNull(c.quietHours, "null disables quiet hours")
        assertEquals(TimeWindow(270, 600), c.sabah, "sabah override")
        assertEquals(Config().masaa, c.masaa, "unspecified keys keep defaults")
    }

    @Test
    fun invalidValues() {
        expectError("zero interval", mentioning = "intervalMinutes") { Config.decode("""{"intervalMinutes": 0}""") }
        expectError("zero max stack", mentioning = "maxStack") { Config.decode("""{"maxStack": 0}""") }
        expectError("bad hotkey", mentioning = "hotkey") { Config.decode("""{"hotkey": "ctrl+foo"}""") }
        expectError("bad order", mentioning = "order") { Config.decode("""{"order": "shuffle"}""") }
        expectError("bad clock", mentioning = "sabah") {
            Config.decode("""{"sabah": {"start": "25:00", "end": "11:00"}}""")
        }
        expectError("not json", mentioning = "JSON") { Config.decode("{nope") }
    }

    @Test
    fun booleansAndStringsAreNotNumbers() {
        expectError("a boolean is not an interval", mentioning = "intervalMinutes") {
            Config.decode("""{"intervalMinutes": true}""")
        }
        expectError("a boolean is not a max stack", mentioning = "maxStack") {
            Config.decode("""{"maxStack": true}""")
        }
        expectError("a boolean is not a font size", mentioning = "fontSize") {
            Config.decode("""{"fontSize": true}""")
        }
        expectError("a string is not a number", mentioning = "fontSize") { Config.decode("""{"fontSize": "22"}""") }
        assertEquals(3, Config.decode("""{"maxStack": 3.0}""").maxStack, "3.0 is a whole number")
        assertEquals(100, Config.decode("""{"maxStack": 1e2}""").maxStack, "1e2 is a whole number")
    }

    @Test
    fun encoding() {
        val c = Config(
            intervalMinutes = 0.5,
            hotkey = Hotkey.parse("cmd+shift+f5")!!,
            order = Order.Sequential,
            repeatGeneral = true,
            maxStack = 2,
            sabah = null,
            masaa = TimeWindow(1020, 1200),
            quietHours = null,
            fontSize = 26.5,
            sound = true,
            showCount = false,
            openAtLogin = false,
            showWindowAtLogin = true,
        )
        assertEquals(c, Config.decode(c.encode()), "encode round-trips through decode")
        val text = c.encode()
        assertTrue(""""sabah": null""" in text, "a switched-off window is written as null")
        assertTrue(""""masaa": { "start": "17:00", "end": "20:00" }""" in text, "windows are written as HH:mm")
        assertTrue(""""intervalMinutes": 0.5""" in text, "fractional numbers keep their fraction")
        assertEquals(Config(), Config.decode(Config().encode()), "defaults round-trip")
    }

    @Test
    fun exactBytes() {
        val defaults = """
            {
              "intervalMinutes": 3,
              "hotkey": "ctrl+alt+z",
              "order": "random",
              "repeatGeneral": false,
              "maxStack": 5,
              "sabah": { "start": "05:00", "end": "11:00" },
              "masaa": { "start": "15:30", "end": "21:00" },
              "quietHours": { "start": "23:30", "end": "05:00" },
              "fontSize": 22,
              "sound": false,
              "showCount": true,
              "openAtLogin": true,
              "showWindowAtLogin": false
            }
        """.trimIndent() + "\n"
        assertEquals(defaults, Config().encode(), "defaults are written in the settings window's layout")

        val numbers = listOf(
            3.0 to "3", 0.5 to "0.5", 26.5 to "26.5", 0.1 + 0.2 to "0.30000000000000004", 0.0001 to "0.0001",
            0.00001 to "1e-05", 1.5e-7 to "1.5e-07", 12345678.5 to "12345678.5", 99999999999999.5 to "99999999999999.5",
            1e15 to "1000000000000000.0", 9007199254740992.0 to "9007199254740992.0",
            9007199254740994.0 to "9.007199254740994e+15", 1.25e16 to "1.25e+16", 1e100 to "1e+100",
        )
        for ((n, text) in numbers) {
            assertTrue(
                "\n  \"fontSize\": $text,\n" in Config(fontSize = n).encode(),
                "fontSize $text is written as Swift writes it",
            )
        }
    }
}
```

- [ ] **Step 3: Run the tests to verify they fail**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest --tests 'com.wildduck.azkar.core.ConfigTest'`
Expected: FAIL in `:shared:compileTestKotlinJvm` with `Unresolved reference 'ConfigError'` and `'Config'`.

- [ ] **Step 4: Write Config.kt**

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Config.kt`:

```kotlin
// config.json: decoding (missing keys keep their defaults) and the canonical form the settings page writes.
package com.wildduck.azkar.core

import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.round
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull

enum class Order(val raw: String) { Random("random"), Sequential("sequential") }

class ConfigError(message: String) : Exception(message)

data class Config(
    val intervalMinutes: Double = 3.0,
    val hotkey: Hotkey = Hotkey(setOf(Modifier.Ctrl, Modifier.Alt), "z"),
    val order: Order = Order.Random,
    /** Off: general azkar are one tap each. On: they keep their full count (e.g. ×100). */
    val repeatGeneral: Boolean = false,
    val maxStack: Int = 5,
    val sabah: TimeWindow? = TimeWindow(5 * 60, 11 * 60),
    val masaa: TimeWindow? = TimeWindow(15 * 60 + 30, 21 * 60),
    val quietHours: TimeWindow? = TimeWindow(23 * 60 + 30, 5 * 60),
    val fontSize: Double = 22.0,
    /** Play a sound when a new card appears. */
    val sound: Boolean = false,
    /** The number of waiting cards next to the menu-bar or tray icon. */
    val showCount: Boolean = true,
    /** Start at login, in the background. */
    val openAtLogin: Boolean = true,
    /** Also open the window when starting at login. */
    val showWindowAtLogin: Boolean = false,
) {
    /** The config.json the settings page writes: the same bytes as Swift's `Config.encode()`. */
    fun encode(): String {
        fun string(s: String) = "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
        fun window(w: TimeWindow?) =
            if (w == null) "null" else "{ \"start\": ${string(formatClock(w.start))}, \"end\": ${string(formatClock(w.end))} }"

        val fields = listOf(
            "intervalMinutes" to formatNumber(intervalMinutes),
            "hotkey" to string(hotkey.spec),
            "order" to string(order.raw),
            "repeatGeneral" to repeatGeneral.toString(),
            "maxStack" to maxStack.toString(),
            "sabah" to window(sabah),
            "masaa" to window(masaa),
            "quietHours" to window(quietHours),
            "fontSize" to formatNumber(fontSize),
            "sound" to sound.toString(),
            "showCount" to showCount.toString(),
            "openAtLogin" to openAtLogin.toString(),
            "showWindowAtLogin" to showWindowAtLogin.toString(),
        )
        return fields.joinToString(",\n", prefix = "{\n", postfix = "\n}\n") { (key, value) -> "  \"$key\": $value" }
    }

    companion object {
        /** Missing keys keep their defaults; `null` disables a time window. Errors use the Swift app's wording. */
        fun decode(text: String): Config {
            val json = try {
                Json.parseToJsonElement(text)
            } catch (e: SerializationException) {
                throw ConfigError("not valid JSON (${e.message?.lineSequence()?.first()})")
            }
            val obj = json as? JsonObject ?: throw ConfigError("must be a JSON object")

            var c = Config()
            obj["intervalMinutes"]?.let { v ->
                val n = v.number()
                if (n == null || n <= 0) throw ConfigError("intervalMinutes must be a number > 0")
                c = c.copy(intervalMinutes = n)
            }
            obj["maxStack"]?.let { v ->
                val n = v.number()
                if (n == null || n != floor(n) || n < 1 || n > Int.MAX_VALUE) {
                    throw ConfigError("maxStack must be a whole number >= 1")
                }
                c = c.copy(maxStack = n.toInt())
            }
            obj["hotkey"]?.let { v ->
                val hotkey = v.string()?.let { Hotkey.parse(it) }
                    ?: throw ConfigError(
                        "hotkey ${(v as? JsonPrimitive)?.content ?: v} is not valid, use e.g. \"ctrl+alt+z\"",
                    )
                c = c.copy(hotkey = hotkey)
            }
            obj["order"]?.let { v ->
                val order = Order.entries.firstOrNull { it.raw == v.string() }
                    ?: throw ConfigError("order must be \"random\" or \"sequential\"")
                c = c.copy(order = order)
            }

            fun switch(key: String, current: Boolean): Boolean {
                val v = obj[key] ?: return current
                return (v as? JsonPrimitive)?.takeUnless { it.isString }?.booleanOrNull
                    ?: throw ConfigError("$key must be true or false")
            }
            c = c.copy(
                repeatGeneral = switch("repeatGeneral", c.repeatGeneral),
                sound = switch("sound", c.sound),
                showCount = switch("showCount", c.showCount),
                openAtLogin = switch("openAtLogin", c.openAtLogin),
                showWindowAtLogin = switch("showWindowAtLogin", c.showWindowAtLogin),
            )

            obj["fontSize"]?.let { v ->
                val n = v.number()
                if (n == null || n <= 0) throw ConfigError("fontSize must be a number > 0")
                c = c.copy(fontSize = n)
            }

            fun window(key: String, current: TimeWindow?): TimeWindow? {
                val v = obj[key] ?: return current
                if (v is JsonNull) return null
                val w = v as? JsonObject
                val start = w?.get("start")?.string()?.let(::parseClock)
                val end = w?.get("end")?.string()?.let(::parseClock)
                if (start == null || end == null) {
                    throw ConfigError("$key must be null or {\"start\": \"HH:mm\", \"end\": \"HH:mm\"}")
                }
                return TimeWindow(start, end)
            }
            return c.copy(
                sabah = window("sabah", c.sabah),
                masaa = window("masaa", c.masaa),
                quietHours = window("quietHours", c.quietHours),
            )
        }
    }
}

// The JSON number grammar. kotlinx.serialization also reads unquoted words (`abc`, `Infinity`, `3d`) as values,
// which Swift's JSONSerialization rejects.
private val jsonNumber = Regex("""-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?""")

/** A JSON number as a Double; null for booleans, strings, null and anything else. */
private fun JsonElement.number(): Double? =
    (this as? JsonPrimitive)?.takeIf { !it.isString && jsonNumber.matches(it.content) }?.content?.toDouble()

private fun JsonElement.string(): String? = (this as? JsonPrimitive)?.takeIf { it.isString }?.content

/** A number as Swift's `Config.encode()` writes it: whole numbers below 1e15 as integers, others as `String(n)`. */
private fun formatNumber(n: Double): String =
    if (n == round(n) && abs(n) < 1e15) n.toLong().toString() else swiftDescription(n)

/**
 * Swift's `String(n)` for a Double: the shortest digits that read back as `n`, as a plain decimal ("0.0001",
 * "1000000000000000.0"), or with an exponent below 1e-4 or above 2^53 ("1e-05", "1.25e+16").
 */
private fun swiftDescription(n: Double): String {
    if (n.isNaN()) return "nan"
    if (n.isInfinite()) return if (n > 0) "inf" else "-inf"
    // Kotlin prints the same shortest digits, laid out differently: "0.5", "1.0E-4", "1.23456785E7".
    val text = abs(n).toString()
    val mantissa = text.substringBefore('E').substringBefore('e')
    val shift = text.substringAfter('E', text.substringAfter('e', "0")).toInt()
    val whole = mantissa.substringBefore('.')
    val all = whole + mantissa.substringAfter('.', "")
    val digits = all.trimStart('0').trimEnd('0')
    // n = d.ddd × 10^exponent
    val exponent = whole.length - (all.length - all.trimStart('0').length) - 1 + shift
    val body = when {
        abs(n) > 9007199254740992.0 || exponent < -4 -> {
            val fraction = digits.drop(1)
            digits.take(1) + (if (fraction.isEmpty()) "" else ".$fraction") +
                "e" + (if (exponent < 0) "-" else "+") + abs(exponent).toString().padStart(2, '0')
        }
        exponent < 0 -> "0." + "0".repeat(-exponent - 1) + digits
        else -> digits.take(exponent + 1).padEnd(exponent + 1, '0') + "." + digits.drop(exponent + 1).ifEmpty { "0" }
    }
    return (if (n < 0) "-" else "") + body
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest :shared:compileKotlinIosSimulatorArm64`
Expected: `BUILD SUCCESSFUL`; all eight `ConfigTest` methods `PASSED`, and the Clock and Hotkey tests still pass.

- [ ] **Step 6: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/kotlin/shared/src
git commit -m "feat(azkar): port Config decoding and encoding to Kotlin"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `only azkar/ files`.

---

### Task 5: Library and the shipped files in Kotlin

**Files:**
- Create: `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Library.kt`
- Modify: `kotlin/shared/build.gradle.kts` (the `jvmTest` block)
- Test: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/LibraryTest.kt`,
  `kotlin/shared/src/jvmTest/kotlin/com/wildduck/azkar/core/ShippedFilesTest.kt`

**Interfaces:**
- Consumes: `ConfigError`, `Config.decode`, `Config.encode` (Task 4).
- Produces:
  - `@Serializable data class Zikr(val text: String, val count: Int = 1, val note: String? = null, val ref: Int? = null)`
  - `@Serializable data class Library(val sabah: List<Zikr> = emptyList(), val masaa: List<Zikr> = emptyList(),
    val general: List<Zikr> = emptyList())` with `companion object { fun decode(text: String): Library }`
  - JVM system property `azkar.package` in `jvmTest`: the absolute path of `azkar/`

- [ ] **Step 1: Write the failing Library tests**

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/LibraryTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class LibraryTest {
    @Test
    fun decoding() {
        val l = Library.decode(
            """{"sabah": [{"text": "a", "source": "x"}, {"text": "b", "count": 3, "note": "n", "ref": 86}], "masaa": null}""",
        )
        assertEquals("a", l.sabah.first().text, "unknown keys are ignored")
        assertEquals(1, l.sabah.first().count, "count defaults to 1")
        assertNull(l.sabah.first().note, "note is optional")
        assertNull(l.sabah.first().ref, "ref is optional")
        assertEquals(Zikr("b", 3, "n", 86), l.sabah.last(), "a zikr with every field")
        assertEquals(emptyList(), l.masaa, "a null list is empty")
        assertEquals(emptyList(), l.general, "a missing list is empty")
    }

    @Test
    fun aZikrNeedsText() {
        expectError("a zikr needs text", mentioning = "text") { Library.decode("""{"general": [{"count": 3}]}""") }
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest --tests 'com.wildduck.azkar.core.LibraryTest'`
Expected: FAIL in `:shared:compileTestKotlinJvm` with `Unresolved reference 'Library'` and `'Zikr'`.

- [ ] **Step 3: Write Library.kt**

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Library.kt`:

```kotlin
// azkar.json: the morning, evening and general lists.
package com.wildduck.azkar.core

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

/** One zikr. `count` may be omitted in azkar.json (defaults to 1); `note` and `ref` are optional. */
@Serializable
data class Zikr(val text: String, val count: Int = 1, val note: String? = null, val ref: Int? = null)

/** Any of the three lists may be omitted. */
@Serializable
data class Library(
    val sabah: List<Zikr> = emptyList(),
    val masaa: List<Zikr> = emptyList(),
    val general: List<Zikr> = emptyList(),
) {
    companion object {
        // Like Swift's JSONDecoder: unknown keys are ignored, and null counts as missing.
        private val json = Json {
            ignoreUnknownKeys = true
            coerceInputValues = true
        }

        fun decode(text: String): Library =
            try {
                json.decodeFromString(Library.serializer(), text)
            } catch (e: SerializationException) {
                throw ConfigError(e.message ?: "not a valid azkar.json")
            }
    }
}
```

(A missing `text` gives kotlinx.serialization's message, `Field 'text' is required for type with serial name
'com.wildduck.azkar.core.Zikr', but it was missing at path: $.general[0]`.)

- [ ] **Step 4: Run the tests to verify they pass**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest --tests 'com.wildduck.azkar.core.LibraryTest'`
Expected: `BUILD SUCCESSFUL`; `decoding()` and `aZikrNeedsText()` `PASSED`.

- [ ] **Step 5: Write the failing shipped-files test**

`kotlin/shared/src/jvmTest/kotlin/com/wildduck/azkar/core/ShippedFilesTest.kt`:

```kotlin
package com.wildduck.azkar.core

import java.io.File
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** The azkar.json and config.json in azkar/.config/azkar, as apple/CoreTests/ShippedFilesTests.swift checks them. */
class ShippedFilesTest {
    // Set by shared/build.gradle.kts: the azkar/ stow package.
    private val dir = File(requireNotNull(System.getProperty("azkar.package")) { "run with ./gradlew jvmTest" })
        .resolve(".config/azkar")

    @Test
    fun shippedAzkarJson() {
        val shipped = Library.decode(dir.resolve("azkar.json").readText())
        assertEquals(25, shipped.sabah.size, "shipped sabah count")
        assertEquals(23, shipped.masaa.size, "shipped masaa count")
        assertEquals(22, shipped.general.size, "shipped general count")
        val all = shipped.sabah + shipped.masaa + shipped.general
        assertTrue(all.all { it.text.isNotEmpty() && it.count >= 1 }, "every shipped zikr has text and a count")
    }

    @Test
    fun shippedConfigJson() {
        // The live file the macOS settings window writes to (through stow), so it can differ from the defaults, but
        // it must be valid and in exactly the format both apps write.
        val text = dir.resolve("config.json").readText()
        assertEquals(Config.decode(text).encode(), text, "config.json is in the format the settings window writes")
    }
}
```

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest --tests 'com.wildduck.azkar.core.ShippedFilesTest'`
Expected: FAIL, both methods, with `java.lang.IllegalArgumentException: run with ./gradlew jvmTest` (the property
is not set yet).

- [ ] **Step 6: Pass the azkar/ path to jvmTest**

In `kotlin/shared/build.gradle.kts`, replace the `tasks.named<Test>("jvmTest") { … }` block with:

```kotlin
val azkarPackage: File = rootDir.parentFile

tasks.named<Test>("jvmTest") {
    // ShippedFilesTest reads the real azkar.json and config.json; rerun it when they change.
    systemProperty("azkar.package", azkarPackage.absolutePath)
    inputs.dir(azkarPackage.resolve(".config/azkar")).withPropertyName("shippedFiles")
    testLogging {
        events("passed", "failed")
        exceptionFormat = TestExceptionFormat.FULL
    }
}
```

- [ ] **Step 7: Run all Kotlin tests**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest :shared:compileKotlinIosSimulatorArm64`
Expected: `BUILD SUCCESSFUL`; `ShippedFilesTest > shippedAzkarJson() PASSED`, `shippedConfigJson() PASSED`, and every
earlier test still passes. If `shippedConfigJson` fails, compare the two texts in the failure message: the Kotlin
encoder differs from Swift's (fix `Config.encode`, not the file).

- [ ] **Step 8: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/kotlin/shared
git commit -m "feat(azkar): port Library to Kotlin and test the shipped files"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `only azkar/ files`.

---

### Task 6: Tick, TapCounter and opensWindowAtLaunch in Kotlin

**Files:**
- Create: `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Tick.kt`,
  `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/TapCounter.kt`,
  `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Startup.kt`
- Test: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/TickTest.kt`,
  `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/TapCounterTest.kt`,
  `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/StartupTest.kt`

**Interfaces:**
- Consumes: `Config` (Task 4).
- Produces:
  - `sealed interface TickDecision { data object Show; data class Skip(val reason: String) }`
  - `fun decideTick(paused: Boolean, locked: Boolean, quiet: Boolean, stackCount: Int, maxStack: Int): TickDecision`
  - `class TapCounter(target: Int)` with `val target: Int`, `val done: Int` (private set), `val isComplete: Boolean`,
    `fun tap(): Boolean`, `val badge: String`, `val fraction: Double`
  - `fun opensWindowAtLaunch(arguments: List<String>, config: Config): Boolean`

`TapCounter` is a small mutable class, like the Swift `mutating` struct: one counter lives with one card.

- [ ] **Step 1: Write the failing tests**

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/TickTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals

class TickTest {
    @Test
    fun decisions() {
        assertEquals(
            TickDecision.Show,
            decideTick(paused = false, locked = false, quiet = false, stackCount = 0, maxStack = 5),
            "normal tick shows",
        )
        assertEquals(
            TickDecision.Skip("paused"),
            decideTick(paused = true, locked = false, quiet = false, stackCount = 0, maxStack = 5),
            "paused",
        )
        assertEquals(
            TickDecision.Skip("screen locked"),
            decideTick(paused = false, locked = true, quiet = false, stackCount = 0, maxStack = 5),
            "locked",
        )
        assertEquals(
            TickDecision.Skip("quiet hours"),
            decideTick(paused = false, locked = false, quiet = true, stackCount = 0, maxStack = 5),
            "quiet",
        )
        assertEquals(
            TickDecision.Skip("stack full"),
            decideTick(paused = false, locked = false, quiet = false, stackCount = 5, maxStack = 5),
            "full",
        )
    }
}
```

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/TapCounterTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** Each click or shortcut press counts once; the card closes when the count is reached. */
class TapCounterTest {
    @Test
    fun counting() {
        val one = TapCounter(target = 1)
        assertEquals("", one.badge, "×1 cards show no badge")
        assertTrue(one.tap(), "a single tap completes a ×1 zikr")

        val three = TapCounter(target = 3)
        assertEquals("×3", three.badge, "untouched badge shows the target")
        assertFalse(three.tap(), "first of three taps does not complete")
        assertEquals("1/3", three.badge, "badge counts taps")
        assertFalse(three.tap(), "second of three taps does not complete")
        assertEquals("2/3", three.badge, "badge counts taps again")
        assertTrue(three.tap(), "third tap completes")
        assertTrue(three.isComplete, "complete after reaching the target")
        three.tap()
        assertEquals(3, three.done, "extra taps do not overshoot")

        val four = TapCounter(target = 4)
        four.tap()
        assertEquals(0.25, four.fraction, "fraction done")

        assertTrue(TapCounter(target = 0).tap(), "a target below 1 behaves like 1")
    }
}
```

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/StartupTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** Whether the window opens when the app starts. */
class StartupTest {
    @Test
    fun windowAtLaunch() {
        assertTrue(opensWindowAtLaunch(listOf("Azkar"), Config()), "opened by hand: the window shows")
        assertFalse(opensWindowAtLaunch(listOf("Azkar", "--background"), Config()), "at login: menu bar only")
        assertTrue(
            opensWindowAtLaunch(listOf("Azkar", "--background"), Config(showWindowAtLogin = true)),
            "at login, if asked: the window shows",
        )
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest`
Expected: FAIL in `:shared:compileTestKotlinJvm` with `Unresolved reference` for `decideTick`, `TickDecision`,
`TapCounter` and `opensWindowAtLaunch`.

- [ ] **Step 3: Write the three files**

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Tick.kt`:

```kotlin
package com.wildduck.azkar.core

/** What a reminder tick does: show a card, or skip it and say why. */
sealed interface TickDecision {
    data object Show : TickDecision

    data class Skip(val reason: String) : TickDecision
}

fun decideTick(paused: Boolean, locked: Boolean, quiet: Boolean, stackCount: Int, maxStack: Int): TickDecision =
    when {
        paused -> TickDecision.Skip("paused")
        locked -> TickDecision.Skip("screen locked")
        quiet -> TickDecision.Skip("quiet hours")
        stackCount >= maxStack -> TickDecision.Skip("stack full")
        else -> TickDecision.Show
    }
```

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/TapCounter.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.math.max
import kotlin.math.min

/** Repetitions of one zikr: each click or shortcut press is one tap; the card closes at `target`. */
class TapCounter(target: Int) {
    val target: Int = max(1, target)

    var done: Int = 0
        private set

    val isComplete: Boolean get() = done >= target

    /** Returns true once the target is reached. */
    fun tap(): Boolean {
        done = min(done + 1, target)
        return isComplete
    }

    /** "" for ×1, "×3" before the first tap, then "1/3", "2/3"… */
    val badge: String
        get() = when {
            target == 1 -> ""
            done == 0 -> "×$target"
            else -> "$done/$target"
        }

    val fraction: Double get() = done.toDouble() / target
}
```

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Startup.kt`:

```kotlin
// Whether the window opens when the app starts. (The macOS LaunchAgent plist stays in Swift.)
package com.wildduck.azkar.core

/** Opened by hand: always. Started at login (`--background`): only if asked. */
fun opensWindowAtLaunch(arguments: List<String>, config: Config): Boolean =
    "--background" !in arguments || config.showWindowAtLogin
```

- [ ] **Step 4: Run the tests to verify they pass**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest :shared:compileKotlinIosSimulatorArm64`
Expected: `BUILD SUCCESSFUL`; `TickTest > decisions()`, `TapCounterTest > counting()` and
`StartupTest > windowAtLaunch()` `PASSED`, earlier tests still pass.

- [ ] **Step 5: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/kotlin/shared/src
git commit -m "feat(azkar): port Tick, TapCounter and window-at-launch to Kotlin"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `only azkar/ files`.

---

### Task 7: Picker in Kotlin

**Files:**
- Create: `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Picker.kt`
- Modify: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/Fixtures.kt` (adds `z`, `lib`, `firstIndex`, `Picks`)
- Test: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/PickerTest.kt`

**Interfaces:**
- Consumes: `dayKey`, `minuteOfDay`, `TimeWindow.contains` (Task 1); `Config`, `Order` (Task 4); `Zikr`, `Library`
  (Task 5).
- Produces:
  - `enum class Session(val raw: String) { Sabah, Masaa, General }`
  - `data class Card(val zikr: Zikr, val session: Session, val position: Int? = null, val total: Int? = null)`
  - `data class AppState(val day: String = "", val sabah: Int = 0, val masaa: Int = 0, val general: Int = 0,
    val lastGeneral: Int? = null, val paused: Boolean = false)`
  - `data class Pick(val card: Card?, val state: AppState)`
  - `object Picker { fun next(at: LocalDateTime, config: Config, library: Library, state: AppState,
    random: (Int) -> Int): Pick }`
  - test fixtures `fun z(text: String): Zikr`, `val lib: Library` (s1–s3, m1–m2, g1–g3), `val firstIndex: (Int) -> Int`,
    `class Picks(var state: AppState = AppState())` with
    `fun pick(date: LocalDateTime, config: Config = Config(), library: Library = lib, random: (Int) -> Int = firstIndex): Card?`

Swift's `Picker.next` changes `state` in place (`inout`); the Kotlin one returns the new state in `Pick`, including
when there is no card (the day may still have rolled over). `Picks` keeps that state between picks so the tests read
like the Swift ones.

- [ ] **Step 1: Add the picker fixtures**

Replace `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/Fixtures.kt` with:

```kotlin
// Fixtures shared by the core tests, the same as apple/CoreTests/Harness.swift.
package com.wildduck.azkar.core

import kotlin.test.assertFailsWith
import kotlin.test.assertTrue
import kotlinx.datetime.LocalDateTime

/** A time on a day in September 2026 (the tests use UTC wherever a time zone is needed). */
fun at(day: Int, h: Int, m: Int): LocalDateTime = LocalDateTime(2026, 9, day, h, m)

fun z(text: String): Zikr = Zikr(text)

val lib = Library(
    sabah = listOf(z("s1"), z("s2"), z("s3")),
    masaa = listOf(z("m1"), z("m2")),
    general = listOf(z("g1"), z("g2"), z("g3")),
)

val firstIndex: (Int) -> Int = { 0 }

/** Picks cards one after another, keeping the state between picks like the Swift tests' `inout` state. */
class Picks(var state: AppState = AppState()) {
    fun pick(
        date: LocalDateTime,
        config: Config = Config(),
        library: Library = lib,
        random: (Int) -> Int = firstIndex,
    ): Card? {
        val result = Picker.next(date, config, library, state, random)
        state = result.state
        return result.card
    }
}

/** `block` must throw a ConfigError whose message mentions `mentioning`. */
fun expectError(name: String, mentioning: String, block: () -> Unit) {
    val error = assertFailsWith<ConfigError>(name) { block() }
    assertTrue(
        error.message.orEmpty().contains(mentioning),
        "$name: error '${error.message}' should mention '$mentioning'",
    )
}
```

- [ ] **Step 2: Write the failing Picker tests**

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/PickerTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertNull

class PickerTest {
    @Test
    fun morningList() {
        val p = Picks()
        val c1 = p.pick(at(14, 6, 0))
        assertEquals("s1", c1?.zikr?.text, "sabah window starts at the first morning zikr")
        assertEquals(Session.Sabah, c1?.session, "session is sabah")
        assertEquals(1, c1?.position, "sabah position 1")
        assertEquals(3, c1?.total, "sabah total")
        assertEquals("s2", p.pick(at(14, 6, 3))?.zikr?.text, "second morning zikr")
        assertEquals("s3", p.pick(at(14, 6, 6))?.zikr?.text, "third morning zikr")
        val after = p.pick(at(14, 6, 9))
        assertEquals(Session.General, after?.session, "finished sabah falls back to general")
        assertNull(after?.position, "general cards have no position")

        // next day restarts the morning list
        assertEquals("s1", p.pick(at(15, 6, 0))?.zikr?.text, "a new day restarts sabah")
    }

    @Test
    fun eveningList() {
        val p = Picks()
        assertEquals("m1", p.pick(at(14, 16, 0))?.zikr?.text, "masaa window starts at the first evening zikr")
        assertEquals(Session.Masaa, p.pick(at(14, 16, 3))?.session, "session is masaa")
    }

    @Test
    fun sequentialGeneralWrapsAround() {
        val p = Picks()
        val cfg = Config(order = Order.Sequential)
        val texts = (0 until 4).mapNotNull { i -> p.pick(at(14, 13, i), cfg)?.zikr?.text }
        assertEquals(listOf("g1", "g2", "g3", "g1"), texts, "sequential general wraps around")
    }

    @Test
    fun randomNeverRepeats() {
        val p = Picks()
        // A random source that always says 0 must still never show the same zikr twice in a row.
        val texts = (0 until 4).mapNotNull { i -> p.pick(at(14, 13, i))?.zikr?.text }
        for ((a, b) in texts.zipWithNext()) assertNotEquals(a, b, "random never repeats consecutively ($texts)")
    }

    @Test
    fun disabledSabahWindow() {
        val card = Picks().pick(at(14, 6, 0), Config(sabah = null))
        assertEquals(Session.General, card?.session, "disabled sabah window is skipped")
    }

    @Test
    fun generalBetweenWindows() {
        // Between the morning and evening windows, and after them, the general azkar show.
        val p = Picks()
        for ((h, m) in listOf(11 to 0, 13 to 0, 15 to 29, 21 to 0)) {
            val card = p.pick(at(14, h, m))
            assertEquals(Session.General, card?.session, "$h:$m is outside both windows, so a general zikr")
        }
        assertEquals(0, p.state.sabah, "general cards don't use up the morning list")
        assertEquals(0, p.state.masaa, "general cards don't use up the evening list")
        assertEquals(Session.Masaa, p.pick(at(14, 15, 30))?.session, "the evening list starts at 15:30")
    }

    @Test
    fun onlyTimedListsKeepCounts() {
        // General azkar are one tap each; only the morning/evening lists keep their counts.
        val counted = Library(
            sabah = listOf(Zikr("s", 3)),
            masaa = listOf(Zikr("m", 4)),
            general = listOf(Zikr("g", 100)),
        )
        val p = Picks()
        assertEquals(1, p.pick(at(14, 13, 0), library = counted)?.zikr?.count, "a ×100 general zikr is one tap")
        assertEquals(3, p.pick(at(14, 6, 0), library = counted)?.zikr?.count, "morning azkar keep their count")
        assertEquals(
            1,
            p.pick(at(14, 6, 3), library = counted)?.zikr?.count,
            "general after the morning list is one tap",
        )
        assertEquals(4, p.pick(at(14, 16, 0), library = counted)?.zikr?.count, "evening azkar keep their count")
        assertEquals(
            100,
            p.pick(at(14, 13, 3), Config(repeatGeneral = true), counted)?.zikr?.count,
            "repeatGeneral keeps the full count",
        )
    }

    @Test
    fun nothingToShow() {
        assertNull(Picks().pick(at(14, 13, 0), library = Library()), "nothing to show")
    }
}
```

- [ ] **Step 3: Run the tests to verify they fail**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest`
Expected: FAIL in `:shared:compileTestKotlinJvm` with `Unresolved reference` for `Picker`, `AppState`, `Card` and
`Session`.

- [ ] **Step 4: Write Picker.kt**

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Picker.kt`:

```kotlin
// Picking the next card, and the progress through today's lists that it keeps.
package com.wildduck.azkar.core

import kotlinx.datetime.LocalDateTime

enum class Session(val raw: String) { Sabah("sabah"), Masaa("masaa"), General("general") }

data class Card(
    val zikr: Zikr,
    val session: Session,
    /** 1-based position within the morning/evening list; null for general azkar. */
    val position: Int? = null,
    val total: Int? = null,
)

/** Kept between launches so the morning/evening lists continue where they left off today. */
data class AppState(
    val day: String = "",
    val sabah: Int = 0,
    val masaa: Int = 0,
    val general: Int = 0,
    val lastGeneral: Int? = null,
    val paused: Boolean = false,
)

/** The picked card (null when there is nothing to show) and the state after picking. */
data class Pick(val card: Card?, val state: AppState)

object Picker {
    /**
     * Inside the morning (evening) window, walks that list in order once per day; otherwise, or once the list is
     * done, picks from `general` (one tap each unless `repeatGeneral`). `random(n)` must return 0 until n.
     */
    fun next(at: LocalDateTime, config: Config, library: Library, state: AppState, random: (Int) -> Int): Pick {
        val today = dayKey(at)
        var st = if (state.day == today) state else state.copy(day = today, sabah = 0, masaa = 0)
        val minute = minuteOfDay(at)

        val sabah = library.sabah
        if (config.sabah?.contains(minute) == true && st.sabah < sabah.size) {
            val i = st.sabah
            return Pick(Card(sabah[i], Session.Sabah, i + 1, sabah.size), st.copy(sabah = i + 1))
        }
        val masaa = library.masaa
        if (config.masaa?.contains(minute) == true && st.masaa < masaa.size) {
            val i = st.masaa
            return Pick(Card(masaa[i], Session.Masaa, i + 1, masaa.size), st.copy(masaa = i + 1))
        }

        val general = library.general
        if (general.isEmpty()) return Pick(null, st)
        val i: Int
        when (config.order) {
            Order.Sequential -> {
                i = st.general % general.size
                st = st.copy(general = i + 1)
            }
            Order.Random -> {
                val last = st.lastGeneral
                i = when {
                    general.size == 1 -> 0
                    // Skip `last` so the same zikr never shows twice in a row.
                    last != null && last < general.size -> random(general.size - 1).let { r -> if (r >= last) r + 1 else r }
                    else -> random(general.size)
                }
            }
        }
        val zikr = if (config.repeatGeneral) general[i] else general[i].copy(count = 1)
        return Pick(Card(zikr, Session.General), st.copy(lastGeneral = i))
    }
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest :shared:compileKotlinIosSimulatorArm64`
Expected: `BUILD SUCCESSFUL`; all eight `PickerTest` methods `PASSED`, earlier tests still pass.

- [ ] **Step 6: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/kotlin/shared/src
git commit -m "feat(azkar): port Picker to Kotlin"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `only azkar/ files`.

---

### Task 8: Plan in Swift

**Files:**
- Create: `apple/Core/Plan.swift`
- Test: `apple/CoreTests/PlanTests.swift`
- Modify: `apple/CoreTests/main.swift` (adds `planTests()`)

**Interfaces:**
- Consumes: `Picker.next`, `AppState`, `Card` (`apple/Core/Picker.swift`); `minuteOfDay`, `TimeWindow`
  (`apple/Core/Clock.swift`); test fixtures `cal`, `at`, `lib`, `firstIndex` (`apple/CoreTests/Harness.swift`).
- Produces:
  - `struct PlannedReminder: Equatable { var fireAt: Date; var card: Card; var state: AppState }`
  - `enum Plan` with
    `static func make(now: Date, calendar: Calendar, config: Config, library: Library, state: AppState,
    limit: Int = 64, horizon: TimeInterval = 48 * 3600, random: (Int) -> Int = { Int.random(in: 0..<$0) }) -> [PlannedReminder]`
    and `static func commit(_ plan: [PlannedReminder], now: Date, current: AppState) -> AppState`

Behaviour (spec section 2): reminders at `now + interval`, `now + 2 × interval`, … Ticks inside quiet hours are
skipped (time still advances). A tick where the picker has no card is skipped too. Stops after `limit` reminders or
once the next tick would be later than `now + horizon` (a tick exactly at the horizon is included). A paused state,
or an interval ≤ 0, gives an empty plan. `maxStack` does not apply. `commit` returns the state of the last reminder
whose `fireAt <= now`, or `current` if none has fired.

- [ ] **Step 1: Write the failing Plan tests**

`apple/CoreTests/PlanTests.swift`:

```swift
import Foundation

/// The reminders an iPhone schedules ahead as notifications (kotlin/shared PlanTest has the same cases).
func planTests() {
  func plan(
    _ now: Date, config: Config = Config(), library: Library = lib, state: AppState = AppState(), limit: Int = 64
  ) -> [PlannedReminder] {
    Plan.make(now: now, calendar: cal, config: config, library: library, state: state, limit: limit, random: firstIndex)
  }

  do {
    let p = plan(at(14, 12, 0))
    eq(p.first?.fireAt, at(14, 12, 3), "the first reminder is one interval after now")
    eq(p.dropFirst().first?.fireAt, at(14, 12, 6), "reminders are one interval apart")
    eq(p.count, 64, "up to 64 reminders")
  }

  do {
    var cfg = Config()
    cfg.maxStack = 1
    eq(plan(at(14, 12, 0), config: cfg).count, 64, "maxStack does not limit the plan")
    eq(plan(at(14, 12, 0), limit: 5).count, 5, "stops at the limit")
  }

  do {
    var cfg = Config()
    cfg.intervalMinutes = 60
    cfg.quietHours = nil
    let p = plan(at(14, 12, 0), config: cfg)
    eq(p.count, 48, "stops at the horizon")
    eq(p.last?.fireAt, at(16, 12, 0), "a reminder exactly at the horizon is included")
  }

  do {
    var cfg = Config()
    cfg.intervalMinutes = 30
    eq(plan(at(14, 23, 0), config: cfg).first?.fireAt, at(15, 5, 0), "quiet hours are skipped")
  }

  do {
    let p = plan(at(14, 5, 57))
    eq(p.prefix(4).map(\.card.zikr.text), ["s1", "s2", "s3", "g1"], "the morning list continues through the plan")
    eq(p.first?.state.sabah, 1, "each reminder carries the state after its card")
    eq(p.dropFirst(2).first?.state.sabah, 3, "the state after the third card")
    let resumed = plan(at(14, 6, 0), state: AppState(day: "2026-09-14", sabah: 2))
    eq(resumed.first?.card.zikr.text, "s3", "the plan starts from the given state")
  }

  do {
    var cfg = Config()
    cfg.intervalMinutes = 60
    cfg.quietHours = nil
    let p = plan(at(14, 9, 30), config: cfg)
    eq(
      p.first { $0.fireAt == at(15, 5, 30) }?.card.zikr.text, "s1",
      "a new day restarts the morning list inside the plan")
  }

  do {
    var paused = AppState()
    paused.paused = true
    eq(plan(at(14, 12, 0), state: paused).count, 0, "a paused state plans nothing")
    let empty = Library(sabah: [], masaa: [], general: [])
    eq(plan(at(14, 12, 0), library: empty).count, 0, "nothing to show plans nothing")
    var cfg = Config()
    cfg.intervalMinutes = 0
    eq(plan(at(14, 12, 0), config: cfg).count, 0, "a zero interval plans nothing")
  }

  // Committing: the app keeps the state of the reminders that have fired, then makes a new plan.
  do {
    let start = AppState(day: "2026-09-14")
    let p = plan(at(14, 6, 0), state: start)  // 06:03 s1, 06:06 s2, 06:09 s3, …
    eq(Plan.commit(p, now: at(14, 6, 2), current: start), start, "before any reminder fires, the state stays as it is")
    eq(
      Plan.commit(p, now: at(14, 6, 7), current: start), p[1].state,
      "commit keeps the state after the last reminder that fired")
    eq(Plan.commit(p, now: at(14, 6, 9), current: start), p[2].state, "a reminder firing exactly now counts as fired")
    eq(Plan.commit(p, now: at(20, 0, 0), current: start), p.last?.state, "after the whole plan, the last reminder's state")
    eq(Plan.commit([], now: at(14, 6, 7), current: start), start, "an empty plan keeps the current state")
  }
}
```

In `apple/CoreTests/main.swift`, after `pickerTests()`, add the line `planTests()`.

- [ ] **Step 2: Run the tests to verify they fail**

Run (in `azkar/`): `apple/build.sh test`
Expected: FAIL at compile time with `cannot find 'Plan' in scope` and `cannot find type 'PlannedReminder' in scope`.

- [ ] **Step 3: Write Plan.swift**

`apple/Core/Plan.swift`:

```swift
// The reminders ahead, for phones that can't run code every few minutes: iOS schedules them as notifications.
import Foundation

struct PlannedReminder: Equatable {
  var fireAt: Date
  var card: Card
  /// The state after this card, which the app keeps once the reminder has fired.
  var state: AppState
}

enum Plan {
  /// One reminder per interval after `now` (the first at `now + interval`), until `limit` reminders or `horizon`
  /// seconds. Ticks in quiet hours are skipped. Paused: none. `maxStack` doesn't apply, since nothing stacks up.
  static func make(
    now: Date, calendar: Calendar, config: Config, library: Library, state: AppState,
    limit: Int = 64, horizon: TimeInterval = 48 * 3600, random: (Int) -> Int = { Int.random(in: 0..<$0) }
  ) -> [PlannedReminder] {
    guard !state.paused, config.intervalMinutes > 0 else { return [] }
    var state = state
    var plan: [PlannedReminder] = []
    var step = 1
    while plan.count < limit {
      let offset = Double(step) * config.intervalMinutes * 60
      step += 1
      if offset > horizon { break }
      let date = now.addingTimeInterval(offset)
      if let quiet = config.quietHours, quiet.contains(minuteOfDay: minuteOfDay(date, calendar)) { continue }
      guard
        let card = Picker.next(
          at: date, calendar: calendar, config: config, library: library, state: &state, random: random)
      else { continue }
      plan.append(PlannedReminder(fireAt: date, card: card, state: state))
    }
    return plan
  }

  /// The state after the last reminder that has fired by `now`, or `current` if none has.
  static func commit(_ plan: [PlannedReminder], now: Date, current: AppState) -> AppState {
    plan.last { $0.fireAt <= now }?.state ?? current
  }
}
```

- [ ] **Step 4: Format, then run all Swift tests**

Run (in `azkar/`): `apple/build.sh format && apple/build.sh test && git status --short .`
Expected: Core tests `… passed, 0 failed`, UI tests pass, exit 0; `git status` lists only `apple/Core/Plan.swift`,
`apple/CoreTests/PlanTests.swift` and `apple/CoreTests/main.swift`.

- [ ] **Step 5: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/apple/Core/Plan.swift azkar/apple/CoreTests/PlanTests.swift azkar/apple/CoreTests/main.swift
git commit -m "feat(azkar): add Plan to the Swift Core"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `only azkar/ files`.

---

### Task 9: Plan in Kotlin, README, and the stage check

**Files:**
- Create: `kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Plan.kt`
- Modify: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/Fixtures.kt` (adds `instant`)
- Test: `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/PlanTest.kt`
- Modify: `README.md`

**Interfaces:**
- Consumes: `Picker.next`, `Pick`, `AppState`, `Card` (Task 7); `minuteOfDay`, `TimeWindow` (Task 1); `Config` (Task 4);
  fixtures `at`, `lib`, `firstIndex` (Task 7).
- Produces:
  - `data class PlannedReminder(val fireAt: Instant, val card: Card, val state: AppState)` (`kotlin.time.Instant`)
  - `object Plan` with
    `fun make(now: Instant, timeZone: TimeZone, config: Config, library: Library, state: AppState, limit: Int = 64,
    horizon: Duration = 48.hours, random: (Int) -> Int = { Random.nextInt(it) }): List<PlannedReminder>` and
    `fun commit(plan: List<PlannedReminder>, now: Instant, current: AppState): AppState`
  - test fixture `fun instant(day: Int, h: Int, m: Int): Instant` (UTC)

Same behaviour as the Swift `Plan` in Task 8, and the same test cases.

- [ ] **Step 1: Add the instant fixture**

Replace `kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/Fixtures.kt` with:

```kotlin
// Fixtures shared by the core tests, the same as apple/CoreTests/Harness.swift.
package com.wildduck.azkar.core

import kotlin.test.assertFailsWith
import kotlin.test.assertTrue
import kotlin.time.Instant
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant

/** A time on a day in September 2026 (the tests use UTC wherever a time zone is needed). */
fun at(day: Int, h: Int, m: Int): LocalDateTime = LocalDateTime(2026, 9, day, h, m)

/** The same time as an Instant, in UTC. */
fun instant(day: Int, h: Int, m: Int): Instant = at(day, h, m).toInstant(TimeZone.UTC)

fun z(text: String): Zikr = Zikr(text)

val lib = Library(
    sabah = listOf(z("s1"), z("s2"), z("s3")),
    masaa = listOf(z("m1"), z("m2")),
    general = listOf(z("g1"), z("g2"), z("g3")),
)

val firstIndex: (Int) -> Int = { 0 }

/** Picks cards one after another, keeping the state between picks like the Swift tests' `inout` state. */
class Picks(var state: AppState = AppState()) {
    fun pick(
        date: LocalDateTime,
        config: Config = Config(),
        library: Library = lib,
        random: (Int) -> Int = firstIndex,
    ): Card? {
        val result = Picker.next(date, config, library, state, random)
        state = result.state
        return result.card
    }
}

/** `block` must throw a ConfigError whose message mentions `mentioning`. */
fun expectError(name: String, mentioning: String, block: () -> Unit) {
    val error = assertFailsWith<ConfigError>(name) { block() }
    assertTrue(
        error.message.orEmpty().contains(mentioning),
        "$name: error '${error.message}' should mention '$mentioning'",
    )
}
```

- [ ] **Step 2: Write the failing Plan tests**

`kotlin/shared/src/commonTest/kotlin/com/wildduck/azkar/core/PlanTest.kt`:

```kotlin
package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.time.Instant
import kotlinx.datetime.TimeZone

/** The reminders an iPhone schedules ahead as notifications (apple/CoreTests/PlanTests.swift has the same cases). */
class PlanTest {
    private fun plan(
        now: Instant,
        config: Config = Config(),
        library: Library = lib,
        state: AppState = AppState(),
        limit: Int = 64,
    ): List<PlannedReminder> = Plan.make(now, TimeZone.UTC, config, library, state, limit, random = firstIndex)

    @Test
    fun spacing() {
        val p = plan(instant(14, 12, 0))
        assertEquals(instant(14, 12, 3), p.first().fireAt, "the first reminder is one interval after now")
        assertEquals(instant(14, 12, 6), p[1].fireAt, "reminders are one interval apart")
        assertEquals(64, p.size, "up to 64 reminders")
    }

    @Test
    fun limits() {
        assertEquals(64, plan(instant(14, 12, 0), Config(maxStack = 1)).size, "maxStack does not limit the plan")
        assertEquals(5, plan(instant(14, 12, 0), limit = 5).size, "stops at the limit")
        val hourly = plan(instant(14, 12, 0), Config(intervalMinutes = 60.0, quietHours = null))
        assertEquals(48, hourly.size, "stops at the horizon")
        assertEquals(instant(16, 12, 0), hourly.last().fireAt, "a reminder exactly at the horizon is included")
    }

    @Test
    fun quietHours() {
        val p = plan(instant(14, 23, 0), Config(intervalMinutes = 30.0))
        assertEquals(instant(15, 5, 0), p.first().fireAt, "quiet hours are skipped")
    }

    @Test
    fun stateThroughThePlan() {
        val p = plan(instant(14, 5, 57))
        assertEquals(
            listOf("s1", "s2", "s3", "g1"),
            p.take(4).map { it.card.zikr.text },
            "the morning list continues through the plan",
        )
        assertEquals(1, p[0].state.sabah, "each reminder carries the state after its card")
        assertEquals(3, p[2].state.sabah, "the state after the third card")
        val resumed = plan(instant(14, 6, 0), state = AppState(day = "2026-09-14", sabah = 2))
        assertEquals("s3", resumed.first().card.zikr.text, "the plan starts from the given state")

        val hourly = plan(instant(14, 9, 30), Config(intervalMinutes = 60.0, quietHours = null))
        assertEquals(
            "s1",
            hourly.firstOrNull { it.fireAt == instant(15, 5, 30) }?.card?.zikr?.text,
            "a new day restarts the morning list inside the plan",
        )
    }

    @Test
    fun emptyPlans() {
        assertEquals(0, plan(instant(14, 12, 0), state = AppState(paused = true)).size, "a paused state plans nothing")
        assertEquals(0, plan(instant(14, 12, 0), library = Library()).size, "nothing to show plans nothing")
        assertEquals(0, plan(instant(14, 12, 0), Config(intervalMinutes = 0.0)).size, "a zero interval plans nothing")
    }

    @Test
    fun commit() {
        val start = AppState(day = "2026-09-14")
        val p = plan(instant(14, 6, 0), state = start) // 06:03 s1, 06:06 s2, 06:09 s3, …
        assertEquals(
            start,
            Plan.commit(p, instant(14, 6, 2), start),
            "before any reminder fires, the state stays as it is",
        )
        assertEquals(
            p[1].state,
            Plan.commit(p, instant(14, 6, 7), start),
            "commit keeps the state after the last reminder that fired",
        )
        assertEquals(p[2].state, Plan.commit(p, instant(14, 6, 9), start), "a reminder firing exactly now counts as fired")
        assertEquals(
            p.last().state,
            Plan.commit(p, instant(20, 0, 0), start),
            "after the whole plan, the last reminder's state",
        )
        assertEquals(start, Plan.commit(emptyList(), instant(14, 6, 7), start), "an empty plan keeps the current state")
    }
}
```

- [ ] **Step 3: Run the tests to verify they fail**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest --tests 'com.wildduck.azkar.core.PlanTest'`
Expected: FAIL in `:shared:compileTestKotlinJvm` with `Unresolved reference 'Plan'` and `'PlannedReminder'`.

- [ ] **Step 4: Write Plan.kt**

`kotlin/shared/src/commonMain/kotlin/com/wildduck/azkar/core/Plan.kt`:

```kotlin
// The reminders ahead, for phones that can't run code every few minutes: iOS schedules them as notifications.
package com.wildduck.azkar.core

import kotlin.random.Random
import kotlin.time.Duration
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.minutes
import kotlin.time.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

/** One scheduled reminder, and the state after its card, which the app keeps once the reminder has fired. */
data class PlannedReminder(val fireAt: Instant, val card: Card, val state: AppState)

object Plan {
    /**
     * One reminder per interval after `now` (the first at `now + interval`), until `limit` reminders or `horizon`.
     * Ticks in quiet hours are skipped. Paused: none. `maxStack` doesn't apply, since nothing stacks up.
     */
    fun make(
        now: Instant,
        timeZone: TimeZone,
        config: Config,
        library: Library,
        state: AppState,
        limit: Int = 64,
        horizon: Duration = 48.hours,
        random: (Int) -> Int = { Random.nextInt(it) },
    ): List<PlannedReminder> {
        if (state.paused || config.intervalMinutes <= 0) return emptyList()
        val interval = config.intervalMinutes.minutes
        val plan = mutableListOf<PlannedReminder>()
        var st = state
        var step = 1
        while (plan.size < limit) {
            val offset = interval * step
            step += 1
            if (offset > horizon) break
            val fireAt = now + offset
            val local = fireAt.toLocalDateTime(timeZone)
            if (config.quietHours?.contains(minuteOfDay(local)) == true) continue
            val pick = Picker.next(local, config, library, st, random)
            st = pick.state
            val card = pick.card ?: continue
            plan += PlannedReminder(fireAt, card, st)
        }
        return plan
    }

    /** The state after the last reminder that has fired by `now`, or `current` if none has. */
    fun commit(plan: List<PlannedReminder>, now: Instant, current: AppState): AppState =
        plan.lastOrNull { it.fireAt <= now }?.state ?: current
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run (in `azkar/kotlin`): `./gradlew :shared:jvmTest :shared:compileKotlinIosSimulatorArm64`
Expected: `BUILD SUCCESSFUL`; all six `PlanTest` methods `PASSED`, earlier tests still pass.

- [ ] **Step 6: Update the README**

In `README.md`, directly above `## Install`, add:

````markdown
## Other platforms (in progress)

`kotlin/` is becoming a Kotlin Multiplatform version for Android, iOS, Windows and Linux, built in stages (see
`docs/superpowers/`). So far it has the core logic, ported from `apple/Core` and tested with the same cases:

```sh
cd kotlin && ./gradlew jvmTest   # Gradle runs on JDK 17+ and downloads the JDK 21 toolchain if it's missing
```

````

In the Layout block, after the line `    TapCounter          ×N repetitions on one card`, add:

```
    Plan                the reminders ahead, for iPhone notifications
```

and directly above the line `docs/superpowers/       design spec and implementation plans for the Swift + Kotlin Multiplatform apps`, add:

```
kotlin/                 Kotlin Multiplatform (Gradle)
  shared/               com.wildduck.azkar.core: apple/Core ported file by file (Hotkey without key codes)
    src/commonTest/     the same test cases as apple/CoreTests
    src/jvmTest/        ShippedFilesTest: the real .config/azkar files
```

After the paragraph that ends with `` `apple/build.sh format`. ``, add:

```markdown

Kotlin follows the official Kotlin style (4 spaces, 120 columns, see `kotlin/.editorconfig`).
```

- [ ] **Step 7: Commit**

```bash
cd /Users/wildduck/dotfiles
git add azkar/kotlin/shared/src azkar/README.md
git commit -m "feat(azkar): add Plan to the Kotlin core"
git show --name-only --format= HEAD | grep -v '^azkar/' || echo "only azkar/ files"
```

Expected: `only azkar/ files`.

- [ ] **Step 8: Check the whole stage from clean**

Run:

```bash
cd /Users/wildduck/dotfiles/azkar && apple/build.sh test
cd kotlin && ./gradlew clean :shared:jvmTest :shared:compileKotlinIosArm64 :shared:compileKotlinIosSimulatorArm64 --no-build-cache
grep -ho '<testsuite name="[^"]*" tests="[0-9]*" skipped="[0-9]*" failures="[0-9]*" errors="[0-9]*"' \
  shared/build/test-results/jvmTest/*.xml
```

Expected: Swift Core tests `… passed, 0 failed` and UI tests pass; Gradle `BUILD SUCCESSFUL`; ten test suites, all
with `failures="0" errors="0"`: ClockTest 3, HotkeyTest 6, ConfigTest 8, LibraryTest 2, ShippedFilesTest 2,
TickTest 1, TapCounterTest 1, StartupTest 1, PickerTest 8, PlanTest 6 (38 tests).

- [ ] **Step 9: Check that every Swift case name exists in Kotlin**

Run:

```bash
cd /Users/wildduck/dotfiles/azkar
# A Swift case name is the last string argument of eq/check, or the first of expectError; `\(x)` becomes `$x`.
perl -ne 'while (/(?:, |^\s*)"([^"]+)"\)/g) { print "$1\n" } while (/expectError\("([^"]+)"/g) { print "$1\n" }' \
  apple/CoreTests/*.swift | perl -pe 's/\\\((\w+)\)/\$$1/g' | sort -u |
  while IFS= read -r name; do
    grep -rqF -- "$name" kotlin/shared/src/commonTest kotlin/shared/src/jvmTest || echo "only in Swift: $name"
  done
```

Expected: only the Swift-only cases (Carbon key codes and the LaunchAgent plist):

```
only in Swift: a recorded key press becomes the same hotkey as its spec
only in Swift: a recorded key press needs a modifier
only in Swift: interactive process
only in Swift: key code for '$name'
only in Swift: launch agent label
only in Swift: login starts the app in the background
only in Swift: other modifier bits (caps lock) are ignored
only in Swift: restarted only if it crashes
only in Swift: runs at login
only in Swift: unknown key code
```

Any other line is a case missing from Kotlin: add it to the matching Kotlin test, run Step 8 again, and commit.

- [ ] **Step 10: Show the stage's commits**

Run: `cd /Users/wildduck/dotfiles && git log --oneline -9 && git status --short azkar`
Expected: the nine stage 2 commits on top of `f6ed43d`, and no uncommitted files under `azkar/`.
