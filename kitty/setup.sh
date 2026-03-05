#!/usr/bin/env bash
#
# Kitty Terminal Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Kitty Terminal"

check_arch

pkg_install kitty ttf-jetbrains-mono-nerd

if fc-list | grep -qi "JetBrainsMono Nerd Font.*Bold Italic"; then
  ok "JetBrainsMono Nerd Font Bold Italic available"
else
  warn "Bold Italic style not detected -- try: fc-cache -fv"
fi

stow_package kitty

ok "Kitty setup complete"
