# ZSH Configuration

ZSH shell setup with Oh My Zsh, Zinit plugin manager, fzf integration, and zoxide smart navigation.

## Requirements

- **[zsh](https://www.zsh.org/)**
- **[fzf](https://github.com/junegunn/fzf)** (fuzzy finder -- shell integration, fzf-tab, Ctrl+f widget)
- **[fd](https://github.com/sharkdp/fd)** (fast find alternative -- used by fzf_nvim widget)
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** (smart cd replacement)
- **[git](https://git-scm.com/)** (Oh My Zsh, Zinit, git plugin)
- **[curl](https://curl.se/)** (Oh My Zsh and NVM installers)
- **[neovim](https://neovim.io/)** (optional -- `vim` alias and `Ctrl+f` widget open files in nvim)

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

### [Oh My Zsh](https://ohmyz.sh/)
Framework providing the base theme and git plugin.

- **Theme**: robbyrussell
- **Plugin**: git

### [Zinit](https://github.com/zdharma-continuum/zinit)
Fast plugin manager loading additional plugins and OMZ snippets.

**Plugins:**

| Plugin | Purpose |
|--------|---------|
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Command syntax coloring |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Additional completion definitions |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like inline suggestions |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replace default tab completion with fzf |

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
| **[fzf](https://github.com/junegunn/fzf)** | Shell keybindings via `eval "$(fzf --zsh)"`, fzf-tab completion |
| **[zoxide](https://github.com/ajeetdsouza/zoxide)** | Replaces `cd` via `eval "$(zoxide init --cmd cd zsh)"` |
| **[NVM](https://github.com/nvm-sh/nvm)** | Node version manager (lazy-loaded for fast shell startup) |
| **[pyenv](https://github.com/pyenv/pyenv)** | Python version manager, `eval "$(pyenv init - zsh)"` |
| **[Deno](https://deno.land/)** | Env sourced from `~/.deno/env` if present |
| **[Bun](https://bun.sh/)** | Completions sourced from `~/.bun/_bun` if present |
| **[Cargo](https://doc.rust-lang.org/cargo/)** | PATH set in `.zshenv` |

## History

- 5000 entries in `~/.zsh_history`
- Shared across sessions
- Deduplication enabled
- Space-prefixed commands ignored
