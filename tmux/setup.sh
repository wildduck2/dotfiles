#!/usr/bin/env bash
#
# Tmux Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Tmux"
check_arch

# -- Packages --------------------------------------------------------------
# tmux: terminal multiplexer
# xclip: clipboard support (tmux-yank uses it)
# bc: version comparison in vim-tmux-navigator config
# zsh: tmux.conf sets default-shell to /bin/zsh
pkg_install tmux xclip bc zsh

# -- TPM (Tmux Plugin Manager) --------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
  ok "TPM already installed"
else
  info "Installing TPM"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  ok "TPM installed"
fi

# -- Stow ------------------------------------------------------------------
stow_package tmux

# -- Install plugins -------------------------------------------------------
if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
  info "Installing tmux plugins via TPM"
  "$TPM_DIR/bin/install_plugins" || warn "Plugin install had issues -- launch tmux and press prefix + I"
else
  warn "TPM install script not found -- launch tmux and press prefix + I"
fi

ok "Tmux setup complete"
