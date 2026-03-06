# Picom Compositor Configuration

Picom compositor config for i3, providing glass-like transparency and blur effects.

## Requirements

- **[picom](https://github.com/yshui/picom)** (compositor)
- **GLX support** ([mesa](https://mesa3d.org/), GPU drivers)
- An X11 window manager ([i3](https://i3wm.org/))

## Quick Start

```bash
cd ~/dotfiles
./picom/setup.sh
```

## Settings

### Backend
GLX backend with vsync and damage tracking enabled.

### Opacity
| Target | Opacity |
|--------|---------|
| Active windows | 90% |
| Inactive windows | 85% |
| Window frames | 90% |
| i3bar | 85% |
| Gnome screensaver | 75% |

### Blur
Dual kawase blur for a frosted glass effect.

| Setting | Value |
|---------|-------|
| Method | dual_kawase |
| Strength | 8 |
| Radius | 10 |

### Exclusions (100% opaque, no blur)
- Video players: mpv, vlc, YouTube (by window name)
- Image viewers: feh, sxiv, Gwenview
- Browsers with argb (commented out by default)

### Fading
| Setting | Value |
|---------|-------|
| Fade in step | 0.06 |
| Fade out step | 0.06 |
| Fade delta | 5ms |

### Other
- Shadows disabled (clean glass look)
- Rounded corner detection enabled
- Client opacity detection enabled
- Dock windows excluded from blur
