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
#   ./setup.sh --help         Show help
#   ./setup.sh --dry-run      Preview what would be installed
#   ./setup.sh --verify       Verify all tools are installed
#
# Available modules:
#   base bash zsh tmux kitty terminator picom nvim i3 duck-bash htop neofetch
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/scripts/helpers.sh"

ALL_MODULES=(bash zsh tmux kitty terminator picom nvim i3 duck-bash htop neofetch mechvibes)
DRY_RUN=0
VERIFY_ONLY=0

# -- Help ------------------------------------------------------------------
show_help() {
  cat <<'HELP'
Dotfiles Setup - Arch Linux development environment

Usage:
  ./setup.sh                Install everything (full setup)
  ./setup.sh <module> ...   Install specific module(s)
  ./setup.sh --help         Show this help
  ./setup.sh --dry-run      Preview what would be installed
  ./setup.sh --verify       Verify all tools are installed (no changes)

Available modules:
  base         Base packages (git, stow, curl, wget, yay, rust, bun, go, claude-code)
  bash         Bash shell config (.bashrc, .bash_profile)
  zsh          ZSH shell (Oh My Zsh, Zinit, fzf, zoxide, NVM)
  tmux         Terminal multiplexer (TPM, vim-tmux-navigator)
  kitty        Kitty terminal (JetBrainsMono Nerd Font)
  terminator   Terminator terminal (Berkeley Mono / JetBrainsMono)
  picom        Compositor (GLX backend, blur, opacity)
  nvim         Neovim IDE (74 plugins, 16 LSPs, formatters, linters)
  i3           i3 window manager (Catppuccin, gaps, lock, chrome, discord, OBS, yaak)
  duck-bash    Utility scripts (git, docker, fzf-tmux, cleanup)
  htop         Process viewer
  neofetch     System info display
  mechvibes    Mechanical keyboard sounds (NK Cream)

Full install order:
  base -> bash -> zsh -> tmux -> kitty -> terminator -> picom
       -> nvim -> i3 -> duck-bash -> htop -> neofetch

Requirements:
  - Arch Linux with pacman
  - sudo access
  - Internet connection (for AUR, git clones, curl installs)
HELP
}

# -- Dry run summary -------------------------------------------------------
show_dry_run() {
  local modules=("$@")
  header "Dry Run -- nothing will be installed"
  echo ""
  echo "Modules to install:"
  for mod in "${modules[@]}"; do
    echo "  - $mod"
  done
  echo ""
  echo "This would:"
  echo "  - Install system packages via pacman"
  echo "  - Install AUR packages via yay (if available)"
  echo "  - Clone git repos (Oh My Zsh, Zinit, TPM, NVM)"
  echo "  - Install yay (AUR helper) if not present"
  echo "  - Install language runtimes (Rust, Go, Bun, Deno)"
  echo "  - Install Claude Code CLI"
  echo "  - Install npm/pip/go packages"
  echo "  - Stow config files into \$HOME"
  echo ""
  echo "Run without --dry-run to proceed."
}

# -- Module functions ------------------------------------------------------

setup_base() {
  header "Base Packages"
  pkg_install git base-devel stow curl wget unzip xclip wl-clipboard fontconfig go

  # -- Bundled fonts (Berkeley Mono, etc.) --
  install_bundled_fonts

  # -- yay (AUR helper) -- needed by i3 and other modules
  install_yay

  # -- Rust toolchain (from official rustup installer) --
  if command_exists rustup; then
    ok "Rust toolchain already installed (rustup)"
  elif command_exists rustc; then
    ok "Rust compiler found"
  else
    duck_wait "Installing Rust via rustup" "~20-40s"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path \
      && ok "Rust installed" \
      || warn "Rust installation failed -- install manually: https://rustup.rs"
    source "$HOME/.cargo/env" 2>/dev/null || true
  fi

  # -- Bun (JavaScript runtime/bundler) --
  if command_exists bun; then
    ok "Bun already installed"
  else
    duck_wait "Installing Bun" "~10-20s"
    curl -fsSL https://bun.sh/install | bash \
      && ok "Bun installed" \
      || warn "Bun installation failed -- install manually: https://bun.sh"
    source "$HOME/.bun/_bun" 2>/dev/null || true
    export PATH="$HOME/.bun/bin:$PATH"
  fi

  # -- Claude Code (AI CLI) --
  if command_exists claude; then
    ok "Claude Code already installed"
  else
    duck_wait "Installing Claude Code" "~10-20s"
    curl -fsSL https://claude.ai/install.sh | bash \
      && ok "Claude Code installed" \
      || warn "Claude Code installation failed -- install manually: https://claude.ai/install.sh"
  fi
}

setup_bash()       { bash "$DOTFILES_DIR/bash/setup.sh"; }
setup_zsh()        { bash "$DOTFILES_DIR/zsh/setup.sh"; }
setup_tmux()       { bash "$DOTFILES_DIR/tmux/setup.sh"; }
setup_kitty()      { bash "$DOTFILES_DIR/kitty/setup.sh"; }
setup_terminator() { bash "$DOTFILES_DIR/terminator/setup.sh"; }
setup_picom()      { bash "$DOTFILES_DIR/picom/setup.sh"; }
setup_nvim()       { bash "$DOTFILES_DIR/nvim/setup.sh"; }
setup_i3()         { bash "$DOTFILES_DIR/i3/setup.sh"; }
setup_duck_bash()  { bash "$DOTFILES_DIR/duck-bash/setup.sh"; }

setup_mechvibes() {
  header "Mechvibes"
  stow_package mechvibes
  ok "Mechvibes config stowed (NK Cream, volume 50%)"
}

setup_htop() {
  header "Htop"
  pkg_install htop
  stow_package htop
  ok "Htop setup complete"
}

setup_neofetch() {
  header "Neofetch"
  pkg_install neofetch
  stow_package neofetch
  ok "Neofetch setup complete"
}

# -- Verify all tools ------------------------------------------------------
run_verify() {
  header "Verifying All Tools"
  local checks=0 total=0
  _check() {
    total=$((total + 1))
    if command_exists "$1"; then
      ok "$1"
      checks=$((checks + 1))
    else
      warn "$1 -- NOT FOUND"
    fi
  }

  echo ""
  info "Base tools:"
  _check git; _check stow; _check curl; _check wget; _check xclip

  info "AUR helper:"
  _check yay

  info "Language runtimes:"
  _check rustc; _check cargo; _check go; _check bun; _check node; _check npm; _check python; _check deno

  info "CLI tools:"
  _check claude; _check fzf; _check fd; _check rg; _check zoxide; _check tmux

  info "Shells:"
  _check bash; _check zsh

  info "Terminals:"
  _check kitty; _check terminator

  info "Editors:"
  _check nvim

  info "Formatters & linters:"
  _check stylua; _check shfmt; _check prettier; _check black; _check eslint_d

  info "Desktop (i3):"
  _check i3; _check i3status; _check picom; _check feh; _check flameshot
  _check i3lock; _check dmenu; _check nm-applet

  info "Apps:"
  _check google-chrome-stable; _check discord; _check firefox; _check obs; _check yaak

  info "Utilities:"
  _check htop; _check neofetch; _check jq; _check yt-dlp; _check qrencode

  echo ""
  if [[ $checks -eq $total ]]; then
    printf "${GREEN}${BOLD}All checks passed ($checks/$total)${NC}\n"
  else
    printf "${YELLOW}${BOLD}$checks/$total checks passed${NC}\n"
    warn "$((total - checks)) tool(s) missing -- run ./setup.sh to install"
  fi
}

# -- Parse arguments -------------------------------------------------------
MODULES=()
for arg in "$@"; do
  case "$arg" in
    --help|-h)    show_help; exit 0 ;;
    --dry-run|-n) DRY_RUN=1 ;;
    --verify|-V)  VERIFY_ONLY=1 ;;
    *)            MODULES+=("$arg") ;;
  esac
done

# -- Verify-only mode (no sudo needed) ------------------------------------
if [[ $VERIFY_ONLY -eq 1 ]]; then
  run_verify
  exit 0
fi

# -- Pre-flight checks ----------------------------------------------------
header "Dotfiles Setup"
check_arch
cache_sudo
check_internet || true  # warn but don't abort -- offline installs may partially work

# -- Single module mode ----------------------------------------------------
if [[ ${#MODULES[@]} -gt 0 ]]; then
  # Validate all module names first
  for module in "${MODULES[@]}"; do
    case "$module" in
      base|bash|zsh|tmux|kitty|terminator|picom|nvim|i3|htop|neofetch|duck-bash|mechvibes) ;;
      *) err "Unknown module: $module"
         echo "Available: ${ALL_MODULES[*]}"
         echo "Run ./setup.sh --help for details"
         exit 1 ;;
    esac
  done

  if [[ $DRY_RUN -eq 1 ]]; then
    show_dry_run "${MODULES[@]}"
    exit 0
  fi

  info "Installing modules: ${MODULES[*]}"
  echo ""

  for module in "${MODULES[@]}"; do
    case "$module" in
      base)       setup_base ;;
      bash)       setup_base && setup_bash ;;
      zsh)        setup_base && setup_zsh ;;
      tmux)       setup_base && setup_tmux ;;
      kitty)      setup_base && setup_kitty ;;
      terminator) setup_base && setup_terminator ;;
      picom)      setup_base && setup_picom ;;
      nvim)       setup_base && setup_nvim ;;
      i3)         setup_base && setup_i3 ;;
      htop)       setup_base && setup_htop ;;
      neofetch)   setup_base && setup_neofetch ;;
      duck-bash)  setup_base && setup_duck_bash ;;
      mechvibes)  setup_base && setup_mechvibes ;;
    esac
  done

  echo ""
  printf "🦆 ${GREEN}${BOLD}Done! Quack!${NC}\n"
  exit 0
fi

# -- Full install (dry-run check) ------------------------------------------
if [[ $DRY_RUN -eq 1 ]]; then
  show_dry_run "${ALL_MODULES[@]}"
  exit 0
fi

# -- Full install summary --------------------------------------------------
header "Full Install"
info "The following modules will be installed in order:"
for mod in "${ALL_MODULES[@]}"; do
  step "$mod"
done
echo ""

# -- Full install (ordered) ------------------------------------------------

# 1. Base packages (git, stow, etc.)
setup_base

# 2. Shells (bash as fallback, zsh as primary)
setup_bash
setup_zsh

# 3. Terminal multiplexer (depends on zsh, xclip)
setup_tmux

# 4. Terminals (depends on fonts)
setup_kitty
setup_terminator

# 5. Compositor (before i3 so it's ready)
setup_picom

# 6. Editor (heaviest -- languages, LSPs, formatters, linters)
setup_nvim

# 7. Desktop environment (depends on picom, terminator, fonts)
setup_i3

# 8. Utility scripts
setup_duck_bash

# 9. Utilities
setup_htop
setup_neofetch
setup_mechvibes

# -- Summary ---------------------------------------------------------------
header "Setup Complete"

echo ""
printf "🦆 ${GREEN}${BOLD}All dotfiles installed and stowed!${NC}\n"
echo ""
echo "Stowed modules:"

cd "$DOTFILES_DIR"
for pkg in "${ALL_MODULES[@]}"; do
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
echo "  5. Run 'claude' to configure Claude Code API key"
echo "  6. Run 'rustup update' to get latest Rust toolchain"
echo ""
duck_quote
