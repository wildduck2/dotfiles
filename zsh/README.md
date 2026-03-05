# ZSH Configuration

ZSH shell setup with Oh My Zsh, Zinit plugin manager, fzf integration, and zoxide smart navigation.

## Requirements

- **zsh**
- **fzf** (fuzzy finder -- shell integration, fzf-tab, Ctrl+f widget)
- **zoxide** (smart cd replacement)
- **git** (Oh My Zsh, Zinit, git plugin)
- **curl** (Oh My Zsh and NVM installers)
- **neovim** (optional -- `vim` alias and `Ctrl+f` widget open files in nvim)

## Quick Start

```bash
cd ~/dotfiles
./zsh/setup.sh
```

The setup script installs zsh, fzf, zoxide, Oh My Zsh, Zinit, and NVM, then stows the config and sets zsh as the default shell.

## Files

| File | Purpose |
|------|---------|
| `.zshenv` | Environment variables and PATH (runs for every zsh instance) |
| `.zshrc` | Interactive shell config (plugins, completions, aliases, keybinds) |

## Plugin Managers

### Oh My Zsh
Framework providing the base theme and git plugin.

- **Theme**: robbyrussell
- **Plugin**: git

### Zinit
Fast plugin manager loading additional plugins and OMZ snippets.

**Plugins:**

| Plugin | Purpose |
|--------|---------|
| zsh-syntax-highlighting | Command syntax coloring |
| zsh-completions | Additional completion definitions |
| zsh-autosuggestions | Fish-like inline suggestions |
| fzf-tab | Replace default tab completion with fzf |

**OMZ Snippets:** git, sudo, archlinux, aws, kubectl, kubectx, command-not-found

## Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+p` | History search backward |
| `Ctrl+n` | History search forward |
| `Alt+w` | Kill region |
| `Ctrl+f` | fzf file/directory picker (opens selection in nvim) |

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

| Tool | How it's used |
|------|---------------|
| **fzf** | Shell keybindings via `eval "$(fzf --zsh)"`, fzf-tab completion |
| **zoxide** | Replaces `cd` via `eval "$(zoxide init --cmd cd zsh)"` |
| **NVM** | Node version manager, sourced from `$NVM_DIR/nvm.sh` |
| **pyenv** | Python version manager, `eval "$(pyenv init - zsh)"` |
| **deno** | Env sourced from `~/.deno/env` if present |
| **bun** | Completions sourced from `~/.bun/_bun` if present |
| **cargo** | Env sourced from `~/.cargo/env` if present |

## History

- 5000 entries in `~/.zsh_history`
- Shared across sessions
- Deduplication enabled
- Space-prefixed commands ignored
