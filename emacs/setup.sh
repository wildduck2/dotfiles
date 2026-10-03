#!/usr/bin/env bash
#
# Doom Emacs Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Emacs (Doom)"
check_arch

# -- Packages ---------------------------------------------------------------
# emacs: GTK build (pgtk), works fine under i3/X11 and Wayland (sway/hyprland)
# ripgrep/fd: used by Doom's project search (+ivy/+vertico, projectile)
# less: pager `doom doctor`/`doom sync -v` need for output
# ttf-jetbrains-mono-nerd: fallback font, matches kitty/terminator
# ttf-nerd-fonts-symbols-mono: icon glyphs for nerd-icons.el (treemacs, modeline, dashboard)
pkg_install emacs git ripgrep fd less ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono

# -- Font check --------------------------------------------------------------
# Non-fatal: under `set -e` a bare call would silently kill the whole script
# if neither font is detected yet (e.g. fontconfig cache not rebuilt yet).
check_preferred_font || true

# -- Doom framework (cloned, not stowed -- same relationship as .oh-my-zsh) --
DOOM_DIR="$HOME/.config/emacs"
# Check for bin/doom, not just the directory -- a directory can exist from an
# interrupted/killed clone (e.g. a suspended `sudo` run left it half-written)
# with no working `doom` binary in it.
if [[ -x "$DOOM_DIR/bin/doom" ]]; then
  ok "Doom Emacs framework already installed"
else
  [[ -d "$DOOM_DIR" ]] && { warn "Removing incomplete Doom checkout at $DOOM_DIR"; rm -rf "$DOOM_DIR"; }
  duck_wait "Cloning Doom Emacs framework" "~30-60s"
  git clone https://github.com/doomemacs/doomemacs "$DOOM_DIR" \
    && ok "Doom Emacs framework cloned" \
    || { err "Failed to clone Doom Emacs -- check internet and try again"; exit 1; }
fi

DOOM_BIN="$DOOM_DIR/bin/doom"

# -- Stow (private config: init.el, config.el, packages.el) -----------------
# Must happen before `doom sync` so Doom reads our modules, not a
# freshly-generated template.
stow_package emacs

# -- Language servers ---------------------------------------------------------
header "Language Servers"

# TypeScript/JS + web (json/html/css language servers)
npm_install_global typescript typescript-language-server vscode-langservers-extracted || true

# Rust
pkg_install rust-analyzer

# C/C++ (clangd ships with clang)
pkg_install clang

# Elixir (elixir-ls is AUR-only)
pkg_install elixir
aur_install elixir-ls || warn "elixir-ls install failed -- install manually or Doom's :lang elixir module falls back to no LSP"

# -- Sync Doom packages -------------------------------------------------------
# Idempotent: installs on first run, updates on re-run. Safe to call directly
# instead of `doom install` since our config is already in place via stow.
duck_wait "Syncing Doom packages (installing everything declared in init.el)" "~1-3min"
if "$DOOM_BIN" sync --no-color; then
  ok "Doom packages synced"
else
  err "Doom sync failed -- run '$DOOM_BIN doctor' to diagnose"
  exit 1
fi

# -- Daemon (systemd --user unit ships with the emacs package) ---------------
# TUI-only setup: emacsclient -t attaches a text-mode frame to this daemon
# (see the `emacs` alias in zsh/.zshrc), no GUI frame involved.
#
# Override --init-directory explicitly: this Emacs build doesn't reliably
# fall back to ~/.config/emacs without XDG_CONFIG_HOME set (nothing on this
# system sets it, not even the interactive shell), so a plain `emacs
# --fg-daemon` silently recreates and uses an empty ~/.emacs.d instead --
# `doom doctor`'s "Found another Emacs config" warning is this bug, not
# cosmetic. An empty auto-generated ~/.emacs.d (no init.el of its own) is
# removed so it can't shadow ~/.config/emacs again.
if command_exists systemctl && systemctl --user list-unit-files emacs.service &>/dev/null; then
  OVERRIDE_DIR="$HOME/.config/systemd/user/emacs.service.d"
  mkdir -p "$OVERRIDE_DIR"
  cat > "$OVERRIDE_DIR/override.conf" << 'UNIT'
[Service]
ExecStart=
ExecStart=/usr/bin/emacs --fg-daemon --init-directory=%h/.config/emacs
UNIT
  systemctl --user daemon-reload

  [[ -d "$HOME/.emacs.d" && ! -f "$HOME/.emacs.d/init.el" ]] && rm -rf "$HOME/.emacs.d"

  if systemctl --user is-active --quiet emacs.service; then
    systemctl --user restart emacs.service
  else
    systemctl --user enable --now emacs.service
  fi \
    && ok "emacs.service running with explicit --init-directory (emacsclient -t attaches instantly)" \
    || warn "Could not start emacs.service -- start manually: emacs --daemon --init-directory=$HOME/.config/emacs"
else
  warn "emacs.service not found -- emacsclient will cold-start Emacs each time"
fi

info "Launch: 'emacs' in a terminal (aliased in zsh/.zshrc to 'emacsclient -t -a \"\"')"
info "CLI: $DOOM_BIN doctor | $DOOM_BIN sync | $DOOM_BIN upgrade"

ok "Emacs setup complete"
