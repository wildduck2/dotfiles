# dotfiles

Arch Linux development environment managed with [GNU Stow](https://www.gnu.org/software/stow/). Catppuccin Mocha theme with TokyoNight background across all tools.

## Install

```bash
git clone https://github.com/wildduck2/dotfiles ~/dotfiles
cd ~/dotfiles
./setup.sh
```

Install a single module:

```bash
./setup.sh nvim          # just neovim
./setup.sh kitty tmux    # multiple modules
./setup.sh --verify      # check all tools without installing
./setup.sh --dry-run     # preview what would be installed
./setup.sh --help        # show module descriptions
```

## What Gets Installed

The base setup installs these tools automatically:

| Tool | Method | More Info |
|------|--------|-----------|
| [yay](https://github.com/Jguer/yay) | Built from AUR | AUR helper for Arch Linux |
| [Rust](https://www.rust-lang.org/) | [rustup.rs](https://rustup.rs/) | Systems programming language |
| [Go](https://go.dev/) | pacman | Backend/systems programming |
| [Bun](https://bun.sh/) | curl installer | Fast JavaScript runtime & bundler |
| [Claude Code](https://claude.ai/code) | curl installer | AI-powered CLI assistant |

## Modules

| Module | Description | Key Config | More Info |
|--------|-------------|------------|-----------|
| [bash](bash/) | Bash fallback shell | `.bashrc`, `.bash_profile` | [GNU Bash](https://www.gnu.org/software/bash/) |
| [zsh](zsh/) | Primary shell (Oh My Zsh + Zinit + fzf + zoxide) | `.zshrc`, `.zshenv` | [Zsh](https://www.zsh.org/) |
| [tmux](tmux/) | Terminal multiplexer (TPM, vim-tmux-navigator, Tokyo Night) | `tmux.conf` | [tmux](https://github.com/tmux/tmux) |
| [kitty](kitty/) | GPU terminal (JetBrainsMono Bold Italic, Catppuccin colors) | `kitty.conf` | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| [terminator](terminator/) | GTK terminal (Berkeley Mono, Catppuccin colors) | `config` | [Terminator](https://gnome-terminator.org/) |
| [nvim](nvim/) | Neovim IDE (74 plugins, 16 LSPs, lazy.nvim) | `lua/` | [Neovim](https://neovim.io/) |
| [i3](i3/) | Window manager (Catppuccin, gaps, i3lock, picom) | `config` | [i3wm](https://i3wm.org/) |
| [picom](picom/) | Compositor (GLX, dual_kawase blur, glass opacity) | `picom.conf` | [Picom](https://github.com/yshui/picom) |
| [htop](htop/) | Process viewer | `htoprc` | [htop](https://htop.dev/) |
| [neofetch](neofetch/) | System info display | `config.conf` | [Neofetch](https://github.com/dylanaraps/neofetch) |
| [duck-bash](duck-bash/) | Utility scripts (cleanup, git, fzf-tmux, QR, yt-dlp) | `*.sh` | See [duck-bash/README.md](duck-bash/) |

## Desktop Apps (installed by i3 module)

| App | Source | More Info |
|-----|--------|-----------|
| [Google Chrome](https://www.google.com/chrome/) | AUR | Primary browser |
| [Firefox](https://www.mozilla.org/firefox/) | pacman | Secondary browser |
| [Discord](https://discord.com/) | pacman | Chat & voice |
| [OBS Studio](https://obsproject.com/) | AUR (obs-studio-tytan652) | Screen recording & streaming |
| [Yaak](https://yaak.app/) | AUR | API client (HTTP, GraphQL, WebSocket, gRPC) |

## Architecture

```
~/dotfiles/
  setup.sh              # Main installer (orchestrates all modules)
  scripts/helpers.sh    # Shared functions (pkg_install, stow, etc.)
  {module}/
    setup.sh            # Module installer (deps + stow)
    README.md           # Module documentation
    .config/{app}/      # Config files (symlinked by stow)
```

Each module is self-contained. `stow {module}` symlinks its contents into `$HOME`.

## Theme

Catppuccin Mocha palette on a TokyoNight Storm background (`#1a1b26`) shared across:

| App | Colors | Font |
|-----|--------|------|
| kitty | [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) | JetBrainsMono Nerd Font Bold Italic 14 |
| terminator | [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) | Berkeley Mono Trial Bold 14 |
| i3 bar | [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) | Berkeley Mono Trial 16 |
| i3lock | [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) | Berkeley Mono Trial / JetBrainsMono |
| nvim | Multiple (TokyoNight, Catppuccin, Rose Pine, etc.) | Terminal font |
| tmux | [Tokyo Night](https://github.com/janoamaral/tokyo-night-tmux) + [Catppuccin](https://github.com/catppuccin/tmux) | Terminal font |

## Neovim

74 plugins organized in `lua/plugins/` with the spec-per-directory pattern. Highlights:

- **LSP**: 16 servers auto-installed via [Mason](https://github.com/williamboman/mason.nvim) (Lua, Rust, TypeScript, Go, C/C++, etc.)
- **Completion**: [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) + [LuaSnip](https://github.com/L3MON4D3/LuaSnip) + [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
- **Formatting**: [conform.nvim](https://github.com/stevearc/conform.nvim) with format-on-save (stylua, prettier, biome, rustfmt, etc.)
- **Navigation**: [Telescope](https://github.com/nvim-telescope/telescope.nvim), [Harpoon](https://github.com/ThePrimeagen/harpoon), [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)
- **Git**: [Fugitive](https://github.com/tpope/vim-fugitive) + [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- **Treesitter**: 34 parsers with [text objects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)

See [nvim/README.md](nvim/) for the full plugin list and keybinding reference.

## Requirements

- **[Arch Linux](https://archlinux.org/)** (pacman)
- **[Nerd Font](https://www.nerdfonts.com/)** -- JetBrainsMono Nerd Font installed by setup.sh
- **[Berkeley Mono Trial](https://berkeleymono.com/)** (optional) -- proprietary font for i3/terminator, falls back to JetBrainsMono

## Key Bindings Quick Reference

### i3 (Mod = Alt) -- [i3 User Guide](https://i3wm.org/docs/userguide.html)

| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminal |
| `Mod+q` | Kill window |
| `Mod+d` | App launcher ([dmenu](https://tools.suckless.org/dmenu/)) |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+1-0` | Switch workspace |
| `Mod+x` | Lock screen ([i3lock-color](https://github.com/Raymo111/i3lock-color)) |
| `Mod+f` | Fullscreen |
| `Mod+Shift+r` | Restart i3 |

### tmux (Prefix = Ctrl+d) -- [tmux Wiki](https://github.com/tmux/tmux/wiki)

| Key | Action |
|-----|--------|
| `prefix+r` | Reload config |
| `prefix+h/j/k/l` | Navigate panes |
| `prefix+"` | Horizontal split |
| `prefix+\|` | Vertical split |
| `Ctrl+h/j/k/l` | Navigate panes (seamless with nvim via [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)) |
| `Shift+Left/Right` | Switch windows |

### Neovim (Leader = Space) -- [Neovim Docs](https://neovim.io/doc/user/)

| Key | Action |
|-----|--------|
| `<leader>sf` | Search files ([Telescope](https://github.com/nvim-telescope/telescope.nvim)) |
| `<leader>sg` | Search by grep |
| `<leader>pv` | Toggle file tree ([nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)) |
| `<leader>a` | Add to [Harpoon](https://github.com/ThePrimeagen/harpoon) |
| `gd` | Go to definition |
| `<leader>ca` | Code action |
| `<leader>f` | Format buffer ([conform.nvim](https://github.com/stevearc/conform.nvim)) |

See [nvim/README.md](nvim/) for the complete list.
