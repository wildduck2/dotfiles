#!/usr/bin/env bash
#
# Duck-Bash Utility Scripts Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Duck-Bash Scripts"
check_arch

# -- Core tools (used across multiple scripts) -----------------------------
pkg_install git curl jq fzf tmux

# -- Image tools (qr-with-image.sh) ----------------------------------------
pkg_install qrencode imagemagick

# -- Pacman cache cleanup (sys-package-manager-clean.sh, system-clean.sh) --
pkg_install pacman-contrib

# -- Media download (yt-download.sh) ---------------------------------------
pkg_install yt-dlp

# -- Desktop notifications (screenshot.sh) ---------------------------------
pkg_install libnotify

# -- Make all scripts executable -------------------------------------------
info "Setting scripts to executable"
local_count=0
while IFS= read -r -d '' script; do
  chmod +x "$script"
  step "$(basename "$script")"
  local_count=$((local_count + 1))
done < <(find "$SCRIPT_DIR/.config/duck-bash/" -name "*.sh" -print0)
ok "$local_count scripts set to executable"

# -- Optional tools (not required but used by some scripts) ----------------
if ! command_exists docker; then
  warn "docker not installed -- docker-clean.sh will not work"
  warn "Install with: sudo pacman -S docker"
fi

# -- Stow ------------------------------------------------------------------
stow_package duck-bash

# -- Verify ----------------------------------------------------------------
header "Duck-bash Verification"
CHECKS=0 TOTAL=0
check_duck_cmd() {
  TOTAL=$((TOTAL + 1))
  if command_exists "$1"; then
    ok "$1"
    CHECKS=$((CHECKS + 1))
  else
    warn "$1 -- NOT FOUND"
  fi
}

check_duck_cmd fzf
check_duck_cmd tmux
check_duck_cmd jq
check_duck_cmd git
check_duck_cmd curl
check_duck_cmd qrencode
check_duck_cmd magick
check_duck_cmd yt-dlp
check_duck_cmd flameshot
check_duck_cmd paccache

ok "Duck-bash setup complete ($CHECKS/$TOTAL checks passed)"
