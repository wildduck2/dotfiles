# ZSH Configuration

ZSH shell setup with Oh My Zsh, Zinit plugin manager, fzf integration, and zoxide smart navigation.

## Requirements

- **zsh**
- **fzf** (fuzzy finder)
- **zoxide** (smart cd replacement)
- **git** (for Oh My Zsh and Zinit installation)
- **curl** (for Oh My Zsh installer)

## Quick Start

```bash
cd ~/dotfiles
./zsh/setup.sh
```

## Files

| File | Purpose |
|------|---------|
| `.zshenv` | Environment variables and PATH (runs for every zsh instance) |
| `.zshrc` | Interactive shell config (plugins, completions, aliases, keybinds) |

## Plugin Managers

### Oh My Zsh
Framework providing the base theme and git plugin.

- **Theme**: robbyrussell
- **Plugins**: git

### Zinit
Fast plugin manager for additional plugins and OMZ snippets.

**Plugins:**
| Plugin | Purpose |
|--------|---------|
| zsh-syntax-highlighting | Command syntax coloring |
| zsh-completions | Additional completion definitions |
| zsh-autosuggestions | Fish-like autosuggestions |
| fzf-tab | Replace default completion with fzf |

**OMZ Snippets:**
git, sudo, archlinux, aws, kubectl, kubectx, command-not-found

## Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+p` | History search backward |
| `Ctrl+n` | History search forward |
| `Alt+w` | Kill region |
| `Ctrl+f` | fzf file/directory picker (opens in nvim) |

## Aliases

| Alias | Command |
|-------|---------|
| `ls` | `ls --color` |
| `vim` | `nvim` |
| `c` | `clear` |

## Environment Variables (.zshenv)

| Variable | Value |
|----------|-------|
| `EDITOR` | nvim |
| `ZSH` | ~/.oh-my-zsh |
| `ZINIT_HOME` | ~/.local/share/zinit/zinit.git |
| `NVM_DIR` | ~/.nvm |
| `BUN_INSTALL` | ~/.bun |
| `PYENV_ROOT` | ~/.pyenv |
| `DENO_INSTALL` | ~/.deno |
| `CARGO_HOME` | ~/.cargo |

PATH additions (if directories exist): `~/.local/bin`, `~/bin`, cargo, deno, pyenv, bun

## Tool Integrations

- **fzf**: Fuzzy finder shell integration (`eval "$(fzf --zsh)"`)
- **zoxide**: Smart cd (`eval "$(zoxide init --cmd cd zsh)"`) -- replaces `cd` command
- **nvm**: Node version manager (lazy loaded from `$NVM_DIR`)
- **pyenv**: Python version manager
- **deno/bun/cargo**: Environment sourced if installed

## History

- 5000 entries
- Shared across sessions
- Deduplication enabled
- Space-prefixed commands ignored
