#!/usr/bin/env bash
# Build, test, install and (re)start the Azkar menu-bar app.
#   ./build.sh            test, build, install to ~/Applications, start now and at login
#   ./build.sh test       run the tests only
#   ./build.sh build      test + build into .build/ without installing
#   ./build.sh ios        check the iPhone app and draw its icon (Xcode does the rest, in CI)
#   ./build.sh uninstall  stop it and remove the app and its LaunchAgent
#   ./build.sh format     format all Swift files (swift format, settings in .swift-format)
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
build="$here/.build"
app="$HOME/Applications/Azkar.app"
label="com.wildduck.azkar"
agent="$HOME/Library/LaunchAgents/$label.plist"
swiftc=(swiftc -swift-version 5)
core=("$here"/Core/*.swift)
# Everything except main.swift, so the UI tests can link it.
lib=("${core[@]}" "$here"/macOS/App/*.swift "$here"/macOS/Window/*.swift)

run_tests() {
  mkdir -p "$build"
  "${swiftc[@]}" "${core[@]}" "$here"/CoreTests/*.swift -o "$build/tests"
  "$build/tests"
  # UI tests briefly show cards in the top-right corner.
  "${swiftc[@]}" -framework AppKit -framework Carbon "${lib[@]}" "$here"/macOS/UITests/*.swift -o "$build/ui-tests"
  "$build/ui-tests"
}

# Without Xcode there is no iOS SDK, so the iPhone app is checked as far as the command-line
# tools go: every file has to parse, and the half that never touches UIKit has to type-check
# against the Mac SDK. CI builds the app itself, for the simulator.
check_ios() {
  mkdir -p "$build"
  "${swiftc[@]}" -parse "$here"/iOS/App/*.swift
  "${swiftc[@]}" -typecheck "${core[@]}" "$here"/iOS/App/{Files,Reminders,Model}.swift
  ios_icon
  if command -v xcodegen >/dev/null; then
    (cd "$here/iOS" && xcodegen generate)
  else
    echo "iOS app checked. Install XcodeGen (brew install xcodegen) to generate iOS/Azkar.xcodeproj."
  fi
}

# The one 1024 px icon an iPhone app needs, in an asset catalog under .build/ — generated, like
# the Xcode project, so neither is checked in.
ios_icon() {
  local assets="$build/iOS/Assets.xcassets"
  local set="$assets/AppIcon.appiconset"
  mkdir -p "$set"
  "${swiftc[@]}" -framework AppKit "$here/macOS/tools/icon.swift" -o "$build/icon"
  "$build/icon" --ios "$set/icon-1024.png"
  echo '{ "info": { "author": "xcode", "version": 1 } }' >"$assets/Contents.json"
  cat >"$set/Contents.json" <<'EOF'
{
  "images": [
    { "filename": "icon-1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
EOF
}

make_icon() {
  local icns="$build/AppIcon.icns"
  if [ "$icns" -nt "$here/macOS/tools/icon.swift" ]; then return; fi
  "${swiftc[@]}" -framework AppKit "$here/macOS/tools/icon.swift" -o "$build/icon"
  "$build/icon" "$build/AppIcon.iconset"
  iconutil -c icns "$build/AppIcon.iconset" -o "$icns"
}

build_app() {
  local out="$build/Azkar.app"
  make_icon
  rm -rf "$out"
  mkdir -p "$out/Contents/MacOS" "$out/Contents/Resources"
  cp "$build/AppIcon.icns" "$out/Contents/Resources/"
  "${swiftc[@]}" -O -framework AppKit -framework Carbon "${lib[@]}" "$here/macOS/main.swift" -o "$out/Contents/MacOS/Azkar"
  cat >"$out/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key><string>$label</string>
  <key>CFBundleName</key><string>Azkar</string>
  <key>CFBundleExecutable</key><string>Azkar</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>15.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
EOF
  codesign --force --sign - "$out" >/dev/null
}

stop_agent() {
  launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
}

install_agent() {
  mkdir -p "$(dirname "$agent")"
  cat >"$agent" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key><array><string>$app/Contents/MacOS/Azkar</string><string>--background</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
  <key>ProcessType</key><string>Interactive</string>
</dict>
</plist>
EOF
  launchctl bootstrap "gui/$(id -u)" "$agent"
}

link_config() {
  # ~/.config/azkar -> dotfiles/azkar/.config/azkar
  [ -e "$HOME/.config/azkar" ] || stow -d "$here/../.." -t "$HOME" azkar
}

case "${1:-install}" in
  test) run_tests ;;
  build) run_tests && build_app ;;
  ios) check_ios ;;
  format) swift format -i -r "$here/Core" "$here/CoreTests" "$here/macOS" "$here/iOS" ;;
  install)
    run_tests
    build_app
    stop_agent
    mkdir -p "$(dirname "$app")"
    rm -rf "$app"
    cp -R "$build/Azkar.app" "$app"
    link_config
    install_agent
    echo "Azkar installed to $app and running (menu bar 📿)."
    ;;
  uninstall)
    stop_agent
    rm -f "$agent"
    rm -rf "$app"
    echo "Azkar removed. Config left in ~/.config/azkar."
    ;;
  *)
    sed -n '2,8p' "$0"
    exit 1
    ;;
esac
