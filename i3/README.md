# i3 Window Manager

Catppuccin Mocha themed i3 config with gaps, i3lock-color lock screen, and auto-start script.

## What's included

- `config` — i3 config (Catppuccin Mocha colors, gaps, keybindings, workspace assignments)
- `i3status.conf` — status bar config
- `lock.sh` — blur lock screen using i3lock-color (Mod+Ctrl+l / Mod+x)
- `startup.sh` — auto-launch apps on login (Chrome, Kitty, Discord on specific workspaces/monitors)
- `bgs/` — wallpaper directory (place `bg.jpg` here)

## Installed packages

### Pacman
i3-wm, i3status, dmenu, picom, feh, flameshot, imagemagick, pulseaudio, pavucontrol,
kitty, terminator, discord, firefox, xdotool, network-manager-applet, blueman,
v4l2loopback-dkms

### AUR (yay)
google-chrome, yaak-bin, obs-studio-tytan652, obs-pipewire-audio-capture,
trayer, i3lock-color, gnome-screensaver-no-watchdog

## Monitor layout

`startup.sh` auto-detects monitors via `xrandr`:
- External monitor → Workspace 1 (Chrome), Workspace 2 (Kitty)
- Primary monitor → Workspace 5 (Discord)

## Setup

```bash
./setup.sh        # from dotfiles root (includes base)
# or standalone:
bash i3/setup.sh
```
