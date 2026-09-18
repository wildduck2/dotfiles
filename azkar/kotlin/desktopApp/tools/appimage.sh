#!/usr/bin/env bash
# Wraps the folder jpackage builds into an AppImage: one file that runs on any Linux desktop, with
# no installer, no root and no package manager. A .deb only suits Debian and Ubuntu, and the
# portable .zip asks people to find bin/azkar themselves — this is the thing you download, chmod +x
# and double-click, on Arch, Fedora, openSUSE or anything else.
#
#   appimage.sh <the folder jpackage built> <the .AppImage to write> <x64|arm64>
#
# Needs curl (to fetch appimagetool) and the JDK that built the app (to draw the icon).
set -euo pipefail

app="${1:?the folder jpackage built}"
out="${2:?the .AppImage to write}"
arch="${3:?x64 or arm64}"
here="$(cd "$(dirname "$0")" && pwd)"

# appimagetool names its releases after uname -m, and refuses to guess when it can't tell.
case "$arch" in
  arm64 | aarch64) machine=aarch64 ;;
  x64 | x86_64 | amd64) machine=x86_64 ;;
  *)
    echo "appimage.sh: appimagetool has no build for $arch" >&2
    exit 1
    ;;
esac

# Pinned: this is a download from the internet in the middle of a build, and a release that changes
# under us is a build that breaks for no reason anyone can see.
tool_version=1.9.1
tool_url="https://github.com/AppImage/appimagetool/releases/download/$tool_version/appimagetool-$machine.AppImage"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
dir="$work/AppDir"

mkdir -p "$dir/usr" "$dir/usr/share/applications" "$dir/usr/share/icons/hicolor/256x256/apps"
cp -a "$app" "$dir/usr/azkar"

# The program inside is not called what the package is called: jpackage builds Azkar/bin/Azkar while
# the .deb installs "azkar". Read the name off the build rather than assume it — an AppRun pointing
# at a name that is not there is a 70MB file that starts nothing, and says so only when someone runs
# it on a machine you haven't got.
launcher="$(ls "$dir/usr/azkar/bin")"
if [ "$(printf '%s\n' "$launcher" | wc -l)" -ne 1 ] || [ ! -x "$dir/usr/azkar/bin/$launcher" ]; then
  echo "appimage.sh: expected one program in $app/bin, found:" >&2
  printf '  %s\n' "$launcher" >&2
  exit 1
fi

# AppRun is what the AppImage starts. $0 is a path inside the image once it is mounted, so the app
# has to be found relative to it and not relative to wherever the file was downloaded to.
cat >"$dir/AppRun" <<RUN
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\$0")")"
exec "\$HERE/usr/azkar/bin/$launcher" "\$@"
RUN
chmod +x "$dir/AppRun"

# The .desktop file and the icon have to sit at the top of the AppDir — that is where appimagetool
# looks — and the copies under usr/share are what a desktop reads after the file is integrated.
cat >"$dir/azkar.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Azkar
Comment=A zikr card every few minutes
Exec=azkar
Icon=azkar
Categories=Utility;
Terminal=false
DESKTOP
cp "$dir/azkar.desktop" "$dir/usr/share/applications/azkar.desktop"

java "$here/Icon.java" "$dir/azkar.png" 256
cp "$dir/azkar.png" "$dir/usr/share/icons/hicolor/256x256/apps/azkar.png"

curl -fsSL -o "$work/appimagetool" "$tool_url"
chmod +x "$work/appimagetool"

rm -f "$out"
# appimagetool is itself an AppImage, so it wants FUSE to mount itself — which a container and most
# CI runners do not have. Unpacking itself instead costs a second and works everywhere.
if ! ARCH="$machine" APPIMAGE_EXTRACT_AND_RUN=1 "$work/appimagetool" "$dir" "$out" >"$work/log" 2>&1; then
  echo "appimagetool failed. The last 30 lines:" >&2
  tail -30 "$work/log" >&2
  exit 1
fi
