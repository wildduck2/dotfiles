#!/usr/bin/env bash
set -euo pipefail

echo "System Cleanup Starting..."

# 1. Pacman & Yay cache cleanup
echo "Cleaning pacman cache (keeping last 3 versions)..."
if command -v paccache &>/dev/null; then
  sudo paccache -r -k3
else
  echo "paccache not found (install pacman-contrib)"
fi

if command -v yay &>/dev/null; then
  echo "Cleaning yay cache..."
  yay -Sc --noconfirm || true
fi

# 2. Remove orphaned packages
if pacman -Qdtq &>/dev/null; then
  echo "Removing orphaned dependencies..."
  sudo pacman -Rns --noconfirm $(pacman -Qdtq)
else
  echo "No orphaned packages."
fi

# 3. Clear journal logs
echo "Cleaning journal logs (keeping 7 days)..."
sudo journalctl --vacuum-time=7d

# 4. Clear system temporary files
echo "Clearing system temporary files..."
sudo systemd-tmpfiles --clean 2>/dev/null || true

# 5. Clean pip, npm, yarn caches
command -v pip &>/dev/null && { echo "Cleaning pip cache..."; pip cache purge || true; }
command -v npm &>/dev/null && { echo "Cleaning npm cache..."; npm cache clean --force || true; }
command -v yarn &>/dev/null && { echo "Cleaning yarn cache..."; yarn cache clean || true; }

# 6. Clean thumbnails
echo "Clearing thumbnails..."
rm -rf ~/.cache/thumbnails/* 2>/dev/null || true

echo "System Cleanup Complete!"
