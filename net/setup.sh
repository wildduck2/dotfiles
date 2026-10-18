#!/usr/bin/env bash
#
# Network Setup (firewall + ssh)
# Can be run standalone or called from the main setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

LAN_SUBNET="192.168.1.0/24"

header "Network"
check_arch

# -- Packages --------------------------------------------------------------
pkg_install firewalld openssh

# -- Firewall --------------------------------------------------------------
# Devices on the home LAN reach every port (dev servers, Postgres, Drizzle);
# everything else still only gets ssh through the public zone
sudo systemctl enable --now firewalld.service
if sudo firewall-cmd --permanent --zone=trusted --query-source="$LAN_SUBNET" &>/dev/null; then
  ok "LAN $LAN_SUBNET already trusted"
else
  sudo firewall-cmd --permanent --zone=trusted --add-source="$LAN_SUBNET"
  ok "LAN $LAN_SUBNET added to trusted zone"
fi
sudo firewall-cmd --permanent --zone=public --add-service=ssh &>/dev/null || true
sudo firewall-cmd --reload >/dev/null

# -- SSH -------------------------------------------------------------------
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
stow_package net
chmod 600 "$SCRIPT_DIR/.ssh/config"
sudo systemctl enable --now sshd.service

# -- Clipboard from the Mac ------------------------------------------------
pkg_install xclip
systemctl --user daemon-reload
systemctl --user enable --now clip-from-mac.service
ok "Copies on the Mac reach this clipboard"

ok "Network setup complete"
