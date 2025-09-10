#!/usr/bin/env bash
set -euo pipefail

echo "🐍 Python environment cleanup starting..."

# ------------------------------------------------
# 1. Clean user-installed pip packages
# ------------------------------------------------
echo "📦 Collecting user-installed pip packages..."
user_packages=$(pip list --user --format=freeze | cut -d= -f1 || true)

if [ -n "$user_packages" ]; then
  echo "🗑 Removing user-installed pip packages..."
  echo "$user_packages" | xargs -r pip uninstall -y --user
else
  echo "✅ No user-installed pip packages found."
fi

# ------------------------------------------------
# 2. Clean global pip packages not managed by pacman
# ------------------------------------------------
echo "📦 Collecting global pip packages..."
global_pip=$(pip list --format=freeze | cut -d= -f1 || true)

echo "📦 Collecting system-managed Python packages (pacman)..."
system_packages=$(pacman -Qqe | grep '^python-' | sed 's/^python-//' || true)

# Filter: global pip packages that are NOT system ones
global_extra=$(comm -23 <(echo "$global_pip" | sort) <(echo "$system_packages" | sort))

if [ -n "$global_extra" ]; then
  echo "🗑 Removing global pip packages not managed by pacman..."
  echo "$global_extra" | sudo xargs -r pip uninstall -y --break-system-packages
else
  echo "✅ No extra global pip packages found."
fi

# ------------------------------------------------
# 3. Clean Python package managers (pip, setuptools, wheel)
# ------------------------------------------------
echo "📦 Ensuring pip, setuptools, and wheel come from pacman..."
for pkg in pip setuptools wheel; do
  if pacman -Q "python-$pkg" >/dev/null 2>&1; then
    echo "✅ python-$pkg managed by pacman."
  else
    echo "⚠️ $pkg not from pacman. Forcing reinstall via pacman..."
    sudo pacman -S --needed --noconfirm "python-$pkg"
  fi
done

echo "🎉 Python cleanup complete!"

