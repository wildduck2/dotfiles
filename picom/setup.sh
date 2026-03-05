#!/usr/bin/env bash
#
# Picom Compositor Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Picom Compositor"

check_arch

# -- Core package ----------------------------------------------------------
pkg_install picom

# -- GLX backend dependencies ----------------------------------------------
# picom.conf uses backend = "glx" and dual_kawase blur
pkg_install libx11 libxcomposite libxdamage libxfixes libxrender mesa

# -- Stow ------------------------------------------------------------------
stow_package picom

# -- Verify ----------------------------------------------------------------
if command_exists picom; then
  ok "picom installed: $(picom --version 2>/dev/null | head -1)"
else
  err "picom not found after install"
fi

ok "Picom setup complete"
echo ""
echo "Configuration:"
echo "  - Backend: GLX (required for blur)"
echo "  - Blur: dual_kawase (strength 8, radius 10)"
echo "  - Active opacity: 90%"
echo "  - Inactive opacity: 85%"
echo "  - Fading enabled"
echo "  - Shadows disabled"
echo "  - Video/image apps excluded from blur and opacity"
echo ""
echo "Start picom: picom --daemon"
echo "Or it auto-starts via i3 config"
