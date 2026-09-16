# Azkar stage 4: the Android app Implementation Plan

> **For agentic workers:** this plan is executed inline in one session (the user asked for every stage to be built
> without stopping). Each task ends with a test run and a commit; commits stay local.

**Goal:** `kotlin/androidApp` is Azkar on a phone: the same five-page window from `shared/ui`, and reminders as
notifications with a **Count** button instead of cards on screen.

**Architecture:** `shared` gains an Android target (`com.android.kotlin.multiplatform.library`) so the core, the app
layer and the Compose UI all come from the same source. `androidApp` is a thin shell: one activity, an
`AlarmManager` alarm at a time, a `BroadcastReceiver` that runs the same `decideTick` → `Picker` tick the desktop
runs, and notifications built by pure functions that JVM unit tests can check.

**Tech Stack:** AGP 9.4.0 (classic `com.android.library` / `com.android.application`), minSdk 26, compileSdk 37, `androidx.activity:activity-compose`, `androidx.core:core-ktx`
(NotificationCompat), Compose Multiplatform 1.12.0 from `shared`.

**Spec:** `../specs/2026-09-15-azkar-kotlin-multiplatform-design.md` (section 3 "Android", section 5).

## Global Constraints

- Stage only `azkar/` paths by name when committing; the repo has unrelated uncommitted changes.
- The JSON formats stay byte-compatible: `config.json` and `state.json` in the app's files directory,
  `azkar.json` from assets on first run.
- Pure logic (notification text, badge, channel choice, when the next alarm is due) is tested with JVM unit tests;
  anything that needs a real phone is checked in CI (`assembleDebug`) or by hand.
- `local.properties` is never committed; the SDK comes from `ANDROID_HOME`.
- The desktop and iOS targets keep building: `:desktopApp:test` and the iOS compile tasks stay green.

## Deviations from the spec (decided while building)

- **Not `com.android.kotlin.multiplatform.library`:** the Compose resources plugin at 1.12.0 doesn't know that
  target, so no `assembleAndroidMainResources` task exists and the Arabic font never reaches the APK. `shared`
  uses `com.android.library` + `androidTarget()` instead, with `android.builtInKotlin=false` and
  `android.newDsl=false` (AGP 9's own documented bypass) in `gradle.properties`. Both flags go away once Compose
  supports the new plugin. Checked by unzipping the APK: `assets/composeResources/.../noto_naskh_arabic_*.ttf`.

## File Map

```
kotlin/gradle/libs.versions.toml      agp, androidx activity/core versions and the two Android plugins
kotlin/settings.gradle.kts            include(":androidApp")
kotlin/shared/build.gradle.kts        androidTarget() + android { }: namespace, minSdk, compileSdk
kotlin/androidApp/build.gradle.kts    com.android.application, Compose, minSdk 26, applicationId com.wildduck.azkar
kotlin/androidApp/src/main/AndroidManifest.xml
kotlin/androidApp/src/main/assets/azkar.json          copied from .config/azkar/azkar.json at build time
kotlin/androidApp/src/main/kotlin/com/wildduck/azkar/android/
  AndroidStorage.kt    Storage on filesDir + the asset, and the notification channels' ids
  Notifications.kt     pure: header, big text, badge, progress, channel choice, which action a card gets
  Reminders.kt         pure: when the next alarm is due; and the AlarmManager wrapper around it
  Tick.kt              the shared tick: decideTick -> Picker -> notification -> next alarm
  AzkarApp.kt          Application: channels, the controller, the storage
  MainActivity.kt      AzkarWindow, the full-screen card, the permission flow
  AlarmReceiver.kt     the alarm, BOOT_COMPLETED and the Count action
kotlin/androidApp/src/test/kotlin/...  unit tests for Notifications, Reminders and Tick
```

---

### Task 1: the Android target and an app that builds

- [ ] `libs.versions.toml`: `agp = "9.4.0"`, `androidx-activity`, `androidx-core`; plugins `androidApplication` and
      `androidKmpLibrary`.
- [ ] `shared`: add `androidTarget()` and the `android { }` block (namespace `com.wildduck.azkar.shared`,
      minSdk 26, compileSdk 37).
- [ ] `androidApp`: `com.android.application` + Compose, `applicationId com.wildduck.azkar`, minSdk 26, a manifest
      with the single activity, and `processResources`-style copy of the shipped `azkar.json` into `assets`.
- [ ] Verify: `./gradlew :shared:assemble :androidApp:assembleDebug` with `ANDROID_HOME` set, and
      `:desktopApp:test` still green.
- [ ] Commit: "build(azkar): add the Android target and app module".

### Task 2: the phone's logic, tested

- [ ] `Notifications`: `header(card)` (`أذكار الصباح · 7 من 25`), `body(zikr)`, `badge(counter)`, `channel(sound)`,
      `hasCount(card)`; the ids and channel names.
- [ ] `Reminders`: `nextAlarm(now, config, state)` → the instant of the next reminder, and whether an exact alarm
      is needed; quiet hours are skipped by the tick, not by the alarm.
- [ ] `Tick`: `tick(controller, active, now, exact)` → `decideTick(paused, locked = false, quiet, active, maxStack)`
      → `Picker` → what to post, and when the next alarm is due.
- [ ] Verify: `./gradlew :androidApp:testDebugUnitTest` — red first, then green.
- [ ] Commit: "feat(azkar): the Android reminder logic, tested".

### Task 3: the app itself

- [ ] `AzkarApp`: the controller on `AndroidStorage`, both notification channels, `Features.android`.
- [ ] `MainActivity`: `AzkarWindow` from `shared/ui`, the card shown full-screen when a notification is tapped,
      `POST_NOTIFICATIONS` at first launch and `SCHEDULE_EXACT_ALARM` from the Schedule page.
- [ ] `AlarmReceiver`: the alarm tick, `BOOT_COMPLETED` re-arm, and the Count action updating the same notification.
- [ ] Verify: `./gradlew :androidApp:assembleDebug :androidApp:testDebugUnitTest`.
- [ ] Commit: "feat(azkar): the Android app".

### Task 4: CI, README, stage check

- [ ] The workflow's Linux job also runs `:androidApp:testDebugUnitTest :androidApp:assembleDebug` and uploads the
      APK.
- [ ] README: an Android section (what it does, how to build, where the files are, the permissions) and the phone
      part of the manual checklist.
- [ ] Verify: `./gradlew clean jvmTest :desktopApp:test :androidApp:testDebugUnitTest :androidApp:assembleDebug
      compileKotlinIosArm64 compileKotlinIosSimulatorArm64`, `git status --short .`.
- [ ] Commit: "docs(azkar): document the Android app and build it in CI".
