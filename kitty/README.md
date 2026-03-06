# Kitty Terminal Configuration

A minimal kitty terminal setup styled to match the terminator config, using Catppuccin Mocha colors on a TokyoNight background.

## Requirements

- **[Kitty](https://sw.kovidgoyal.net/kitty/)** >= 0.35
- **[JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)** (ttf-jetbrains-mono-nerd on Arch)

## Quick Start

```bash
cd ~/dotfiles

# Install dependencies
./kitty/setup.sh

# Symlink config via stow
stow kitty
```

## Configuration

### Font

- **Family**: JetBrainsMono Nerd Font
- **Style**: Bold Italic (all slots)
- **Size**: 14

### Color Scheme

Catppuccin Mocha palette with TokyoNight Storm background (`#1a1b26`).

| Element | Color |
|---------|-------|
| Background | `#1a1b26` |
| Foreground | `#cdd6f4` |
| Cursor | `#cdd6f4` block |
| Selection BG | `#f5e0dc` |
| URL | `#89b4fa` |

### Colors

| Color | Normal | Bright |
|-------|--------|--------|
| Black | `#1e1e2e` | `#585b70` |
| Red | `#f38ba8` | `#f38ba8` |
| Green | `#a6e3a1` | `#a6e3a1` |
| Yellow | `#f9e2af` | `#f9e2af` |
| Blue | `#89b4fa` | `#89b4fa` |
| Magenta | `#f5c2e7` | `#f5c2e7` |
| Cyan | `#94e2d5` | `#94e2d5` |
| White | `#bac2de` | `#a6adc8` |

### Window

- Borderless (no window decorations)
- 4px padding
- No close confirmation
- Layouts: tall, fat, stack

### Tab Bar

Powerline style with slanted separators.

### Keybindings

| Key | Action |
|-----|--------|
| `ctrl+shift+t` | New tab |
| `ctrl+shift+w` | Close tab |
| `ctrl+shift+right` | Next tab |
| `ctrl+shift+left` | Previous tab |
| `ctrl+shift+enter` | New window (split) |
| `ctrl+shift+n` | New OS window |
| `ctrl+shift+equal` | Increase font size |
| `ctrl+shift+minus` | Decrease font size |
| `ctrl+shift+0` | Reset font size |
| `ctrl+shift+c` | Copy |
| `ctrl+shift+v` | Paste |
| `ctrl+shift+f5` | Reload config |

### Other

- Audio bell disabled, visual bell (0.1s)
- 10000 line scrollback
- No scroll on keystroke
- Dynamic background opacity support
