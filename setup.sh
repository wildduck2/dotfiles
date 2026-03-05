#!/usr/bin/env bash
#
# Main Dotfiles Setup
#
# Installs all dependencies and stows all configs in the correct order.
# Designed for Arch Linux. Run from the dotfiles root directory.
#
# Usage:
#   ./setup.sh                Install everything
#   ./setup.sh kitty          Install only kitty
#   ./setup.sh nvim kitty     Install multiple modules
#
# Available modules:
#   base zsh tmux kitty terminator picom nvim i3 htop neofetch
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/scripts/helpers.sh"

# -- Pre-flight ------------------------------------------------------------
header "Dotfiles Setup"
check_arch

# -- Module functions ------------------------------------------------------

setup_base() {
  header "Base Packages"
  pkg_install git base-devel stow curl wget unzip xclip wl-clipboard
}

setup_zsh() {
  bash "$DOTFILES_DIR/zsh/setup.sh"
}

setup_tmux() {
  bash "$DOTFILES_DIR/tmux/setup.sh"
}

setup_kitty() {
  bash "$DOTFILES_DIR/kitty/setup.sh"
}

setup_terminator() {
  header "Terminator"
  pkg_install terminator
  stow_package terminator
}

setup_picom() {
  bash "$DOTFILES_DIR/picom/setup.sh"
}

setup_nvim() {
  bash "$DOTFILES_DIR/nvim/setup.sh"
}

setup_i3() {
  bash "$DOTFILES_DIR/i3/setup.sh"
}

setup_htop() {
  header "Htop"
  pkg_install htop
  stow_package htop
}

setup_neofetch() {
  header "Neofetch"
  pkg_install neofetch
  stow_package neofetch
}

# -- Single module mode ----------------------------------------------------
if [[ $# -gt 0 ]]; then
  for module in "$@"; do
    case "$module" in
      base)       setup_base ;;
      zsh)        setup_base && setup_zsh ;;
      tmux)       setup_base && setup_tmux ;;
      kitty)      setup_base && setup_kitty ;;
      terminator) setup_base && setup_terminator ;;
      picom)      setup_base && setup_picom ;;
      nvim)       setup_base && setup_nvim ;;
      i3)         setup_base && setup_i3 ;;
      htop)       setup_base && setup_htop ;;
      neofetch)   setup_base && setup_neofetch ;;
      *)          err "Unknown module: $module"
                  echo "Available: base zsh tmux kitty terminator picom nvim i3 htop neofetch"
                  exit 1 ;;
    esac
  done

  echo ""
  printf "${GREEN}${BOLD}Done!${NC}\n"
  exit 0
fi

# -- Full install (ordered) ------------------------------------------------

# 1. Base packages first
setup_base

# 2. Shell
setup_zsh

# 3. Terminal multiplexer
setup_tmux

# 4. Terminals
setup_kitty
setup_terminator

# 5. Compositor (before i3 so it's ready)
setup_picom

# 6. Editor (heaviest -- languages, LSPs, formatters, linters)
setup_nvim

# 7. Desktop environment
setup_i3

# 8. Utilities
setup_htop
setup_neofetch

# -- Summary ---------------------------------------------------------------
header "Setup Complete"

echo ""
printf "${GREEN}${BOLD}All dotfiles installed and stowed!${NC}\n"
echo ""
echo "Stowed modules:"

cd "$DOTFILES_DIR"
for pkg in zsh tmux kitty terminator picom nvim i3 htop neofetch; do
  if stow -n -R "$pkg" 2>/dev/null; then
    printf "  ${GREEN}%-14s${NC} ok\n" "$pkg"
  else
    printf "  ${YELLOW}%-14s${NC} needs attention\n" "$pkg"
  fi
done

echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: exec zsh"
echo "  2. Launch nvim -- plugins auto-install on first run"
echo "  3. Log out and select i3 as your session (if using i3)"
echo "  4. Place wallpaper at ~/.config/i3/bgs/bg.jpg"
echo ""
