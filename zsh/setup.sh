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

# -- Packages --------------------------------------------------------------
pkg_install zsh fzf zoxide git curl

# -- Oh My Zsh -------------------------------------------------------------
OMZ_DIR="$HOME/.oh-my-zsh"
if [[ -d "$OMZ_DIR" ]]; then
  ok "Oh My Zsh already installed"
else
  info "Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  ok "Oh My Zsh installed"
fi

# -- Zinit -----------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ -d "$ZINIT_HOME" ]]; then
  ok "Zinit already installed"
else
  info "Installing Zinit"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  ok "Zinit installed"
fi

# -- NVM (Node Version Manager) --------------------------------------------
NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  ok "NVM already installed"
else
  info "Installing NVM"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  ok "NVM installed"
fi

# -- Stow ------------------------------------------------------------------
stow_package zsh

# -- Default shell ---------------------------------------------------------
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" == */zsh ]]; then
  ok "Default shell is already zsh"
else
  info "Changing default shell to zsh"
  chsh -s "$(which zsh)" && ok "Default shell set to zsh" || warn "Failed -- run: chsh -s $(which zsh)"
fi

ok "ZSH setup complete"
