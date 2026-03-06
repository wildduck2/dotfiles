#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning system packages (pacman + yay)..."

# Clear pacman cache (keeping last 3 versions of each package)
echo "Clearing old pacman cache (keeping 3 versions)..."
sudo paccache -r -k3

# Remove unused/orphaned dependencies
orphans=$(pacman -Qdtq 2>/dev/null || true)
if [[ -n "$orphans" ]]; then
  echo "Removing orphaned dependencies..."
  echo "$orphans" | sudo pacman -Rns --noconfirm -
else
  echo "No orphaned dependencies found."
fi

# Clean yay cache
if command -v yay &>/dev/null; then
  echo "Cleaning yay cache..."
  yay -Sc --noconfirm
fi

echo "System cleanup complete!"
