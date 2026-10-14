#!/usr/bin/env bash
#
# ani-cli Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "ani-cli"
check_arch

# -- Packages --------------------------------------------------------------
# mpv: player
# fzf: episode and title picker
# aria2, yt-dlp, ffmpeg: downloads (-d)
pkg_install mpv fzf aria2 yt-dlp ffmpeg curl
aur_install ani-cli

# -- Stow ------------------------------------------------------------------
stow_package ani-cli
mkdir -p "$HOME/Videos/anime"

ok "ani-cli setup complete (open a new shell to load its settings)"
