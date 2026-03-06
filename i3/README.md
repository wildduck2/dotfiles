# i3 Window Manager

Catppuccin Mocha themed i3 config with gaps, blurred lock screen, and smart multi-monitor startup.

## What's Included

- `config` — i3 config (Catppuccin Mocha colors, gaps, vim-style keybindings, autostart)
- `startup.sh` — auto-launch apps on login with monitor detection
- `lock.sh` — blurred screenshot lock screen using i3lock-color
- `i3status.conf` — status bar config
- `bgs/` — wallpaper directory (place `bg.jpg` here)

## Monitor Layout

`startup.sh` auto-detects external monitors via `xrandr`:

| Scenario | Behavior |
|----------|----------|
| External on the left | Chrome (ws 1) and Kitty (ws 2) go to external, Discord (ws 5) on primary |
| External on the right | Rotates the external monitor, then same layout as above |
| No external monitor | Everything stays on primary |

Apps are only launched if not already running.

## Packages

### Pacman

```sh
sudo pacman -S --needed i3-wm i3status dmenu scrot imagemagick picom feh flameshot \
    network-manager-applet blueman polkit-gnome gnome-keyring terminator kitty \
    xorg-xbacklight xdotool pavucontrol discord
```

### AUR (yay)

```sh
yay -S --needed i3lock-color trayer google-chrome
```

## Setup

Managed with [GNU Stow](https://www.gnu.org/software/stow/). From the dotfiles root:

```sh
stow i3
```

### Post-install

1. Replace `~/.config/i3/bgs/bg.jpg` with your wallpaper
2. Ensure `~/.config/picom/picom.conf` exists
3. The config uses `Berkeley Mono Trial` font — change to your preferred monospace font if needed
4. Press `Mod1+Shift+r` to restart i3

## Keybindings

`$mod` = `Mod1` (Alt). Change to `Mod4` for Super/Windows key.

### Essentials

| Key | Action |
|-----|--------|
| `$mod+Return` | Terminal (terminator) |
| `$mod+q` | Kill window |
| `$mod+d` | dmenu (.desktop apps) |
| `$mod+Shift+d` | dmenu (all binaries) |

### Focus & Move (vim-style)

| Key | Action |
|-----|--------|
| `$mod+h/j/k/l` | Focus left/down/up/right |
| `$mod+Shift+h/j/k/l` | Move window left/down/up/right |

### Layout

| Key | Action |
|-----|--------|
| `$mod+z` | Split horizontal |
| `$mod+v` | Split vertical |
| `$mod+f` | Fullscreen |
| `$mod+s/w/e` | Stacking / tabbed / split layout |
| `$mod+Shift+Space` | Toggle floating |
| `$mod+r` | Resize mode (h/j/k/l, Escape to exit) |

### Workspaces

| Key | Action |
|-----|--------|
| `$mod+1-0` | Switch to workspace 1-10 |
| `$mod+Shift+1-0` | Move container to workspace 1-10 |
| `$mod+m` | Move workspace to output left |

### Media

| Key | Action |
|-----|--------|
| Volume keys | Volume +/- 5%, mute toggle |
| Brightness keys | Brightness up/down |
| `Ctrl+Print` | Flameshot screenshot |

### Custom

| Key | Action |
|-----|--------|
| `$mod+x` / `$mod+Ctrl+l` | Lock screen |
| `$mod+Ctrl+p` | pavucontrol |
| `$mod+Ctrl+b` | Bluetooth manager |
| `$mod+b` | Zen browser |
| `$mod+Shift+Period` | Suspend |

### i3 Management

| Key | Action |
|-----|--------|
| `$mod+Shift+c` | Reload config |
| `$mod+Shift+r` | Restart i3 |
| `$mod+Shift+e` | Exit i3 |

## Lock Screen

Blurred screenshot with Catppuccin Mocha ring indicator:
- Takes screenshot with `scrot`, blurs with ImageMagick
- Color-coded ring: purple (idle), green (verifying), red (wrong)
- Clock and date inside the ring

## Theme

**Catppuccin Mocha** throughout:
- Window borders: purple (focused), gray (unfocused)
- Bar: dark base with purple active workspace
- Lock screen: matching purple ring
