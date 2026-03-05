#!/usr/bin/env bash
#
# Bash Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Bash"
check_arch

# -- Packages --------------------------------------------------------------
# bash itself is always present on Arch, but ensure it's up to date
pkg_install bash

# -- Stow ------------------------------------------------------------------
# bash dotfiles live in $HOME (.bashrc, .bash_profile), not .config
stow_package bash

ok "Bash setup complete"
