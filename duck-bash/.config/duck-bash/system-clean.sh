#!/usr/bin/env bash
set -euo pipefail

echo "🧹 System Cleanup Starting..."

# ------------------------------------------------
# 1. Pacman & Yay cache cleanup
# ------------------------------------------------
echo "📦 Cleaning pacman cache (keeping last 3 versions)..."
sudo paccache -r -k3

echo "📦 Cleaning yay cache..."
yay -Sc --noconfirm || true

# ------------------------------------------------
# 2. Remove orphaned packages
# ------------------------------------------------
if pacman -Qdtq >/dev/null 2>&1; then
  echo "🗑 Removing orphaned dependencies..."
  sudo pacman -Rns --noconfirm $(pacman -Qdtq)
else
  echo "✅ No orphaned packages."
fi

# ------------------------------------------------
# 3. Clear journal logs
# ------------------------------------------------
echo "📰 Cleaning journal logs (keeping 7 days)..."
sudo journalctl --vacuum-time=7d

# ------------------------------------------------
# 4. Clear system temporary files
# ------------------------------------------------
echo "🧾 Clearing system temporary files..."
sudo systemd-tmpfiles --clean
sudo rm -rf /tmp/* /var/tmp/* || true

# ------------------------------------------------
# 5. Clean pip, npm, yarn caches
# ------------------------------------------------
if command -v pip &>/dev/null; then
  echo "🐍 Cleaning pip cache..."
  pip cache purge || true
fi

if command -v npm &>/dev/null; then
  echo "📦 Cleaning npm cache..."
  npm cache clean --force || true
fi

if command -v yarn &>/dev/null; then
  echo "📦 Cleaning yarn cache..."
  yarn cache clean || true
fi

# ------------------------------------------------
# 6. Clean thumbnails & tmp
# ------------------------------------------------
echo "🖼 Clearing thumbnails..."
rm -rf ~/.cache/thumbnails/*

echo "🗑 Clearing /tmp..."
sudo rm -rf /tmp/* || true

# ------------------------------------------------
# 7. Optimize pacman database
# ------------------------------------------------
echo "🗄 Optimizing pacman database..."
sudo pacman-optimize && sync

echo "✅ System Cleanup Complete!"

