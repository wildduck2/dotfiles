#!/usr/bin/env bash
#
# System Analytics Setup
# Installs the data collector and dashboard generator as systemd user timers.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "System Analytics"
check_arch

# ── Dependencies ──────────────────────────────────────────────────────────
pkg_install jq lm_sensors

# ── Create data directory ─────────────────────────────────────────────────
DATA_DIR="$HOME/.local/share/sys-analytics/data"
mkdir -p "$DATA_DIR"
ok "Data directory: $DATA_DIR"

# ── Make scripts executable ───────────────────────────────────────────────
chmod +x "$SCRIPT_DIR/collect.sh"
chmod +x "$SCRIPT_DIR/dashboard.sh"

# ── Stow systemd units ───────────────────────────────────────────────────
stow_package sys-analytics

# ── Enable and start timers ──────────────────────────────────────────────
systemctl --user daemon-reload
systemctl --user enable --now sys-analytics.timer
systemctl --user enable --now sys-analytics-dash.timer
ok "Systemd timers enabled"

# ── Seed initial data ────────────────────────────────────────────────────
duck_wait "Collecting initial data sample" "~2s"
bash "$SCRIPT_DIR/collect.sh"
ok "Initial data point collected"

bash "$SCRIPT_DIR/dashboard.sh"
ok "Initial dashboard generated"

DASH_PATH="$HOME/.local/share/sys-analytics/dashboard.html"
ok "System Analytics setup complete"
info "Dashboard: $DASH_PATH"
info "Open in browser: xdg-open $DASH_PATH"
info "Data collected every 30s, dashboard regenerated every 5min"
