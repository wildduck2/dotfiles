#!/usr/bin/env bash
#
# ZSH Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "ZSH"

check_arch

# -- Core packages ---------------------------------------------------------
pkg_install zsh fzf zoxide

# -- Oh My Zsh -------------------------------------------------------------
OMZ_DIR="$HOME/.oh-my-zsh"
if [[ -d "$OMZ_DIR" ]]; then
  ok "Oh My Zsh already installed"
else
  info "Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  ok "Oh My Zsh installed"
fi

# -- Zinit (auto-bootstraps from .zshrc, but ensure parent dir exists) -----
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ -d "$ZINIT_HOME" ]]; then
  ok "Zinit already installed"
else
  info "Installing Zinit"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  ok "Zinit installed"
fi

# -- Stow (zsh uses home-level dotfiles, not .config) ---------------------
cd "$DOTFILES_DIR"
info "Stowing zsh"
stow -R zsh 2>/dev/null && ok "Stowed zsh" || warn "Failed to stow zsh (check for conflicts)"

# -- Set default shell -----------------------------------------------------
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" == */zsh ]]; then
  ok "Default shell is already zsh"
else
  info "Changing default shell to zsh"
  chsh -s "$(which zsh)" && ok "Default shell set to zsh" || warn "Failed to change shell -- run: chsh -s $(which zsh)"
fi

ok "ZSH setup complete"
echo ""
echo "Components:"
echo "  - Oh My Zsh (framework)"
echo "  - Zinit (plugin manager)"
echo "  - zsh-syntax-highlighting"
echo "  - zsh-completions"
echo "  - zsh-autosuggestions"
echo "  - fzf-tab"
echo "  - fzf (fuzzy finder)"
echo "  - zoxide (smart cd)"
echo ""
echo "Run 'exec zsh' or restart your terminal to apply"
