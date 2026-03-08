# ~/.zshenv
# Environment variables and PATH only (runs for every zsh, even non-interactive)

# Oh My Zsh location
export ZSH="$HOME/.oh-my-zsh"

# Zinit
export ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

# Editors / basics
export EDITOR="nvim"
export LANG="${LANG:-en_US.UTF-8}"

# NVM
export NVM_DIR="$HOME/.nvm"

# Bun
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# Deno (optional, if you actually use it)
export DENO_INSTALL="$HOME/.deno"
[[ -d "$DENO_INSTALL/bin" ]] && export PATH="$DENO_INSTALL/bin:$PATH"

# Cargo (Rust)
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
[[ -d "$CARGO_HOME/bin" ]] && export PATH="$CARGO_HOME/bin:$PATH"

# Cursor theme
export XCURSOR_THEME="Banana-Blue"
export XCURSOR_SIZE=24

# User local bins
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
