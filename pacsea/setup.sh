#!/usr/bin/env bash
#
# Pacsea Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Pacsea"
check_arch

# -- Packages --------------------------------------------------------------
# pacsea-bin: Rust TUI to browse, install, remove, update and downgrade packages
# downgrade: backs pacsea's downgrade action
aur_install pacsea-bin downgrade

# -- Stow ------------------------------------------------------------------
# Pacsea keeps logs and caches next to its config, so link the files one by one
# instead of letting stow link the whole folder into the dotfiles
mkdir -p "$HOME/.config/pacsea"
stow_package pacsea

ok "Pacsea setup complete"
