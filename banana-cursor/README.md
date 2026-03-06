# Banana Cursor - Tokyo Night

[Banana Cursor](https://github.com/ful1e5/banana-cursor) (Blue variant) as the system cursor theme, chosen to match the Tokyo Night color palette.

## Why Banana-Blue?

The Banana-Blue variant uses `#64CDCD` (teal/cyan) which complements Tokyo Night's accent colors used across the rest of the dotfiles (kitty, i3, nvim, btop).

## Requirements

- **curl** (for downloading the release)
- **tar** with xz support

## Setup

```bash
cd ~/dotfiles

# Install cursor theme and stow config
./banana-cursor/setup.sh

# Or via the main setup
./setup.sh banana-cursor
```

## What it does

1. Downloads `Banana-Blue.tar.xz` from GitHub releases (v2.0.0)
2. Extracts to `~/.icons/Banana-Blue/`
3. Stows GTK3 settings (`~/.config/gtk-3.0/settings.ini`) and X resources (`~/.Xresources`)
4. Sets `~/.icons/default/cursors` symlink
5. Applies cursor via `xrdb` and `gsettings` (if available)

## Configuration

- **Theme**: Banana-Blue
- **Size**: 24px
- **Applied via**: GTK3 settings.ini, Xresources, default cursor symlink

## Supported sizes

16, 20, 22, 24, 28, 32, 40, 48, 56, 64, 72, 80, 88, 96
