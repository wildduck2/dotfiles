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
  pipewire pipewire-pulse pavucontrol \
  xorg-xbacklight xorg-xdpyinfo \
  network-manager-applet blueman \
  gnome-settings-daemon gnome-keyring polkit-gnome \
  ntfs-3g fontconfig \
  ttf-jetbrains-mono-nerd \
  kitty terminator discord firefox xdotool xss-lock \
  arandr

# -- AUR packages ----------------------------------------------------------
# i3lock-color is a drop-in replacement for i3lock (same binary, more
# features) and the two packages conflict -- remove plain i3lock first so
# yay doesn't hit an unresolvable conflict prompt under --noconfirm.
if is_pkg_installed_exact i3lock; then
  info "Removing i3lock (superseded by i3lock-color)"
  sudo pacman -R --noconfirm i3lock || warn "Failed to remove i3lock -- i3lock-color install may fail"
fi

info "Installing AUR packages"
aur_install trayer i3lock-color

# obs-studio-tytan652 pulls in vlc-plugin-luajit (via ffmpeg-obs), which
# conflicts with vlc-plugin-lua (provided-for by vlc-plugin-luajit, so
# vlc-gui-qt/vlc stay satisfied after the swap), and needs ffmpeg-obs in
# place of system ffmpeg (ffmpeg-obs provides ffmpeg, so firefox/freerdp/
# opencv etc. keep resolving), and conflicts with the official obs-studio
# package directly. These removals must happen immediately before this
# specific install with no other yay call in between: yay's own dependency
# resolution can silently reinstall vlc-plugin-lua to "fix" vlc-gui-qt's
# now-missing dependency before we get here, re-triggering the conflict.
#
# Plain `pacman -R` refuses these: vlc-plugin-lua is required by the
# installed vlc-gui-qt, and obs-studio is required by the installed
# obs-pipewire-audio-capture. -Rdd skips that dependency check -- safe here
# because the AUR replacements below provide the same virtual packages and
# obs-pipewire-audio-capture gets reinstalled against obs-studio-tytan652
# right after.
for conflict_pkg in vlc-plugin-lua obs-studio ffmpeg; do
  if is_pkg_installed_exact "$conflict_pkg"; then
    info "Removing $conflict_pkg (superseded by an obs-studio-tytan652 build dep)"
    sudo pacman -Rdd --noconfirm "$conflict_pkg" || true
    # Verify explicitly -- a silent failure here (e.g. a stray lock file,
    # a second dependent package we haven't accounted for) leaves the old
    # package in place and the AUR install below fails on the same conflict
    # again with a confusing error far away from the actual cause.
    if is_pkg_installed_exact "$conflict_pkg"; then
      err "$conflict_pkg is still installed after removal attempt -- obs-studio-tytan652 install will hit the same conflict"
      err "  Check for a lock (/var/lib/pacman/db.lck) or another dependent: pacman -Qi $conflict_pkg | grep 'Required By'"
      exit 1
    fi
  fi
done
aur_install obs-studio-tytan652
aur_install obs-pipewire-audio-capture

aur_install google-chrome yaak-bin mechvibes

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

# -- Special keys ----------------------------------------------------------
bash "$SCRIPT_DIR/asus-keys.sh"
systemctl --user daemon-reload
systemctl --user enable --now key-popups.service

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
check_cmd mechvibes

ok "i3 setup complete ($CHECKS/$TOTAL checks passed)"
