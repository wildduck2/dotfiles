#!/usr/bin/env bash
#
# Shared helper functions for setup scripts.
# Source this file, do not execute it directly.
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info()   { printf "${BLUE}[INFO]${NC}  %s\n" "$*"; }
ok()     { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
warn()   { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
err()    { printf "${RED}[ERR]${NC}   %s\n" "$*"; }
header() { printf "\n${BOLD}-- %s --${NC}\n" "$*"; }

command_exists() { command -v "$1" &>/dev/null; }

pkg_install() {
  local missing=()
  for pkg in "$@"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    info "Installing: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  else
    ok "Already installed: $*"
  fi
}

aur_install() {
  local missing=()
  for pkg in "$@"; do
    if ! pacman -Qi "$pkg" &>/dev/null && ! yay -Qi "$pkg" &>/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    if command_exists yay; then
      info "Installing from AUR: ${missing[*]}"
      yay -S --needed --noconfirm "${missing[@]}"
    else
      warn "yay not found -- skipping AUR packages: ${missing[*]}"
    fi
  else
    ok "Already installed (AUR): $*"
  fi
}

npm_install_global() {
  local missing=()
  for pkg in "$@"; do
    if ! npm list -g "$pkg" &>/dev/null; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    info "Installing npm packages: ${missing[*]}"
    npm i -g "${missing[@]}"
  else
    ok "npm packages already installed: $*"
  fi
}

go_install() {
  local bin_name="$1"
  local pkg_path="$2"
  if command_exists "$bin_name"; then
    ok "Go tool already installed: $bin_name"
  else
    info "Installing Go tool: $bin_name"
    go install "$pkg_path"
  fi
}

pip_install() {
  local missing=()
  for pkg in "$@"; do
    if ! python -m pip show "$pkg" &>/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    info "Installing pip packages: ${missing[*]}"
    python -m pip install --user --break-system-packages "${missing[@]}" 2>/dev/null \
      || python -m pip install --user "${missing[@]}"
  else
    ok "pip packages already installed: $*"
  fi
}

stow_package() {
  local pkg="$1"
  local target="$HOME/.config/$pkg"

  if [[ -d "$target" ]] && [[ ! -L "$target" ]]; then
    warn "Backing up existing $target to ${target}.bak"
    mv "$target" "${target}.bak"
  fi

  info "Stowing $pkg"
  cd "$DOTFILES_DIR"
  stow -R "$pkg" 2>/dev/null && ok "Stowed $pkg" || warn "Failed to stow $pkg"
}

check_arch() {
  if ! command_exists pacman; then
    err "This script is designed for Arch Linux (pacman required)"
    exit 1
  fi
  ok "Running on Arch Linux"
}
