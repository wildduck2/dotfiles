#!/usr/bin/env bash
# ============================================================================
# i3 Setup Script - Arch Linux
# ============================================================================
#
# Installs all packages needed for the i3 desktop environment config.
# Run from the dotfiles root: ./i3/setup.sh
#
# What this does:
#   1. Installs official repo packages via pacman
#   2. Installs AUR packages via yay
#   3. Stows the i3 and picom configs
#   4. Pre-blurs the wallpaper for the lock screen
#   5. Configures gnome-screensaver with the wallpaper
#   6. Enables necessary services
#
# ============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*"; }

# ============================================================================
# 1. Check prerequisites
# ============================================================================
if ! command -v pacman &>/dev/null; then
    error "This script is for Arch Linux only."
    exit 1
fi

if ! command -v yay &>/dev/null; then
    error "yay (AUR helper) is required but not installed."
    echo "  Install it with:"
    echo "    sudo pacman -S --needed git base-devel"
    echo "    git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si"
    exit 1
fi

# ============================================================================
# 2. Install official repo packages
# ============================================================================
info "Installing pacman packages..."

PACMAN_PKGS=(
    # Window manager
    i3-wm
    i3status
    dmenu

    # Terminal
    terminator

    # Compositor (transparency, blur, animations)
    picom

    # Wallpaper
    feh

    # Screenshot
    flameshot

    # Image processing (for lock screen blur)
    imagemagick

    # Audio
    pulseaudio
    pavucontrol

    # Brightness
    xorg-xbacklight

    # Network & bluetooth
    network-manager-applet
    blueman

    # GNOME integration
    gnome-settings-daemon
    gnome-keyring
    polkit-gnome

    # NTFS support (external drives)
    ntfs-3g

    # Stow (dotfile management)
    stow

    # Xorg utils (for lock screen resolution detection)
    xorg-xdpyinfo
)

sudo pacman -S --needed "${PACMAN_PKGS[@]}"

# ============================================================================
# 3. Install AUR packages
# ============================================================================
info "Installing AUR packages..."

AUR_PKGS=(
    # System tray
    trayer

    # Lock screen (i3lock fork with colors, clock, blur)
    i3lock-color

    # GNOME screensaver (lock screen)
    gnome-screensaver-no-watchdog
)

yay -S --needed "${AUR_PKGS[@]}"

# ============================================================================
# 4. Stow configs
# ============================================================================
info "Stowing configs..."

cd "$DOTFILES_DIR"

# Remove existing dirs that would block stow
for dir in i3 picom; do
    target="$HOME/.config/$dir"
    if [ -d "$target" ] && [ ! -L "$target" ]; then
        warn "Backing up existing $target to ${target}.bak"
        mv "$target" "${target}.bak"
    fi
done

stow -R i3
stow -R picom 2>/dev/null || warn "picom stow skipped (may need manual setup)"

# ============================================================================
# 5. Generate blurred wallpaper for lock screen
# ============================================================================
WALLPAPER="$HOME/.config/i3/bgs/bg.jpg"
BLURRED="$HOME/.config/i3/bgs/bg-blurred.png"

if [ -f "$WALLPAPER" ]; then
    info "Generating blurred wallpaper for lock screen..."
    magick "$WALLPAPER" \
        -blur 0x16 \
        -brightness-contrast -10x-5 \
        "$BLURRED"
    info "Blurred wallpaper saved to $BLURRED"
else
    warn "No wallpaper found at $WALLPAPER - place one there and re-run."
fi

# ============================================================================
# 6. Configure GNOME screensaver
# ============================================================================
info "Configuring GNOME screensaver..."

if [ -f "$BLURRED" ]; then
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$BLURRED"
    gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
    gsettings set org.gnome.desktop.screensaver lock-enabled true
    gsettings set org.gnome.desktop.screensaver lock-delay 0
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
    info "GNOME screensaver configured with blurred wallpaper."
elif [ -f "$WALLPAPER" ]; then
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
    gsettings set org.gnome.desktop.screensaver lock-enabled true
    gsettings set org.gnome.desktop.screensaver lock-delay 0
    info "GNOME screensaver configured with wallpaper (no blur)."
fi

# ============================================================================
# 7. Verify everything is in place
# ============================================================================
echo ""
info "Verifying installation..."

CHECKS_PASSED=0
CHECKS_TOTAL=0

check() {
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    if command -v "$1" &>/dev/null; then
        info "$1 - OK"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        error "$1 - NOT FOUND"
    fi
}

check i3
check i3status
check dmenu
check terminator
check picom
check feh
check flameshot
check magick
check i3lock
check gnome-screensaver
check gnome-screensaver-command
check nm-applet
check stow

echo ""
if [ -L "$HOME/.config/i3/config" ]; then
    info "i3 config symlink - OK"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    error "i3 config not symlinked - run: cd $DOTFILES_DIR && stow i3"
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

if [ -f "$HOME/.config/picom/picom.conf" ]; then
    info "picom config - OK"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    error "picom config missing at ~/.config/picom/picom.conf"
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

if [ -f "$WALLPAPER" ]; then
    info "Wallpaper - OK"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    warn "Wallpaper missing - place an image at $WALLPAPER"
fi
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN} Setup complete! ($CHECKS_PASSED/$CHECKS_TOTAL checks passed)${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Log out and select 'i3' as your session"
echo "  2. Or reload i3 with Alt+Shift+r if already running"
echo "  3. Place your wallpaper at ~/.config/i3/bgs/bg.jpg"
echo "  4. Lock screen: Alt+x or Alt+Ctrl+l"
echo ""
