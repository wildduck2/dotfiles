# Terminator Configuration

GTK-based terminal emulator with Catppuccin Mocha colors on a TokyoNight background.

## Requirements

- **terminator**
- **Berkeley Mono Trial** font (primary, proprietary -- must be manually installed)
- **JetBrainsMono Nerd Font** (fallback, installed via setup.sh)

## Quick Start

```bash
cd ~/dotfiles
./terminator/setup.sh
```

## Profiles

### Default Profile
| Setting | Value |
|---------|-------|
| Font | Berkeley Mono Trial Bold 14 |
| Background | `#1a1b26` (TokyoNight Storm) |
| Foreground | `#cdd6f4` (Catppuccin Mocha) |
| Cursor | `#cdd6f4` on `#0b0400` |
| Titlebar | Hidden |
| Scrollbar | Hidden |
| Bold | Disabled |
| Bell | Visual |

### New Profile
| Setting | Value |
|---------|-------|
| Font | JetBrainsMono Nerd Font Bold Italic 14 |
| Background | Transparent (96% opacity) |
| Cursor | Non-blinking, `#cdd6f4` on `#0b0400` |

## Color Palette (Catppuccin Mocha)

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

## Keybindings

| Key | Action |
|-----|--------|
| `Alt+^` | Close terminal |
| `Alt+&` | Close window |

## Window

- Borderless (no decorations)
- No scrollbar
- No scroll on keystroke
- Inactive window dim: 90%

## Font Installation

Berkeley Mono is a proprietary font. To install:

1. Download from https://berkeleymono.com/
2. Place `.ttf` files in `~/.local/share/fonts/`
3. Run `fc-cache -fv`
