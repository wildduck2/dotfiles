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
```

## Modules

| Module | Description | Key Config |
|--------|-------------|------------|
| [bash](bash/) | Bash fallback shell | `.bashrc`, `.bash_profile` |
| [zsh](zsh/) | Primary shell (Oh My Zsh + Zinit + fzf + zoxide) | `.zshrc`, `.zshenv` |
| [tmux](tmux/) | Terminal multiplexer (TPM, vim-tmux-navigator, Tokyo Night) | `tmux.conf` |
| [kitty](kitty/) | GPU terminal (JetBrainsMono Bold Italic, Catppuccin colors) | `kitty.conf` |
| [terminator](terminator/) | GTK terminal (Berkeley Mono, Catppuccin colors) | `config` |
| [nvim](nvim/) | Neovim IDE (74 plugins, 16 LSPs, lazy.nvim) | `lua/` |
| [i3](i3/) | Window manager (Catppuccin, gaps, i3lock, picom) | `config` |
| [picom](picom/) | Compositor (GLX, dual_kawase blur, glass opacity) | `picom.conf` |
| [htop](htop/) | Process viewer | `htoprc` |
| [neofetch](neofetch/) | System info display | `config.conf` |
| [duck-bash](duck-bash/) | Utility scripts (cleanup, git, fzf-tmux, QR, yt-dlp) | `*.sh` |

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
| kitty | Catppuccin Mocha | JetBrainsMono Nerd Font Bold Italic 14 |
| terminator | Catppuccin Mocha | Berkeley Mono Trial Bold 14 |
| i3 bar | Catppuccin Mocha | Berkeley Mono Trial 16 |
| i3lock | Catppuccin Mocha | Berkeley Mono Trial / JetBrainsMono |
| nvim | Multiple (TokyoNight, Catppuccin, Rose Pine, etc.) | Terminal font |
| tmux | Tokyo Night + Catppuccin | Terminal font |

## Neovim

74 plugins organized in `lua/plugins/` with the spec-per-directory pattern. Highlights:

- **LSP**: 16 servers auto-installed via Mason (Lua, Rust, TypeScript, Go, C/C++, etc.)
- **Completion**: nvim-cmp + LuaSnip + friendly-snippets
- **Formatting**: conform.nvim with format-on-save (stylua, prettier, biome, rustfmt, etc.)
- **Navigation**: Telescope, Harpoon, nvim-tree
- **Git**: Fugitive + Gitsigns
- **Treesitter**: 34 parsers with text objects

See [nvim/README.md](nvim/) for the full plugin list and keybinding reference.

## Requirements

- **Arch Linux** (pacman)
- **Nerd Font** -- JetBrainsMono Nerd Font installed by setup.sh
- **Berkeley Mono Trial** (optional) -- proprietary font for i3/terminator, falls back to JetBrainsMono

## Key Bindings Quick Reference

### i3 (Mod = Alt)

| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminator |
| `Mod+q` | Kill window |
| `Mod+d` | App launcher (dmenu) |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+1-0` | Switch workspace |
| `Mod+x` | Lock screen |
| `Mod+b` | Open browser |
| `Mod+f` | Fullscreen |
| `Mod+Shift+r` | Restart i3 |

### tmux (Prefix = Ctrl+d)

| Key | Action |
|-----|--------|
| `prefix+r` | Reload config |
| `prefix+h/j/k/l` | Navigate panes |
| `prefix+"` | Horizontal split |
| `prefix+\|` | Vertical split |
| `Ctrl+h/j/k/l` | Navigate panes (seamless with nvim) |
| `Shift+Left/Right` | Switch windows |

### Neovim (Leader = Space)

| Key | Action |
|-----|--------|
| `<leader>sf` | Search files |
| `<leader>sg` | Search by grep |
| `<leader>pv` | Toggle file tree |
| `<leader>a` | Add to Harpoon |
| `gd` | Go to definition |
| `<leader>ca` | Code action |
| `<leader>f` | Format buffer |

See [nvim/README.md](nvim/) for the complete list.
