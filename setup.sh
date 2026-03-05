#!/usr/bin/env bash
#
# Main Dotfiles Setup
#
# Installs all dependencies and stows all configs in the correct order.
# Designed for Arch Linux. Run from the dotfiles root directory.
#
# Usage:
#   ./setup.sh          Install everything
#   ./setup.sh kitty    Install only kitty
#   ./setup.sh nvim     Install only nvim
#   ./setup.sh i3       Install only i3
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/scripts/helpers.sh"

# -- Pre-flight ------------------------------------------------------------
header "Dotfiles Setup"
check_arch

# -- Base packages (needed by everything) ----------------------------------
setup_base() {
  header "Base Packages"
  pkg_install git base-devel stow curl wget unzip xclip wl-clipboard
}

# -- ZSH -------------------------------------------------------------------
setup_zsh() {
  header "ZSH"
  pkg_install zsh

  cd "$DOTFILES_DIR"
  info "Stowing zsh"
  stow -R zsh 2>/dev/null && ok "Stowed zsh" || warn "Failed to stow zsh"
}

# -- Tmux ------------------------------------------------------------------
setup_tmux() {
  header "Tmux"
  pkg_install tmux

  stow_package tmux
}

# -- Kitty -----------------------------------------------------------------
setup_kitty() {
  bash "$DOTFILES_DIR/kitty/setup.sh"
}

# -- Neovim ----------------------------------------------------------------
setup_nvim() {
  bash "$DOTFILES_DIR/nvim/setup.sh"
}

# -- i3 --------------------------------------------------------------------
setup_i3() {
  bash "$DOTFILES_DIR/i3/setup.sh"
}

# -- Htop ------------------------------------------------------------------
setup_htop() {
  header "Htop"
  pkg_install htop

  stow_package htop
}

# -- Neofetch --------------------------------------------------------------
setup_neofetch() {
  header "Neofetch"
  pkg_install neofetch

  stow_package neofetch
}

# -- Terminator ------------------------------------------------------------
setup_terminator() {
  header "Terminator"
  pkg_install terminator

  stow_package terminator
}

# -- Single module mode ----------------------------------------------------
if [[ $# -gt 0 ]]; then
  for module in "$@"; do
    case "$module" in
      base)       setup_base ;;
      zsh)        setup_base && setup_zsh ;;
      tmux)       setup_base && setup_tmux ;;
      kitty)      setup_base && setup_kitty ;;
      nvim)       setup_base && setup_nvim ;;
      i3)         setup_base && setup_i3 ;;
      htop)       setup_base && setup_htop ;;
      neofetch)   setup_base && setup_neofetch ;;
      terminator) setup_base && setup_terminator ;;
      *)          err "Unknown module: $module"
                  echo "Available: base zsh tmux kitty nvim i3 htop neofetch terminator"
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

# 2. Shell (zsh before anything that might depend on shell config)
setup_zsh

# 3. Terminal multiplexer
setup_tmux

# 4. Terminals
setup_kitty
setup_terminator

# 5. Editor (heaviest -- languages, LSPs, formatters, linters)
setup_nvim

# 6. Desktop environment
setup_i3

# 7. Utilities
setup_htop
setup_neofetch

# -- Summary ---------------------------------------------------------------
header "Setup Complete"

echo ""
printf "${GREEN}${BOLD}All dotfiles installed and stowed!${NC}\n"
echo ""
echo "Stowed modules:"

cd "$DOTFILES_DIR"
for pkg in zsh tmux kitty nvim i3 picom terminator htop neofetch; do
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
