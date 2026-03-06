#!/usr/bin/env bash
#
# Mechvibes Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Mechvibes"
check_arch

# -- Install (AUR) --------------------------------------------------------
aur_install mechvibes-bin

# -- Stow ------------------------------------------------------------------
stow_package mechvibes

# -- Verify ----------------------------------------------------------------
if command_exists mechvibes; then
  ok "mechvibes binary found"
else
  warn "mechvibes binary not found"
fi

ok "Mechvibes setup complete (NK Cream, volume 50%)"
