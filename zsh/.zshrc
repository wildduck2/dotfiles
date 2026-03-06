# ~/.zshrc
# Interactive shell config (plugins, completions, keybinds, aliases, eval)

# Ensure completions path exists
mkdir -p "$HOME/.zsh/completions"
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then
  export FPATH="$HOME/.zsh/completions:$FPATH"
fi

# Oh My Zsh
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# Zinit bootstrap
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "${ZINIT_HOME:h}"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Zinit plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Zinit snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Completion
autoload -Uz compinit
compinit
zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# fzf
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
fi

# NVM
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi

# Deno env (if installed)
[[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"

# Bun completions (optional)
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Pyenv (only if installed)
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# Cargo env (optional; usually not needed if PATH set in .zshenv)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# fzf->nvim widget: Ctrl+f to pick a file/dir and open in nvim
fzf_nvim() {
  local selected
  selected=$(fd --max-depth 3 --hidden --exclude .git ~ | fzf --height 40% --inline-info)
  [[ -z "$selected" ]] && return 0
  if [[ -d "$selected" ]]; then
    cd "$selected" && nvim
  else
    nvim "$selected"
  fi
}
zle -N fzf_nvim
bindkey '^f' fzf_nvim
export PATH="$HOME/.local/bin:$PATH"
