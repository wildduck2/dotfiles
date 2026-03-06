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
# zsh: the shell itself
# fzf: fuzzy finder (used by fzf --zsh, fzf-tab, fzf_nvim widget)
# fd: fast find alternative (used by fzf_nvim widget in .zshrc)
# zoxide: smart cd replacement (eval "$(zoxide init --cmd cd zsh)")
# git: needed by Oh My Zsh, Zinit, and the git plugin
# curl: needed by Oh My Zsh installer and NVM installer
pkg_install zsh fzf fd zoxide git curl

# -- Oh My Zsh -------------------------------------------------------------
OMZ_DIR="$HOME/.oh-my-zsh"
if [[ -d "$OMZ_DIR" ]]; then
  ok "Oh My Zsh already installed"
else
  info "Installing Oh My Zsh"
  sh -c "$(safe_curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh "Oh My Zsh installer")" "" --unattended --keep-zshrc
  ok "Oh My Zsh installed"
fi

# -- Zinit (plugin manager) ------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ -d "$ZINIT_HOME" ]]; then
  ok "Zinit already installed"
else
  info "Installing Zinit"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  if git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"; then
    ok "Zinit installed"
  else
    err "Failed to clone Zinit -- check internet and try again"
    exit 1
  fi
fi

# -- NVM (Node Version Manager) --------------------------------------------
# .zshrc sources $NVM_DIR/nvm.sh and $NVM_DIR/bash_completion
NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  ok "NVM already installed"
else
  info "Installing NVM"
  safe_curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh "NVM installer" | bash
  ok "NVM installed"
fi

# -- Completions directory -------------------------------------------------
# .zshrc does: mkdir -p "$HOME/.zsh/completions" and adds to FPATH
mkdir -p "$HOME/.zsh/completions"

# -- Stow ------------------------------------------------------------------
# zsh dotfiles are home-level (.zshrc, .zshenv), not .config-based
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
