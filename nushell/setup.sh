#!/usr/bin/env bash
#
# Nushell Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Nushell"
check_arch

# -- Packages --------------------------------------------------------------
pkg_install nushell

# -- Stow ------------------------------------------------------------------
stow_package nushell

ok "Nushell setup complete (open a new shell to get nq)"
