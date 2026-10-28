#!/usr/bin/env bash
#
# Audio Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Audio"
check_arch

# -- Packages --------------------------------------------------------------
# pipewire, wireplumber: audio server and session manager
# bluez, bluez-utils: Bluetooth stack and bluetoothctl
pkg_install pipewire pipewire-pulse wireplumber bluez bluez-utils pavucontrol

# -- Stow ------------------------------------------------------------------
stow_package audio

if command_exists systemctl; then
  sudo systemctl enable --now bluetooth.service || warn "Could not enable bluetooth.service"
  systemctl --user restart wireplumber 2>/dev/null || true
fi

# The G614FR's built-in mic needs its driver taught the model.
if grep -q G614FR /sys/class/dmi/id/product_name 2>/dev/null; then
  bash "$SCRIPT_DIR/internal-mic.sh"
fi

ok "Audio setup complete"
