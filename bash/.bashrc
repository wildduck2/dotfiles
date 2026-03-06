#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Console Ninja (optional)
[[ -d "$HOME/.console-ninja/.bin" ]] && export PATH="$HOME/.console-ninja/.bin:$PATH"

# Cargo / Rust (optional)
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
