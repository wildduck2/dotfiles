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
  picom feh flameshot imagemagick \
  pulseaudio pavucontrol \
  xorg-xbacklight xorg-xdpyinfo \
  network-manager-applet blueman \
  gnome-settings-daemon gnome-keyring polkit-gnome \
  ntfs-3g \
  ttf-jetbrains-mono-nerd

# -- AUR packages ----------------------------------------------------------
aur_install trayer i3lock-color gnome-screensaver-no-watchdog

# -- Font check ------------------------------------------------------------
# i3 config and lock.sh use Berkeley Mono Trial (proprietary/trial font).
# It must be manually placed in ~/.local/share/fonts/
if check_font "Berkeley Mono"; then
  ok "Berkeley Mono Trial available for i3 and lock screen"
else
  warn "Berkeley Mono Trial not found"
  warn "i3 bar, lock screen, and terminator use this font"
  warn "Download from https://berkeleymono.com/ and place .ttf files in ~/.local/share/fonts/"
  warn "Then run: fc-cache -fv"
  warn "Falling back to JetBrainsMono Nerd Font (already installed)"
fi

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
if command_exists gsettings; then
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
else
  warn "gsettings not found -- skipping screensaver config"
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
    err "$1 -- NOT FOUND"
  fi
}

check_cmd i3
check_cmd i3status
check_cmd dmenu
check_cmd picom
check_cmd feh
check_cmd flameshot
check_cmd magick
check_cmd i3lock
check_cmd nm-applet

ok "i3 setup complete ($CHECKS/$TOTAL checks passed)"
