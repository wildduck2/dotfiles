#!/usr/bin/env bash
# The root half of the laptop's special keys: the tools keys.sh calls, and the remap that lets X see mic mute
# and the touchpad toggle.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Laptop keys"
pkg_install dunst libnotify jq playerctl xorg-xinput
sudo install -Dm644 "$SCRIPT_DIR/hwdb/90-asus-keys.hwdb" /etc/udev/hwdb.d/90-asus-keys.hwdb
sudo systemd-hwdb update
sudo udevadm trigger --subsystem-match=input --action=change
ok "Mic mute and the touchpad toggle now reach i3"
