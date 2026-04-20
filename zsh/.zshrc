# ~/.zshrc
# Interactive shell config (plugins, completions, keybinds, aliases, eval)

# Ensure completions path exists
[[ -d "$HOME/.zsh/completions" ]] || mkdir -p "$HOME/.zsh/completions"
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then
  export FPATH="$HOME/.zsh/completions:$FPATH"
fi

# Zinit bootstrap
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "${ZINIT_HOME:h}"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Oh My Zsh (theme only — plugins handled by Zinit)
ZSH_THEME="robbyrussell"
plugins=()
source "$ZSH/oh-my-zsh.sh"

# Zinit plugins (turbo mode — deferred loading)
zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait lucid
zinit light zsh-users/zsh-completions
zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions
zinit ice wait lucid
zinit light Aloxaf/fzf-tab

# Zinit snippets (turbo mode)
zinit ice wait lucid
zinit snippet OMZP::git
zinit ice wait lucid
zinit snippet OMZP::sudo
zinit ice wait lucid
zinit snippet OMZP::archlinux
zinit ice wait lucid
zinit snippet OMZP::command-not-found

# Completion (use -C to skip rebuild if cache is fresh — saves ~100ms)
autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
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

# fzf (cache the output instead of eval on every shell)
if [[ -f "$HOME/.zsh/_fzf_cache.zsh" ]] && [[ "$HOME/.zsh/_fzf_cache.zsh" -nt "$(command -v fzf)" ]]; then
  source "$HOME/.zsh/_fzf_cache.zsh"
elif command -v fzf >/dev/null 2>&1; then
  fzf --zsh > "$HOME/.zsh/_fzf_cache.zsh" 2>/dev/null
  source "$HOME/.zsh/_fzf_cache.zsh"
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi

# zoxide (cache the output instead of eval on every shell)
if [[ -f "$HOME/.zsh/_zoxide_cache.zsh" ]] && [[ "$HOME/.zsh/_zoxide_cache.zsh" -nt "$(command -v zoxide)" ]]; then
  source "$HOME/.zsh/_zoxide_cache.zsh"
elif command -v zoxide >/dev/null 2>&1; then
  zoxide init --cmd cd zsh > "$HOME/.zsh/_zoxide_cache.zsh" 2>/dev/null
  source "$HOME/.zsh/_zoxide_cache.zsh"
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
fi

# NVM (lazy-loaded — sourcing nvm.sh on every shell adds ~200ms)
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  _nvm_lazy_load() {
    unset -f nvm node npm npx yarn 2>/dev/null
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  }
  nvm()  { _nvm_lazy_load; nvm "$@"; }
  node() { _nvm_lazy_load; node "$@"; }
  npm()  { _nvm_lazy_load; npm "$@"; }
  npx()  { _nvm_lazy_load; npx "$@"; }
  yarn() { _nvm_lazy_load; yarn "$@"; }
fi

# Deno env (if installed)
[[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"

# Bun completions (optional)
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Pyenv (lazy-loaded — eval on every shell adds ~100ms)
if [[ -d "$PYENV_ROOT/bin" ]]; then
  _pyenv_lazy_load() {
    unset -f pyenv python python3 pip pip3 2>/dev/null
    eval "$(pyenv init - zsh)"
  }
  pyenv()   { _pyenv_lazy_load; pyenv "$@"; }
  python()  { _pyenv_lazy_load; python "$@"; }
  python3() { _pyenv_lazy_load; python3 "$@"; }
  pip()     { _pyenv_lazy_load; pip "$@"; }
  pip3()    { _pyenv_lazy_load; pip3 "$@"; }
fi

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
export PATH="/usr/games:$PATH"

# opencode
export PATH=/home/wildduck/.opencode/bin:$PATH
