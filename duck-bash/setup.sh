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
find "$SCRIPT_DIR/.config/duck-bash/" -name "*.sh" -exec chmod +x {} \;
ok "All scripts set to executable"

# -- Stow ------------------------------------------------------------------
stow_package duck-bash

ok "Duck-bash setup complete"
