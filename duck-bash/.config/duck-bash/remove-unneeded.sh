#!/usr/bin/env bash
set -euo pipefail

# Packages that duplicate something we already use (kitty and Terminator are
# the terminals, pacsea the package TUI). Add to this list instead of uninstalling by hand.
UNNEEDED=(
  alacritty
  gnome-console
  xfce4-terminal
  pacseek
  pacui
)

installed=()
for pkg in "${UNNEEDED[@]}"; do
  pacman -Qq "$pkg" &>/dev/null && installed+=("$pkg")
done

if [[ ${#installed[@]} -eq 0 ]]; then
  echo "Nothing to remove, the system is already clean."
  exit 0
fi

echo "Removing: ${installed[*]}"
# -Rns also drops their now-unused dependencies and leftover system configs;
# pacman shows the full list and asks before doing anything
sudo pacman -Rns "${installed[@]}"
echo "Done."
