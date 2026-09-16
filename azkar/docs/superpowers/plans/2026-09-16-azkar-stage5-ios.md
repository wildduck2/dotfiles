# Azkar stage 5: the two iPhone apps Implementation Plan

> **For agentic workers:** this plan is executed inline in one session (the user asked for every stage to be built
> without stopping). Each task ends with a test run and a commit; commits stay local.

**Goal:** Azkar on an iPhone, twice: `apple/iOS` (SwiftUI, on `apple/Core`) and `kotlin/iosApp` (the shared Compose
UI, on `kotlin/shared`). Both schedule up to 64 local notifications from `Plan`, because iOS won't run code every
few minutes.

**Architecture:** neither app has a loop. On every launch, on activation, after a settings change, after "Show a
zikr now" and on a granted `BGAppRefreshTask` the app does the same three things: `Plan.commit` the reminders that
have already fired, make a fresh plan, and hand it to `UNUserNotificationCenter`. The plan is kept in `plan.json`
next to `config.json` and `state.json`, in one format both apps read. Tapping a notification opens that zikr as a
full-screen card; counting happens there, since iOS can't put a button on a delivered notification.

**Tech Stack:** iOS 18, SwiftUI + Observation for `apple/iOS`; Compose Multiplatform 1.12.0 through a static
`Shared.framework` for `kotlin/iosApp`; XcodeGen for both Xcode projects; `UNUserNotificationCenter` and
`BGTaskScheduler` on both sides.

**Spec:** `../specs/2026-09-15-azkar-kotlin-multiplatform-design.md` (section 3 "iOS", sections 1 and 5).

## Global Constraints

- Stage only `azkar/` paths (and `.github/workflows/azkar.yml`) by name when committing; the repo has unrelated
  uncommitted changes. Commits stay local.
- **There is no Xcode on this machine.** What can be verified here is verified here: the Swift core additions
  through `apple/build.sh test`, every new Kotlin iOS file through `compileKotlinIosArm64` and
  `compileKotlinIosSimulatorArm64`, every new Swift app file through `swiftc -parse` and `swift format --lint`, and
  both `project.yml` files by generating the Xcode projects with XcodeGen. Building and running the apps happens in
  CI (`macos-latest`, simulator, no signing) and by hand on a phone.
- `plan.json` has one format, implemented and tested on both sides, like every other file.
- Bundle ids: `apple/iOS` → `com.wildduck.azkar`, `kotlin/iosApp` → `com.wildduck.azkar.kmp`, so both can be
  installed side by side.
- The user's email address never appears in a shipped file.
- Generated Xcode projects are build output: `*.xcodeproj` stays in `.gitignore`.
- The other four platforms keep building and passing.

## File Map

```
apple/Core/CardText.swift            the card's words: the Arabic heading, the body, the notification's tail line
apple/Core/PlanFile.swift            plan.json: encode/decode the reminders ahead
apple/CoreTests/CardTextTests.swift
apple/CoreTests/PlanFileTests.swift
apple/iOS/project.yml                XcodeGen: com.wildduck.azkar, iOS 18, Core + App + azkar.json as a resource
apple/iOS/App/AzkarApp.swift         @main, the notification delegate, the background refresh task
apple/iOS/App/Model.swift            the app without a screen: files, plan, progress, problems, actions
apple/iOS/App/Files.swift            config.json, state.json, plan.json in Application Support; bundled azkar.json
apple/iOS/App/Reminders.swift        UNUserNotificationCenter: permission, scheduling a plan, what is pending
apple/iOS/App/Pages.swift            Today, Schedule, Cards, Azkar, General
apple/iOS/App/Components.swift       the rows, tiles and clock fields those pages are built from
apple/iOS/App/CardSheet.swift        the full-screen card: tap to count, ×, progress
kotlin/shared/build.gradle.kts       the static Shared.framework for both iOS targets
kotlin/shared/src/commonMain/.../app/PlanFile.kt      the same plan.json, in Kotlin
kotlin/shared/src/commonTest/.../app/PlanFileTest.kt
kotlin/shared/src/iosMain/.../ios/IosApp.kt           the controller, the plan and the notifications, once
kotlin/shared/src/iosMain/.../ios/IosStorage.kt       the three files in Application Support
kotlin/shared/src/iosMain/.../ios/Reminders.kt        UNUserNotificationCenter from Kotlin/Native
kotlin/shared/src/iosMain/.../ios/Entry.kt            MainViewController() for the Swift shell
kotlin/iosApp/project.yml             XcodeGen: com.wildduck.azkar.kmp, the gradle build phase, Shared.framework
kotlin/iosApp/iosApp/App.swift        the shell: one UIViewControllerRepresentable around MainViewController()
.github/workflows/azkar.yml           the macOS job builds both iOS apps for the simulator
azkar/README.md                       an iOS section, and `apple/build.sh ios`
```

## Task 1: plan.json and the card's words, in both cores

- [ ] Swift: `Core/CardText.swift` — `cardHeader(_:separator:)`, `cardBody(_:)` and
      `notificationBody(_:last:)` (the last reminder's body ends "Open Azkar to keep reminders coming"), with
      `Session.title` moved out of the AppKit card window. Kotlin already has the first two in `app/CardText.kt`;
      add the third there.
- [ ] Both: `PlanFile` — `{ "reminders": [ { "at": ISO-8601, "session", "position", "total", "zikr", "state" } ] }`,
      decoding a broken or missing file as an empty plan.
- [ ] Tests on both sides with the same cases: a plan survives the round trip, a broken file is an empty plan, the
      last body carries the tail line, and the heading reads "أذكار الصباح · 7 من 25".
- [ ] Verify: `apple/build.sh test`, `./gradlew jvmTest`.
- [ ] Commit: "feat(azkar): plan.json and the card's words in both cores".

## Task 2: `apple/iOS`, the SwiftUI app

- [ ] `project.yml`, then the app: `Files`, `Reminders`, `Model`, the five pages, the card, `@main`.
- [ ] Re-plan on activate, on a settings change, after "Show a zikr now", and from `BGAppRefreshTask`.
- [ ] A "Needs attention" row when notifications are refused, with a button to the app's Settings page.
- [ ] Verify: `swiftc -parse` on every new file, `swift format --lint`, `xcodegen generate` in `apple/iOS`,
      `apple/build.sh test` (the core additions).
- [ ] Commit: "feat(azkar): the SwiftUI iPhone app".

## Task 3: `kotlin/iosApp`, the Compose app

- [ ] `shared`: the static framework for `iosArm64` and `iosSimulatorArm64`, and the `iosMain` source set:
      `IosStorage`, `Reminders`, `IosApp`, `Entry`.
- [ ] `iosApp`: `project.yml` with the `embedAndSignAppleFrameworkForXcode` build phase, and the Swift shell.
- [ ] Verify: `./gradlew compileKotlinIosArm64 compileKotlinIosSimulatorArm64`, `swiftc -parse`,
      `xcodegen generate` in `kotlin/iosApp`.
- [ ] Commit: "feat(azkar): the Compose iOS app".

## Task 4: CI, the README, and the stage check

- [ ] The macOS job: install XcodeGen, generate both projects and build them for the simulator without signing.
- [ ] README: an iOS section (what a reminder is, the 64-notification limit, where the files are, what to check on
      a phone) and the `apple/build.sh ios` command.
- [ ] Verify: `apple/build.sh test`; `./gradlew clean jvmTest :desktopApp:test :androidApp:testDebugUnitTest
      :androidApp:assembleDebug compileKotlinIosArm64 compileKotlinIosSimulatorArm64`; `git status --short .`.
- [ ] Commit: "docs(azkar): document the iOS apps and build them in CI".
