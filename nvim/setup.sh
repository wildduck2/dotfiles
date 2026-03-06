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
  if safe_curl https://sh.rustup.rs "rustup installer" | sh -s -- -y --no-modify-path; then
    ok "Rust installed"
  else
    warn "Rust installation failed -- silicon and rustfmt will be skipped"
  fi
  source "$HOME/.cargo/env" 2>/dev/null || true
fi

# Deno (for peek.nvim markdown preview)
if command_exists deno; then
  ok "Deno already installed"
else
  info "Installing Deno"
  if pkg_install deno 2>/dev/null; then
    ok "Deno installed via pacman"
  elif safe_curl https://deno.land/install.sh "Deno installer" | sh; then
    ok "Deno installed via install script"
  else
    warn "Deno installation failed -- peek.nvim markdown preview will not work"
  fi
fi

# -- Formatters ------------------------------------------------------------
header "Formatters"

pkg_install stylua shfmt clang
npm_install_global prettier || true
pip_install black isort || true

if command_exists rustup; then
  if rustup component list --installed 2>/dev/null | grep -q rustfmt; then
    ok "rustfmt already installed"
  else
    info "Adding rustfmt component"
    rustup component add rustfmt && ok "rustfmt installed" || warn "Failed to add rustfmt"
  fi
fi

# -- Linters ---------------------------------------------------------------
header "Linters"

pkg_install luacheck
npm_install_global eslint_d markdownlint-cli jsonlint @biomejs/biome || true
pip_install pylint || true

if command_exists hadolint; then
  ok "hadolint already installed"
else
  aur_install hadolint-bin || true
fi

# -- Go tools --------------------------------------------------------------
if command_exists go; then
  header "Go Tools"
  go_install goimports golang.org/x/tools/cmd/goimports@latest || true
  go_install golangci-lint github.com/golangci/golangci-lint/cmd/golangci-lint@latest || true
fi

# -- Optional tools --------------------------------------------------------
if command_exists silicon; then
  ok "silicon already installed"
else
  info "Installing silicon (code screenshot tool)"
  if pkg_install silicon 2>/dev/null; then
    true
  elif command_exists cargo && cargo install silicon 2>/dev/null; then
    ok "silicon installed via cargo"
  else
    warn "Could not install silicon -- install manually if needed"
  fi
fi

# -- Stow and post-setup --------------------------------------------------
stow_package nvim
mkdir -p "$HOME/.config/nvim/.undo"

info "On next nvim launch, lazy.nvim/Mason/Treesitter will auto-install plugins"
ok "Neovim setup complete"
