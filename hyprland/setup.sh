#!/usr/bin/env bash
#
# Hyprland Desktop Environment Setup (Wayland) — HyprFlux-based
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Hyprland (Wayland)"
check_arch

# -- Ensure yay is available -----------------------------------------------
install_yay

# -- Pacman packages -------------------------------------------------------
info "Installing Hyprland and Wayland desktop packages"
pkg_install \
  hyprland hyprlock hypridle xdg-desktop-portal-hyprland \
  waybar rofi-wayland \
  swww \
  swaync wlogout \
  grim slurp wl-clipboard cliphist \
  brightnessctl pamixer playerctl libnotify \
  pipewire pipewire-pulse pavucontrol \
  network-manager-applet blueman \
  polkit-gnome gnome-keyring \
  ntfs-3g fontconfig jq \
  ttf-jetbrains-mono-nerd \
  kitty discord firefox \
  qt5-wayland qt6-wayland

# -- AUR packages ----------------------------------------------------------
info "Installing AUR packages"
aur_install google-chrome

# -- Font check ------------------------------------------------------------
check_preferred_font || true

# -- Make scripts executable -----------------------------------------------
chmod +x "$SCRIPT_DIR/.config/hypr/scripts/"*.sh 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.config/hypr/startup.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.config/hypr/hyprlock/Scripts/"*.sh 2>/dev/null || true

# -- Stow configs ----------------------------------------------------------
stow_package hyprland

# -- Wallpaper: copy from i3 (swww doesn't follow symlinks reliably) -------
I3_WALLPAPER="$HOME/.config/i3/bgs/bg.jpg"
HYPR_BGS="$HOME/.config/hypr/bgs"
HYPR_WALLPAPER="$HYPR_BGS/bg.jpg"

mkdir -p "$HYPR_BGS"

if [[ -f "$I3_WALLPAPER" && ! -f "$HYPR_WALLPAPER" ]]; then
  info "Copying wallpaper from i3 config"
  cp "$I3_WALLPAPER" "$HYPR_WALLPAPER"
  ok "Wallpaper copied to $HYPR_WALLPAPER"
elif [[ -e "$HYPR_WALLPAPER" ]]; then
  ok "Wallpaper already in place"
else
  warn "No wallpaper found — place one at $HYPR_WALLPAPER"
fi

# -- Fetch swaync icons from HyprFlux -------------------------------------
SWAYNC_ICONS="$HOME/.config/swaync/icons"
SWAYNC_IMAGES="$HOME/.config/swaync/images"

if [[ ! -d "$SWAYNC_ICONS" ]] || [[ $(find "$SWAYNC_ICONS" -name "*.png" 2>/dev/null | wc -l) -eq 0 ]]; then
  info "Fetching notification icons from HyprFlux"
  HYPRFLUX_TMP="$(mktemp -d)"
  if git clone --depth 1 --filter=blob:none --sparse https://github.com/ahmad9059/HyprFlux.git "$HYPRFLUX_TMP" 2>/dev/null; then
    cd "$HYPRFLUX_TMP"
    git sparse-checkout set .config/swaync/icons .config/swaync/images 2>/dev/null || true
    cd - >/dev/null
    mkdir -p "$SWAYNC_ICONS" "$SWAYNC_IMAGES"
    cp -r "$HYPRFLUX_TMP/.config/swaync/icons/"* "$SWAYNC_ICONS/" 2>/dev/null || true
    cp -r "$HYPRFLUX_TMP/.config/swaync/images/"* "$SWAYNC_IMAGES/" 2>/dev/null || true
    rm -rf "$HYPRFLUX_TMP"
    ok "Notification icons installed"
  else
    warn "Could not fetch notification icons — notifications will work without icons"
    rm -rf "$HYPRFLUX_TMP"
  fi
else
  ok "Notification icons already in place"
fi

# -- Hyprlock profile photo placeholder ------------------------------------
HYPRLOCK_DIR="$HOME/.config/hypr/hyprlock"
if [[ ! -f "$HYPRLOCK_DIR/profile.jpg" ]]; then
  warn "No profile photo for lock screen — place one at $HYPRLOCK_DIR/profile.jpg"
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

check_cmd Hyprland
check_cmd hyprlock
check_cmd hypridle
check_cmd waybar
check_cmd rofi
check_cmd swww
check_cmd swaync-client
check_cmd wlogout
check_cmd grim
check_cmd slurp
check_cmd wl-copy
check_cmd cliphist
check_cmd brightnessctl
check_cmd pamixer
check_cmd playerctl
check_cmd nm-applet
check_cmd kitty
check_cmd google-chrome-stable
check_cmd discord
check_cmd firefox

ok "Hyprland setup complete ($CHECKS/$TOTAL checks passed)"
echo ""
echo "Next steps:"
echo "  1. Place wallpaper at ~/.config/hypr/bgs/bg.jpg"
echo "  2. Place profile photo at ~/.config/hypr/hyprlock/profile.jpg"
echo "  3. Log out and select 'Hyprland' as your session"
echo "  4. Your i3 config is untouched — switch back anytime"
