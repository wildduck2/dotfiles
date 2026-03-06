# Neofetch - BMOfetch (Duck Arch)

BMOfetch theme for neofetch — BMO ASCII art with a speech bubble, colorful Nerd Font icon labels, adapted for WildDuck Arch.

Based on [Chick2D/neofetch-themes (bmofetch)](https://github.com/Chick2D/neofetch-themes/tree/main/small/bmofetch) by [donatienLeray](https://github.com/donatienLeray).

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

BMO (from Adventure Time) with a speech bubble. The bubble text can be changed using the included `bmosay.sh` script:

```bash
# Change what BMO says
~/.config/neofetch/bmosay.sh "Quack!"

# Random line from a file
~/.config/neofetch/bmosay.sh -r quotes.txt
```

### Info Labels

| Icon | Label | Info |
|------|-------|------|
|  | USR | Users |
|  | OS | Distro |
|  | UP | Uptime |
| 󰍛 | CPU | CPU |
|  | GPU | GPU (dedicated) |
| 󰟖 | RAM | Memory (GiB, %) |
|  | MEM | Disk |

### Colors

Distro-based coloring with rainbow icon row at the bottom. ASCII art uses Arch blue/teal palette (`4 6 1 8 8 6`).

### Key Settings

- Architecture hidden for cleaner output
- CPU speed/cores hidden (brand only)
- Dedicated GPU only
- Memory in GiB with percentage
- Negative gap (`-44`) for overlapping BMO art with info text
