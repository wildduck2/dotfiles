#!/usr/bin/env bash
#
# Yazi Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Yazi"
check_arch

# -- Packages --------------------------------------------------------------
# yazi: file manager
# ffmpeg, ffmpegthumbnailer: video thumbnails
# poppler: PDF previews
# imagemagick, resvg: image and SVG previews
# chafa: draws image and video previews as text in terminals without image support (Terminator)
# 7zip, ouch: archive previews, extraction and compression (C key)
# jq: JSON previews
# fd, ripgrep, fzf, zoxide: search and jump (s, S, Z, z keys)
# git: status markers next to files
pkg_install yazi ffmpeg ffmpegthumbnailer poppler imagemagick resvg 7zip ouch jq chafa \
  fd ripgrep fzf zoxide git file

# -- Stow ------------------------------------------------------------------
stow_package yazi

# -- Plugins and flavor (pinned in package.toml) ---------------------------
if command_exists ya; then
  info "Installing yazi plugins and flavor"
  ya pkg install && ok "Yazi plugins installed" \
    || warn "Plugin install had issues -- run: ya pkg install"
else
  warn "ya not found -- run 'ya pkg install' after installing yazi"
fi

ok "Yazi setup complete"
