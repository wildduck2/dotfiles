# Tmux Configuration

Tmux setup with vim-style navigation, Tokyo Night / Catppuccin theming, and vim-tmux-navigator integration.

## Requirements

- **[tmux](https://github.com/tmux/tmux)** >= 3.0
- **[zsh](https://www.zsh.org/)** (set as default shell in tmux)
- **[xclip](https://github.com/astrand/xclip)** (clipboard support for tmux-yank)
- **bc** (version comparison in vim-tmux-navigator)
- **[TPM](https://github.com/tmux-plugins/tpm)** (Tmux Plugin Manager, auto-installed by setup.sh)

## Quick Start

```bash
cd ~/dotfiles
./tmux/setup.sh
```

## Prefix Key

The prefix is rebound from `Ctrl+b` to `Ctrl+d`.

## Keybindings

### Pane Navigation
| Key | Action |
|-----|--------|
| `prefix + h/j/k/l` | Select pane (vim-style) |
| `Ctrl+h/j/k/l` | Select pane (seamless with nvim splits) |
| `Alt+Arrow` | Select pane (arrow keys) |

### Window Navigation
| Key | Action |
|-----|--------|
| `Shift+Left/Right` | Previous/next window |
| `Alt+H/L` | Previous/next window |

### Splits
| Key | Action |
|-----|--------|
| `prefix + "` | Horizontal split (same path) |
| `prefix + \|` | Vertical split (same path) |

### Copy Mode (vi)
| Key | Action |
|-----|--------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy to system clipboard |
| `Ctrl+v` | Rectangle toggle |

### Other
| Key | Action |
|-----|--------|
| `prefix + r` | Reload config |
| `prefix + I` | Install TPM plugins |
| `prefix + D` | Open TODO.md in nvim |
| `Ctrl+f` | fzf tmux sessionizer |

## Plugins (via TPM)

| Plugin | Purpose |
|--------|---------|
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless pane/split nav between tmux and nvim |
| [catppuccin-tmux](https://github.com/catppuccin/tmux) | Catppuccin Mocha theme |
| [tokyo-night-tmux](https://github.com/janoamaral/tokyo-night-tmux) | Tokyo Night status bar |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | System clipboard integration |

## Settings

- Mouse support enabled
- Vi mode for copy
- Windows/panes start at index 1
- Auto-rename disabled
- 256-color terminal with true color override
- Clock mode in yellow
