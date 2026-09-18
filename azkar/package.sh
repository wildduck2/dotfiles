#!/usr/bin/env bash
# Package every Azkar app this machine can build, into dist/ (git-ignored, throw it away freely).
#
#   ./package.sh           every app this host can build
#   ./package.sh macos     the menu-bar app     .dmg               (macOS)
#   ./package.sh desktop   the desktop app      .dmg/.deb/.msi     (whichever the host makes)
#   ./package.sh android   the phone app        .apk               (needs an Android SDK)
#   ./package.sh ios       both iPhone apps     .ipa + .app.zip    (needs Xcode and XcodeGen)
#   ./package.sh clean     throw dist/ away
#
# No one machine makes the whole set: jpackage only builds an installer for the OS it runs on, and
# iOS needs Xcode. Run this on a Mac, on a PC and on a Linux box — or let the three CI jobs do it.
# Whatever this host can't make is listed at the end, with the reason.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
dist="$here/dist"
work="$dist/.work"  # derived data and staging; kept between runs, never packaged
version="1.0.0"

case "$(uname -s)" in
  Darwin) host=macos ;;
  Linux) host=linux ;;
  MINGW* | MSYS* | CYGWIN*) host=windows ;;
  *) host="$(uname -s)" ;;
esac

# "file|what it is" and "what|why not". Plain arrays: macOS still ships bash 3.2.
made=()
missing=()
record() { made+=("$1|$2"); }
skip() { missing+=("$1|$2"); }
have() { command -v "$1" >/dev/null 2>&1; }
gradle() { (cd "$here/kotlin" && ./gradlew --console=plain "$@"); }
newest() { ls -dt $1 2>/dev/null | head -1; }

# ---------------------------------------------------------------- the menu-bar app (Swift)

package_macos() {
  if [ "$host" != macos ]; then
    skip "macOS .dmg" "the menu-bar app is AppKit — it only builds on a Mac"
    return
  fi
  "$here/apple/build.sh" build
  local staging="$work/macos"
  rm -rf "$staging"
  mkdir -p "$staging"
  cp -R "$here/apple/.build/Azkar.app" "$staging/"
  # So the .dmg opens as the drag-to-install window everyone expects.
  ln -s /Applications "$staging/Applications"
  local out="$dist/azkar-$version-macos.dmg"
  rm -f "$out"
  hdiutil create -volname Azkar -srcfolder "$staging" -ov -quiet -format UDZO "$out"
  record "$out" "the menu-bar app — open it and drag Azkar to Applications"
}

# ---------------------------------------------------------------- the desktop app (Compose)

package_desktop() {
  local task ext
  case "$host" in
    macos) task=packageDmg ext=dmg ;;
    linux) task=packageDeb ext=deb ;;
    windows) task=packageMsi ext=msi ;;
    *)
      skip "desktop installer" "jpackage has no format for $host"
      return
      ;;
  esac
  local other
  for other in "macos .dmg:macos" "linux .deb:linux" "windows .msi:windows"; do
    [ "${other#*:}" = "$host" ] ||
      skip "desktop ${other%%:*}" "jpackage only builds for the OS it runs on — run this on ${other#*:}"
  done

  # A Mac has two Azkars — the menu-bar app is the macOS one, so this is the one that says so.
  local name="$host"
  [ "$host" = macos ] && name="macos-desktop"

  gradle :desktopApp:"$task" :desktopApp:createDistributable
  local binaries="$here/kotlin/desktopApp/build/compose/binaries/main"
  local src
  src="$(newest "$binaries/$ext/*.$ext")"
  [ -n "$src" ] || {
    echo "package.sh: $task produced no .$ext" >&2
    exit 1
  }
  local out="$dist/azkar-$version-$name.$ext"
  cp "$src" "$out"
  record "$out" "the desktop app, installed the way $host installs things"

  # The same app as a folder: no installer, no root, unzip and run bin/azkar.
  if have zip; then
    local appdir
    appdir="$(newest "$binaries/app/*")"
    if [ -n "$appdir" ]; then
      out="$dist/azkar-$version-$name-portable.zip"
      rm -f "$out"
      (cd "$(dirname "$appdir")" && zip -qry "$out" "$(basename "$appdir")")
      record "$out" "the desktop app with no installer — unzip it and run it"
    fi
  else
    skip "desktop portable .zip" "no zip command on this machine"
  fi
}

# ---------------------------------------------------------------- the phone app (Android)

android_sdk() {
  local candidate
  for candidate in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk" \
    /opt/homebrew/share/android-commandlinetools "$HOME/Android/Sdk" /usr/lib/android-sdk; do
    [ -n "$candidate" ] || continue
    if [ -d "$candidate/platform-tools" ] || [ -d "$candidate/cmdline-tools" ]; then
      echo "$candidate"
      return 0
    fi
  done
  # Whatever Android Studio wrote down, if anyone has opened the project in it.
  local props="$here/kotlin/local.properties"
  if [ -f "$props" ]; then
    candidate="$(sed -n 's/^sdk\.dir=//p' "$props" | head -1)"
    if [ -n "$candidate" ] && [ -d "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  fi
  return 1
}

package_android() {
  local sdk
  if ! sdk="$(android_sdk)"; then
    skip "Android .apk" "no Android SDK found — set ANDROID_HOME (see the Android section of the README)"
    return
  fi
  ANDROID_HOME="$sdk" gradle :androidApp:assembleDebug :androidApp:assembleRelease
  local apks="$here/kotlin/androidApp/build/outputs/apk"
  cp "$apks/debug/androidApp-debug.apk" "$dist/azkar-$version-android.apk"
  record "$dist/azkar-$version-android.apk" "the phone app, signed with the debug key — installs as it is"
  local unsigned
  unsigned="$(newest "$apks/release/*.apk")"
  if [ -n "$unsigned" ]; then
    cp "$unsigned" "$dist/azkar-$version-android-release-unsigned.apk"
    record "$dist/azkar-$version-android-release-unsigned.apk" "the same app, optimised — sign it with your own key first"
  fi
}

# ---------------------------------------------------------------- the two iPhone apps

# Unsigned: without a developer certificate Xcode can still build the app, and a phone still won't
# run it. Re-sign the .ipa (Xcode, or a sideloading tool) to put it on a phone; the simulator build
# needs nothing — `xcrun simctl install booted Azkar.app`.
ios_package() {
  local name="$1" dir="$2" project="$3" scheme="$4" label="$5"
  local unsign=(CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="")
  local derived="$work/$scheme"

  xcodebuild build -project "$dir/$project" -scheme "$scheme" -configuration Release \
    -sdk iphoneos -derivedDataPath "$derived-device" "${unsign[@]}" >"$work/$scheme-device.log"
  rm -rf "$derived-payload"
  mkdir -p "$derived-payload/Payload"
  cp -R "$derived-device/Build/Products/Release-iphoneos/$scheme.app" "$derived-payload/Payload/"
  rm -f "$dist/$name.ipa"
  (cd "$derived-payload" && zip -qry "$dist/$name.ipa" Payload)
  record "$dist/$name.ipa" "$label for a phone — unsigned, re-sign it to install"

  xcodebuild build -project "$dir/$project" -scheme "$scheme" -configuration Release \
    -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$derived-sim" "${unsign[@]}" >"$work/$scheme-sim.log"
  rm -f "$dist/$name-simulator.app.zip"
  (cd "$derived-sim/Build/Products/Release-iphonesimulator" && zip -qry "$dist/$name-simulator.app.zip" "$scheme.app")
  record "$dist/$name-simulator.app.zip" "$label for the simulator — xcrun simctl install booted"
}

package_ios() {
  if [ "$host" != macos ]; then
    skip "iPhone .ipa" "iOS builds only on a Mac"
    return
  fi
  # /usr/bin/xcodebuild exists even with only the command-line tools installed, and fails on use.
  if ! xcodebuild -version >/dev/null 2>&1; then
    skip "iPhone .ipa" "needs Xcode itself — this Mac has the command-line tools only (xcode-select -p)"
    return
  fi
  if ! have xcodegen; then
    skip "iPhone .ipa" "needs XcodeGen (brew install xcodegen) to make the two Xcode projects"
    return
  fi
  if ! have zip; then
    skip "iPhone .ipa" "no zip command on this machine"
    return
  fi
  mkdir -p "$work"
  "$here/apple/build.sh" ios
  ios_package "azkar-$version-ios" "$here/apple/iOS" Azkar.xcodeproj Azkar "the SwiftUI app"
  (cd "$here/kotlin/iosApp" && xcodegen generate)
  ios_package "azkar-$version-ios-compose" "$here/kotlin/iosApp" AzkarKMP.xcodeproj AzkarKMP "the Compose app"
}

# ---------------------------------------------------------------- what came out

checksum() {
  if have shasum; then shasum -a 256 "$1" | awk '{print $1}'; else sha256sum "$1" | awk '{print $1}'; fi
}

summary() {
  local entry file what
  if [ ${#made[@]} -gt 0 ]; then
    {
      echo "Azkar $version, packaged on $host, $(date -u '+%Y-%m-%d %H:%M UTC')"
      echo
      for entry in "${made[@]}"; do
        file="${entry%%|*}"
        printf '%s  %s\n' "$(checksum "$file")" "$(basename "$file")"
      done
    } >"$dist/manifest.txt"
  fi

  echo
  echo "dist/ — Azkar $version, packaged on $host"
  echo
  if [ ${#made[@]} -eq 0 ]; then
    echo "  nothing: this machine could build none of them"
  else
    for entry in "${made[@]}"; do
      file="${entry%%|*}"
      what="${entry#*|}"
      printf '  %-42s %6s  %s\n' "$(basename "$file")" "$(du -h "$file" | cut -f1 | tr -d ' ')" "$what"
    done
  fi
  if [ ${#missing[@]} -gt 0 ]; then
    echo
    echo "  not from this machine:"
    for entry in "${missing[@]}"; do
      printf '    %-24s %s\n' "${entry%%|*}" "${entry#*|}"
    done
  fi
  echo
}

case "${1:-all}" in
  all)
    mkdir -p "$dist" "$work"
    package_macos
    package_desktop
    package_android
    package_ios
    summary
    ;;
  macos | desktop | android | ios)
    mkdir -p "$dist" "$work"
    "package_$1"
    summary
    ;;
  clean)
    rm -rf "$dist"
    echo "dist/ removed."
    ;;
  *)
    sed -n '2,13p' "$0"
    exit 1
    ;;
esac
