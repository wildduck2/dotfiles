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

# -- Ensure yay is available -----------------------------------------------
install_yay

# -- Pacman packages -------------------------------------------------------
info "Installing i3 and desktop packages"
pkg_install \
  i3-wm i3status dmenu \
  picom feh flameshot imagemagick \
  pulseaudio pavucontrol \
  xorg-xbacklight xorg-xdpyinfo \
  network-manager-applet blueman \
  gnome-settings-daemon gnome-keyring polkit-gnome \
  ntfs-3g fontconfig \
  ttf-jetbrains-mono-nerd \
  kitty terminator discord firefox xdotool

# -- AUR packages ----------------------------------------------------------
info "Installing AUR packages"
aur_install trayer i3lock-color gnome-screensaver-no-watchdog \
  obs-studio-tytan652 obs-pipewire-audio-capture \
  google-chrome yaak-bin

# -- OBS Virtual Camera (v4l2loopback) ------------------------------------
info "Setting up OBS virtual camera support"
pkg_install v4l2loopback-dkms
if ! lsmod | grep -q v4l2loopback; then
  info "Loading v4l2loopback kernel module"
  sudo modprobe v4l2loopback || warn "Failed to load v4l2loopback -- may need a reboot after kernel headers install"
fi

# -- Font check ------------------------------------------------------------
check_preferred_font

# -- Make lock script executable -------------------------------------------
chmod +x "$SCRIPT_DIR/.config/i3/lock.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.config/i3/startup.sh" 2>/dev/null || true

# -- Stow configs ----------------------------------------------------------
# NOTE: picom is stowed by its own module (picom/setup.sh), not here
stow_package i3

# -- Blurred wallpaper for lock screen -------------------------------------
WALLPAPER="$HOME/.config/i3/bgs/bg.jpg"
BLURRED="$HOME/.config/i3/bgs/bg-blurred.png"

if [[ -f "$WALLPAPER" ]]; then
  if command_exists magick; then
    info "Generating blurred wallpaper for lock screen"
    if magick "$WALLPAPER" -blur 0x16 -brightness-contrast -10x-5 "$BLURRED"; then
      ok "Blurred wallpaper saved to $BLURRED"
    else
      warn "Failed to generate blurred wallpaper"
    fi
  else
    warn "ImageMagick (magick) not found -- cannot generate blurred wallpaper"
  fi
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
    warn "$1 -- NOT FOUND"
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
check_cmd kitty
check_cmd terminator
check_cmd google-chrome-stable
check_cmd discord
check_cmd firefox
check_cmd obs
check_cmd yaak

ok "i3 setup complete ($CHECKS/$TOTAL checks passed)"
