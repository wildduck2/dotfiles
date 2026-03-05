#!/usr/bin/env bash
#
# Kitty Terminal Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Kitty"
check_arch

# -- Packages --------------------------------------------------------------
pkg_install kitty ttf-jetbrains-mono-nerd

# -- Verify font -----------------------------------------------------------
check_font "JetBrainsMono Nerd Font.*Bold Italic" \
  || warn "Try running: fc-cache -fv"

# -- Stow ------------------------------------------------------------------
stow_package kitty

ok "Kitty setup complete"
