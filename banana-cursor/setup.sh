#!/usr/bin/env bash
#
# Banana Cursor Setup (Banana-Blue for Tokyo Night)
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Banana Cursor"
check_arch

CURSOR_THEME="Banana-Blue"
CURSOR_SIZE=24
ICONS_DIR="$HOME/.icons"
RELEASE_URL="https://github.com/ful1e5/banana-cursor/releases/download/v2.0.0/Banana-Blue.tar.xz"

# -- Download & Install cursor theme --------------------------------------
if [[ -d "$ICONS_DIR/$CURSOR_THEME" ]]; then
  ok "$CURSOR_THEME already installed in $ICONS_DIR"
else
  duck_wait "Downloading $CURSOR_THEME cursor theme" "~5-10s"
  TMP_DIR=$(mktemp -d)
  curl -fsSL "$RELEASE_URL" -o "$TMP_DIR/Banana-Blue.tar.xz" \
    && ok "Downloaded $CURSOR_THEME" \
    || { warn "Download failed"; rm -rf "$TMP_DIR"; exit 1; }

  mkdir -p "$ICONS_DIR"
  tar -xf "$TMP_DIR/Banana-Blue.tar.xz" -C "$ICONS_DIR" \
    && ok "Extracted to $ICONS_DIR/$CURSOR_THEME" \
    || { warn "Extraction failed"; rm -rf "$TMP_DIR"; exit 1; }

  rm -rf "$TMP_DIR"
fi

# -- Stow (GTK3 settings, Xresources, default cursor symlink) -------------
stow_package banana-cursor

# -- Set cursor for X11 ---------------------------------------------------
if command_exists xrdb; then
  xrdb -merge "$HOME/.Xresources" 2>/dev/null && ok "Xresources merged" || true
fi

# -- Set cursor for GTK (running session) ----------------------------------
if command_exists gsettings; then
  gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null || true
fi

# -- Set default cursor symlink --------------------------------------------
if [[ -d "$ICONS_DIR/$CURSOR_THEME" ]]; then
  mkdir -p "$ICONS_DIR/default"
  ln -sfn "$ICONS_DIR/$CURSOR_THEME/cursors" "$ICONS_DIR/default/cursors"
  ok "Set $CURSOR_THEME as default cursor"
fi

# -- Export cursor env vars (current session) -------------------------------
export XCURSOR_THEME="$CURSOR_THEME"
export XCURSOR_SIZE="$CURSOR_SIZE"

ok "Banana Cursor setup complete ($CURSOR_THEME, size $CURSOR_SIZE)"
