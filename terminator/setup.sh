#!/usr/bin/env bash
#
# Terminator Terminal Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Terminator"
check_arch

# -- Packages --------------------------------------------------------------
# terminator: GTK terminal emulator
# ttf-jetbrains-mono-nerd: fallback font (New Profile uses it)
pkg_install terminator ttf-jetbrains-mono-nerd

# -- Font check ------------------------------------------------------------
check_preferred_font

# -- Stow ------------------------------------------------------------------
stow_package terminator

ok "Terminator setup complete"
