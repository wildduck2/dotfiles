# i3 Window Manager Configuration

Catppuccin Mocha themed i3 setup with gaps, blurred lock screen, and vim-style keybindings.

## Prerequisites

### Arch Linux Packages

```sh
# Core - window manager and status
sudo pacman -S i3-wm i3status dmenu

# Lock screen dependencies
sudo pacman -S scrot imagemagick

# Lock screen (i3lock-color from AUR - required for themed lock screen)
yay -S i3lock-color

# Compositor (transparency, shadows, blur)
sudo pacman -S picom

# Wallpaper
sudo pacman -S feh

# Screenshot tool
sudo pacman -S flameshot

# System tray
yay -S trayer

# Desktop integration
sudo pacman -S network-manager-applet blueman polkit-gnome gnome-keyring

# Terminal
sudo pacman -S terminator

# Brightness control (laptops)
sudo pacman -S xorg-xbacklight
```

### One-liner Install

```sh
# Pacman packages
sudo pacman -S --needed i3-wm i3status dmenu scrot imagemagick picom feh flameshot \
    network-manager-applet blueman polkit-gnome gnome-keyring terminator xorg-xbacklight

# AUR packages
yay -S --needed i3lock-color trayer
```

## Installation

This directory is managed with [GNU Stow](https://www.gnu.org/software/stow/).
From the dotfiles root:

```sh
stow i3
```

This symlinks `i3/.config/i3/` into `~/.config/i3/`.

### Post-install

1. **Set your wallpaper** - replace `~/.config/i3/bgs/bg.jpg` with your preferred
   wallpaper, or add more images to the `bgs/` folder and update the config path.

2. **Set up picom** - ensure `~/.config/picom/picom.conf` exists. If not:
   ```sh
   mkdir -p ~/.config/picom
   cp /etc/xdg/picom.conf ~/.config/picom/picom.conf
   ```

3. **Font** - the config uses `Berkeley Mono Trial`. If you don't have it,
   change the `font` line in the config to your preferred monospace font:
   ```
   font pango:JetBrains Mono 12px
   ```

4. **Reload i3** - press `Mod1+Shift+r` to restart i3 and apply changes.

## File Structure

```
i3/.config/i3/
├── config          # Main i3 configuration
├── lock.sh         # Lock screen script (blurred screenshot + Catppuccin ring)
├── i3-blocks.sh    # Legacy wrapper, calls lock.sh
├── i3status.conf   # i3blocks status bar configuration
├── bgs/
│   └── bg.jpg      # Wallpaper (used by feh on startup)
└── readme.md       # This file
```

## Lock Screen

The lock screen (`lock.sh`) provides:

- **Blurred screenshot** of your current desktop as the background
- **Catppuccin Mocha themed** ring indicator showing lock state
- **Clock and date** display inside the ring
- **Color-coded feedback**: purple ring (idle), green (verifying), red (wrong password)

### How it works

1. Takes a screenshot with `scrot`
2. Blurs it using ImageMagick (fast scale-down, blur, scale-up method)
3. Launches `i3lock-color` with Catppuccin Mocha colors and clock overlay

### Lock screen keybindings

| Key | Action |
|-----|--------|
| `Mod+x` | Lock screen |
| `Mod+Ctrl+l` | Lock screen |

## Keybinding Reference

`$mod` is set to `Mod1` (Alt key). Change to `Mod4` for Super/Windows key.

### Essentials

| Key | Action |
|-----|--------|
| `$mod+Return` | Open terminal (terminator) |
| `$mod+q` | Kill focused window |
| `$mod+d` | Open dmenu launcher |

### Focus (vim-style)

| Key | Action |
|-----|--------|
| `$mod+h/j/k/l` | Focus left/down/up/right |

### Move Window

| Key | Action |
|-----|--------|
| `$mod+Shift+h/j/k/l` | Move window left/down/up/right |

### Layout

| Key | Action |
|-----|--------|
| `$mod+z` | Split horizontal |
| `$mod+v` | Split vertical |
| `$mod+f` | Fullscreen toggle |
| `$mod+s` | Stacking layout |
| `$mod+w` | Tabbed layout |
| `$mod+e` | Toggle split layout |
| `$mod+Shift+Space` | Toggle floating |
| `$mod+a` | Focus parent container |
| `$mod+r` | Enter resize mode (then h/j/k/l, Escape to exit) |

### Workspaces

| Key | Action |
|-----|--------|
| `$mod+1-0` | Switch to workspace 1-10 |
| `$mod+Shift+1-0` | Move container to workspace 1-10 |
| `$mod+m` | Move workspace to output left |

### Media / Hardware

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up 5% |
| `XF86AudioLowerVolume` | Volume down 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

### Custom

| Key | Action |
|-----|--------|
| `$mod+Shift+n` | Run resolution script |
| `$mod+Shift+Period` | Suspend system |
| `$mod+b` | Launch Zen browser |
| `Ctrl+Print` | Flameshot screenshot |
| `$mod+x` | Lock screen |
| `$mod+Ctrl+l` | Lock screen |

### i3 Management

| Key | Action |
|-----|--------|
| `$mod+Shift+c` | Reload config |
| `$mod+Shift+r` | Restart i3 in-place |
| `$mod+Shift+e` | Exit i3 (with confirmation) |

## Theme

Uses **Catppuccin Mocha** color palette throughout:
- Window borders: purple (mauve) for focused, gray for unfocused
- Bar: dark base with purple accent for active workspace
- Lock screen: matching purple ring indicator

## Troubleshooting

### Lock screen not working
- Verify `i3lock-color` is installed: `i3lock --version` (should show `i3lock-color`)
- If you have plain `i3lock` installed, it conflicts - remove it first: `sudo pacman -R i3lock`
- Verify `scrot` and `magick` are available: `which scrot magick`

### No wallpaper
- Check that `~/.config/i3/bgs/bg.jpg` exists
- Or change the path in the config's Autostart section

### Status bar blocks not showing
- The `i3status.conf` is an i3blocks config. If using plain i3status, the bar
  will use i3status's default format. To use i3blocks instead, install it
  (`sudo pacman -S i3blocks`) and change the bar's `status_command` to `i3blocks`.

### Transparency/compositor issues
- Ensure picom config exists at `~/.config/picom/picom.conf`
- Check picom logs: `picom --log-level=info --config ~/.config/picom/picom.conf`
