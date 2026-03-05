#!/usr/bin/env bash
#
# i3 Desktop Environment Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "i3 Window Manager"

check_arch

# -- Check yay -------------------------------------------------------------
if ! command_exists yay; then
  err "yay (AUR helper) is required but not installed"
  echo "  Install it with:"
  echo "    sudo pacman -S --needed git base-devel"
  echo "    git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si"
  exit 1
fi

# -- Pacman packages -------------------------------------------------------
pkg_install \
  i3-wm i3status dmenu \
  terminator picom feh flameshot imagemagick \
  pulseaudio pavucontrol \
  xorg-xbacklight xorg-xdpyinfo \
  network-manager-applet blueman \
  gnome-settings-daemon gnome-keyring polkit-gnome \
  ntfs-3g

# -- AUR packages ----------------------------------------------------------
aur_install trayer i3lock-color gnome-screensaver-no-watchdog

# -- Stow configs ----------------------------------------------------------
stow_package i3
stow_package picom

# -- Blurred wallpaper for lock screen -------------------------------------
WALLPAPER="$HOME/.config/i3/bgs/bg.jpg"
BLURRED="$HOME/.config/i3/bgs/bg-blurred.png"

if [[ -f "$WALLPAPER" ]]; then
  info "Generating blurred wallpaper for lock screen"
  magick "$WALLPAPER" -blur 0x16 -brightness-contrast -10x-5 "$BLURRED"
  ok "Blurred wallpaper saved to $BLURRED"
else
  warn "No wallpaper found at $WALLPAPER -- place one there and re-run"
fi

# -- GNOME screensaver config ----------------------------------------------
if [[ -f "$BLURRED" ]]; then
  info "Configuring GNOME screensaver with blurred wallpaper"
  gsettings set org.gnome.desktop.screensaver picture-uri "file://$BLURRED"
  gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
  gsettings set org.gnome.desktop.screensaver lock-enabled true
  gsettings set org.gnome.desktop.screensaver lock-delay 0
  gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
elif [[ -f "$WALLPAPER" ]]; then
  info "Configuring GNOME screensaver with wallpaper (no blur)"
  gsettings set org.gnome.desktop.screensaver picture-uri "file://$WALLPAPER"
  gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
  gsettings set org.gnome.desktop.screensaver lock-enabled true
  gsettings set org.gnome.desktop.screensaver lock-delay 0
fi

# -- Verify ----------------------------------------------------------------
header "Verification"

CHECKS_PASSED=0
CHECKS_TOTAL=0

check_cmd() {
  CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
  if command_exists "$1"; then
    ok "$1"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
  else
    err "$1 -- NOT FOUND"
  fi
}

check_cmd i3
check_cmd i3status
check_cmd dmenu
check_cmd terminator
check_cmd picom
check_cmd feh
check_cmd flameshot
check_cmd magick
check_cmd i3lock
check_cmd nm-applet

echo ""
ok "i3 setup complete ($CHECKS_PASSED/$CHECKS_TOTAL checks passed)"
echo ""
echo "Next steps:"
echo "  1. Log out and select i3 as your session"
echo "  2. Or reload i3 with Alt+Shift+r if already running"
echo "  3. Place your wallpaper at ~/.config/i3/bgs/bg.jpg"
echo "  4. Lock screen: Alt+x or Alt+Ctrl+l"
