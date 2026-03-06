# Neofetch - Duck Arch

Custom neofetch config with a duck + Arch Linux ASCII art mashup, Catppuccin Mocha-inspired colors, and Nerd Font icons for info labels.

## Requirements

- **[Neofetch](https://github.com/dylanaraps/neofetch)**
- **[Nerd Font](https://www.nerdfonts.com/)** (for info label icons)

## Setup

```bash
cd ~/dotfiles

# Install dependencies and stow config
./neofetch/setup.sh

# Or via the main setup
./setup.sh neofetch
```

## Configuration

### ASCII Art

Custom duck-on-Arch logo (`duck_arch.txt`) — an Arch triangle with a duck sitting underneath, colored in blue and teal.

### Info Labels

Uses Nerd Font icons instead of text labels:

| Icon | Info |
|------|------|
|  | Distro |
|  | Kernel |
| 󰇄 | Host |
|  | Uptime |
|  | Packages |
|  | Shell |
|  | WM |
|  | Terminal |
|  | Terminal Font |
|  | CPU |
| 󰍛 | Memory |
| 󰊠 | GPU |
|  | Disk |
| 󰍹 | Resolution |

### Colors

Catppuccin Mocha-inspired palette:
- **Labels**: Blue (color 4)
- **Info text**: White (color 7)
- **Separators**: Teal (color 6)
- **Separator**: ` ➜ `
- **Underline**: `─`

### Extras

- CPU temperature shown in Celsius
- Memory shown in GiB with percentage
- Uptime in compact format (`2d 10h 3m`)
- Refresh rate shown with resolution
- Color blocks displayed at the bottom
