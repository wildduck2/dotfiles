#!/usr/bin/env bash
set -euo pipefail

# Install latest Neovim from GitHub releases (useful when pacman version is outdated)

INSTALL_DIR="${HOME}/.local"
BIN_DIR="${INSTALL_DIR}/bin"

if command -v nvim &>/dev/null; then
  CURRENT=$(nvim --version | head -1)
  echo "Current: $CURRENT"
  read -r -p "Reinstall/update Neovim? [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]] || exit 0
fi

echo "Downloading latest Neovim..."
TARBALL="/tmp/nvim-linux-x86_64.tar.gz"
curl -fsSL -o "$TARBALL" "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

echo "Extracting to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
tar -xzf "$TARBALL" -C "$INSTALL_DIR" --strip-components=1

rm -f "$TARBALL"

if command -v nvim &>/dev/null; then
  echo "Installed: $(nvim --version | head -1)"
else
  echo "Neovim installed to $BIN_DIR/nvim"
  echo "Make sure $BIN_DIR is in your PATH"
fi
