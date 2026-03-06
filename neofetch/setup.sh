#!/usr/bin/env bash
#
# Neofetch Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Neofetch"
check_arch

# -- Packages --------------------------------------------------------------
pkg_install neofetch

# -- Stow ------------------------------------------------------------------
stow_package neofetch

# -- Verify ----------------------------------------------------------------
if command_exists neofetch; then
  ok "neofetch binary found"
else
  warn "neofetch binary not found"
fi

ok "Neofetch setup complete (Duck Arch theme)"
