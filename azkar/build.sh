#!/usr/bin/env bash
# Build, test, install and (re)start the Azkar menu-bar app.
#   ./build.sh            test, build, install to ~/Applications, start now and at login
#   ./build.sh test       run the tests only
#   ./build.sh build      test + build into .build/ without installing
#   ./build.sh uninstall  stop it and remove the app and its LaunchAgent
#   ./build.sh format     format all Swift files (swift format, settings in .swift-format)
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
build="$here/.build"
app="$HOME/Applications/Azkar.app"
label="com.wildduck.azkar"
agent="$HOME/Library/LaunchAgents/$label.plist"
swiftc=(swiftc -swift-version 5)
core=("$here"/src/Core/*.swift)
# Everything except main.swift, so the UI tests can link it.
lib=("${core[@]}" "$here"/src/App/*.swift "$here"/src/Window/*.swift)

run_tests() {
  mkdir -p "$build"
  "${swiftc[@]}" "${core[@]}" "$here"/tests/core/*.swift -o "$build/tests"
  "$build/tests"
  # UI tests briefly show cards in the top-right corner.
  "${swiftc[@]}" -framework AppKit -framework Carbon "${lib[@]}" "$here"/tests/ui/*.swift -o "$build/ui-tests"
  "$build/ui-tests"
}

make_icon() {
  local icns="$build/AppIcon.icns"
  if [ "$icns" -nt "$here/tools/icon.swift" ]; then return; fi
  "${swiftc[@]}" -framework AppKit "$here/tools/icon.swift" -o "$build/icon"
  "$build/icon" "$build/AppIcon.iconset"
  iconutil -c icns "$build/AppIcon.iconset" -o "$icns"
}

build_app() {
  local out="$build/Azkar.app"
  make_icon
  rm -rf "$out"
  mkdir -p "$out/Contents/MacOS" "$out/Contents/Resources"
  cp "$build/AppIcon.icns" "$out/Contents/Resources/"
  "${swiftc[@]}" -O -framework AppKit -framework Carbon "${lib[@]}" "$here/src/main.swift" -o "$out/Contents/MacOS/Azkar"
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
  [ -e "$HOME/.config/azkar" ] || stow -d "$here/.." -t "$HOME" azkar
}

case "${1:-install}" in
  test) run_tests ;;
  build) run_tests && build_app ;;
  format) swift format -i -r "$here/src" "$here/tests" "$here/tools" ;;
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
    sed -n '2,7p' "$0"
    exit 1
    ;;
esac
