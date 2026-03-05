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
# Default profile uses Berkeley Mono Trial Bold 14 (proprietary/trial font).
# Must be manually installed to ~/.local/share/fonts/
if check_font "Berkeley Mono"; then
  ok "Berkeley Mono Trial available (default profile font)"
else
  warn "Berkeley Mono Trial not found"
  warn "Default profile uses 'Berkeley Mono Trial Bold 14'"
  warn "Download from https://berkeleymono.com/ and place .ttf files in ~/.local/share/fonts/"
  warn "Then run: fc-cache -fv"
  warn "JetBrainsMono Nerd Font is installed as fallback (New Profile)"
fi

# -- Verify JetBrains fallback ---------------------------------------------
check_font "JetBrainsMono Nerd Font" \
  || warn "JetBrainsMono Nerd Font missing -- try: fc-cache -fv"

# -- Stow ------------------------------------------------------------------
stow_package terminator

ok "Terminator setup complete"
