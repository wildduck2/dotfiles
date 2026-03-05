#!/usr/bin/env bash
#
# Neovim Development Environment Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Neovim"
check_arch

# -- Core packages ---------------------------------------------------------
pkg_install neovim ripgrep fd tree-sitter

# -- Language runtimes -----------------------------------------------------
header "Language Runtimes"

pkg_install nodejs npm python python-pip go

# Rust
if command_exists rustup; then
  ok "Rust toolchain already installed (rustup)"
elif command_exists rustc; then
  ok "Rust compiler found"
else
  info "Installing Rust via rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  source "$HOME/.cargo/env" 2>/dev/null || true
fi

# Deno (for peek.nvim markdown preview)
if command_exists deno; then
  ok "Deno already installed"
else
  pkg_install deno 2>/dev/null || {
    info "Installing Deno via install script"
    curl -fsSL https://deno.land/install.sh | sh
  }
fi

# -- Formatters ------------------------------------------------------------
header "Formatters"

pkg_install stylua shfmt clang
npm_install_global prettier
pip_install black isort

if command_exists rustup; then
  if rustup component list --installed | grep -q rustfmt; then
    ok "rustfmt already installed"
  else
    info "Adding rustfmt component"
    rustup component add rustfmt
  fi
fi

# -- Linters ---------------------------------------------------------------
header "Linters"

pkg_install luacheck
npm_install_global eslint_d markdownlint-cli jsonlint @biomejs/biome
pip_install pylint

if command_exists hadolint; then
  ok "hadolint already installed"
else
  aur_install hadolint-bin
fi

# -- Go tools --------------------------------------------------------------
if command_exists go; then
  header "Go Tools"
  go_install goimports golang.org/x/tools/cmd/goimports@latest
  go_install golangci-lint github.com/golangci/golangci-lint/cmd/golangci-lint@latest
fi

# -- Optional tools --------------------------------------------------------
if ! command_exists silicon; then
  pkg_install silicon 2>/dev/null || cargo install silicon 2>/dev/null || {
    warn "Could not install silicon -- install manually if needed"
  }
fi

# -- Stow and post-setup --------------------------------------------------
stow_package nvim
mkdir -p "$HOME/.config/nvim/.undo"

info "On next nvim launch, lazy.nvim/Mason/Treesitter will auto-install plugins"
ok "Neovim setup complete"
