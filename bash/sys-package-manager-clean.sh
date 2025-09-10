#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Cleaning system packages (pacman + yay)..."

# Clear pacman cache (keeping last 3 versions of each package)
echo "🗑 Clearing old pacman cache (keeping 3 versions)..."
sudo paccache -r -k3

# Full cache clean (optional, uncomment if you want ALL cache removed)
# echo "🗑 Clearing all pacman cache..."
# sudo paccache -r -k0

# Remove unused/orphaned dependencies
if pacman -Qdtq >/dev/null 2>&1; then
  echo "🧹 Removing orphaned dependencies..."
  sudo pacman -Rns --noconfirm $(pacman -Qdtq)
else
  echo "✅ No orphaned dependencies found."
fi

# Clean yay cache
echo "🧽 Cleaning yay cache..."
yay -Sc --noconfirm

# Optimize pacman database
echo "🗄 Optimizing pacman database..."
sudo pacman-optimize && sync

echo "✅ System cleanup complete!"

