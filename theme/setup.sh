#!/usr/bin/env bash
#
# System Dark Theme (Tokyo Night GTK)
# Can be run standalone or called from the main setup.sh
#
# Forces GTK3/GTK4 apps (file pickers, nm-applet, blueman, pavucontrol,
# polkit-gnome dialogs, etc.) into dark mode using the Tokyonight-Dark
# GTK theme, matching the Tokyo Night palette used elsewhere (kitty,
# btop, banana-cursor).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "System Dark Theme (Tokyo Night)"
check_arch

# -- Ensure yay is available -----------------------------------------------
install_yay

# -- AUR packages ------------------------------------------------------------
aur_install tokyonight-gtk-theme-git

# -- Stow (GTK3 + GTK4 settings.ini) ----------------------------------------
# Owns .config/gtk-3.0/settings.ini and .config/gtk-4.0/settings.ini.
# The cursor theme name/size lives here too (not in banana-cursor) since
# stow can't split ownership of a single settings.ini across two packages.
stow_package theme

# -- Apply live (current session) -------------------------------------------
if command_exists gsettings; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark' 2>/dev/null || true
fi

ok "Dark theme (Tokyonight-Dark) applied system-wide"
