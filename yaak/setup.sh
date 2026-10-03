#!/usr/bin/env bash
#
# Yaak Setup
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Yaak"
check_arch

# -- Packages --------------------------------------------------------------
# yaak-bin: API client (AUR). All official plugins (auth, importers, template
# functions, filters, themes) ship bundled with it.
# sqlite: used below to write settings, since Yaak keeps them in its database
pkg_install sqlite
aur_install yaak-bin

# -- CLI -------------------------------------------------------------------
# `yaak` CLI (npm @yaakapp/cli) drives the same database as the app. Installed
# with bun so it lands in ~/.bun/bin without sudo; ~/.local/bin is a stow link.
export PATH="$HOME/.bun/bin:$PATH"  # a fresh base install hasn't reloaded the shell yet
if command_exists bun; then
  info "Installing Yaak CLI"
  bun add -g @yaakapp/cli >/dev/null && ok "Yaak CLI installed ($(yaak --version 2>/dev/null))" \
    || warn "Yaak CLI install failed -- run: bun add -g @yaakapp/cli"
  # Teaches Claude Code, Cursor and other agents how to drive the CLI
  yaak agent install </dev/null >/dev/null 2>&1 && ok "Yaak agent skill installed" \
    || warn "Yaak agent skill install failed -- run: yaak agent install"
else
  warn "bun not found -- run ./setup.sh base, then rerun ./setup.sh yaak for the CLI"
fi

# -- Stow ------------------------------------------------------------------
# Launcher override that turns off WebKit's DMA-BUF renderer (blank window on NVIDIA)
stow_package yaak

# -- Settings --------------------------------------------------------------
DB="$HOME/.local/share/app.yaak.desktop/db.sqlite"
if pgrep -x yaak-app >/dev/null || pgrep -x yaak-app-client >/dev/null; then
  warn "Yaak is running -- close it and rerun ./setup.sh yaak to apply settings"
elif [[ ! -f "$DB" ]]; then
  warn "Yaak has no database yet -- open it once, close it, then rerun ./setup.sh yaak"
else
  sqlite3 "$DB" <<'SQL'
UPDATE settings SET
  appearance           = 'dark',
  theme_dark           = 'tokyo-night',
  theme_light          = 'tokyo-night-day',
  editor_font          = 'JetBrainsMono Nerd Font',
  editor_font_size     = 13,
  interface_font_size  = 14,
  editor_soft_wrap     = 1,
  colored_methods      = 1,
  hide_window_controls = 1,
  telemetry            = 0,
  updated_at           = strftime('%Y-%m-%d %H:%M:%f', 'now')
WHERE id = 'default';
SQL
  ok "Yaak settings applied (Tokyo Night, JetBrainsMono, no window controls under i3)"
fi

ok "Yaak setup complete"
