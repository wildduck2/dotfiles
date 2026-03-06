#!/usr/bin/env bash
set -euo pipefail

# Screenshot tool for X11 (i3/Xorg) using flameshot
# For Hyprland, install grimblast and swappy separately

if ! command -v flameshot &>/dev/null; then
  echo "Error: flameshot is not installed. Install with: sudo pacman -S flameshot"
  exit 1
fi

SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SAVE_DIR"

print_help() {
  cat <<'EOF'
Usage: screenshot.sh <action>

Actions:
  p   Print all screens (full screenshot)
  s   Snip an area (interactive selection)
  m   Print focused monitor
  h   Show this help
EOF
}

case "${1:-h}" in
  p)  flameshot full -p "$SAVE_DIR" ;;
  s)  flameshot gui -p "$SAVE_DIR" ;;
  m)  flameshot screen -p "$SAVE_DIR" ;;
  h)  print_help ;;
  *)  print_help; exit 1 ;;
esac
