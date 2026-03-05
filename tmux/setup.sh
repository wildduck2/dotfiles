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

# -- Core packages ---------------------------------------------------------
pkg_install tmux xclip bc

# -- ZSH (tmux.conf sets default-shell to /bin/zsh) -----------------------
pkg_install zsh

# -- TPM (Tmux Plugin Manager) --------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
  ok "TPM already installed"
else
  info "Installing TPM (Tmux Plugin Manager)"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  ok "TPM installed"
fi

# -- Stow ------------------------------------------------------------------
stow_package tmux

# -- Install plugins via TPM -----------------------------------------------
if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
  info "Installing tmux plugins via TPM"
  "$TPM_DIR/bin/install_plugins" && ok "Plugins installed" || warn "Plugin install had issues"
else
  warn "TPM install script not found -- launch tmux and press prefix + I"
fi

ok "Tmux setup complete"
echo ""
echo "Plugins managed by TPM:"
echo "  - tmux-sensible"
echo "  - vim-tmux-navigator"
echo "  - catppuccin-tmux"
echo "  - tokyo-night-tmux"
echo "  - tmux-yank"
echo ""
echo "Prefix key: Ctrl+d"
echo "Reload config: prefix + r"
echo "Install plugins: prefix + I"
