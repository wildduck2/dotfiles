#!/usr/bin/env bash
#
# Sway Desktop Environment Setup (Wayland — i3 drop-in replacement)
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Sway (Wayland)"
check_arch

# -- Ensure yay is available -----------------------------------------------
install_yay

# -- Pacman packages -------------------------------------------------------
info "Installing Sway and Wayland desktop packages"
pkg_install \
  sway swaylock swayidle swaybg xdg-desktop-portal-wlr \
  i3status dmenu \
  grim slurp wl-clipboard cliphist \
  brightnessctl \
  pipewire pipewire-pulse pavucontrol \
  network-manager-applet blueman \
  polkit-gnome gnome-keyring \
  ntfs-3g fontconfig jq \
  ttf-jetbrains-mono-nerd \
  kitty terminator discord firefox \
  qt5-wayland qt6-wayland

# -- AUR packages ----------------------------------------------------------
info "Installing AUR packages"
aur_install google-chrome

# -- Font check ------------------------------------------------------------
check_preferred_font || true

# -- Make scripts executable -----------------------------------------------
chmod +x "$SCRIPT_DIR/.config/sway/lock.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.config/sway/startup.sh" 2>/dev/null || true

# -- Stow configs ----------------------------------------------------------
stow_package sway

# -- Wallpaper: copy from i3 -----------------------------------------------
I3_WALLPAPER="$HOME/.config/i3/bgs/bg.jpg"
SWAY_BGS="$HOME/.config/sway/bgs"
SWAY_WALLPAPER="$SWAY_BGS/bg.jpg"

mkdir -p "$SWAY_BGS"

if [[ -f "$I3_WALLPAPER" && ! -f "$SWAY_WALLPAPER" ]]; then
  info "Copying wallpaper from i3 config"
  cp "$I3_WALLPAPER" "$SWAY_WALLPAPER"
  ok "Wallpaper copied to $SWAY_WALLPAPER"
elif [[ -f "$SWAY_WALLPAPER" ]]; then
  ok "Wallpaper already in place"
else
  warn "No wallpaper found — place one at $SWAY_WALLPAPER"
fi

# -- Verify ----------------------------------------------------------------
header "Verification"

CHECKS=0 TOTAL=0
check_cmd() {
  TOTAL=$((TOTAL + 1))
  if command_exists "$1"; then
    ok "$1"
    CHECKS=$((CHECKS + 1))
  else
    warn "$1 -- NOT FOUND"
  fi
}

check_cmd sway
check_cmd swaylock
check_cmd swayidle
check_cmd i3status
check_cmd dmenu
check_cmd grim
check_cmd slurp
check_cmd wl-copy
check_cmd cliphist
check_cmd brightnessctl
check_cmd nm-applet
check_cmd kitty
check_cmd terminator
check_cmd google-chrome-stable
check_cmd discord
check_cmd firefox

ok "Sway setup complete ($CHECKS/$TOTAL checks passed)"
echo ""
echo "Next steps:"
echo "  1. Place wallpaper at ~/.config/sway/bgs/bg.jpg"
echo "  2. Log out and select 'Sway' as your session"
echo "  3. Your i3 config is untouched — switch back anytime"
