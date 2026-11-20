#!/usr/bin/env bash
#
# Snapshots of the Minecraft world every 10 minutes, so a broken build or a lost chest can be undone, and
# "Playing Minecraft" on Discord while the game runs.
# Can be run standalone or called from the main setup.sh; safe to run again.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

header "Minecraft backups"
check_arch

pkg_install rsync xdotool
chmod +x "$SCRIPT_DIR/backup.py" "$SCRIPT_DIR/discord-presence.py"
stow_package minecraft

systemctl --user daemon-reload
systemctl --user enable --now minecraft-backup.timer
ok "minecraft-backup.timer enabled (every 10 minutes)"
systemctl --user enable --now minecraft-presence.service
ok "minecraft-presence.service enabled (Playing Minecraft on Discord)"
info "Snapshots: ~/.local/share/minecraft-backups/gentleduck"
