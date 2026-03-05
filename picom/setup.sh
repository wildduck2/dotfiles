#!/usr/bin/env bash
#
# Picom Compositor Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Picom"
check_arch

# -- Packages --------------------------------------------------------------
# picom: compositor
# mesa: GLX backend support (picom.conf uses backend = "glx")
pkg_install picom mesa

# -- Stow ------------------------------------------------------------------
stow_package picom

ok "Picom setup complete"
