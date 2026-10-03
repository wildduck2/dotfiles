# Pacsea

[Pacsea](https://github.com/Firstp1ck/Pacsea), a Rust (ratatui) TUI for repo and AUR packages, themed Tokyo Night.

## Quick Start

```bash
cd ~/dotfiles
./pacsea/setup.sh
```

Run `pacsea`.

## What's Changed From the Defaults

| Setting | Value | Why |
|---------|-------|-----|
| `theme.conf` | Tokyo Night | Matches kitty, nvim, tmux and yazi |
| `installed_packages_mode` | `all` | The installed view lists every explicitly installed package, not only ones nothing depends on |
| `skip_preflight` | `false` | Show what a remove or install touches (reverse deps, services, files) before it runs |
| `fuzzy_search` | `true` | fzf-style matching in search |
| `aur_helper` | `yay` | The AUR helper this system uses |
| `privilege_tool` | `sudo` | No doas here |

Keys are the defaults; press `?` or `F1` inside Pacsea for the full list.

Pacsea writes logs, caches and lists into `~/.config/pacsea` too, so `setup.sh` links only the two config files into that folder instead of the whole directory.
