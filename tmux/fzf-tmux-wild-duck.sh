#!/usr/bin/env bash

#NOTE: this script is for use in tmux sessions
if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/ -mindepth 1 -maxdepth 2 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

tmux neww -n $selected_name -c $selected
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    exit 0
fi

# #NOTE: if you want it to be session instead
# if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
#     # tmux new-session -s $selected_name -c $selected
#     exit 0
# fi
# if ! tmux has-session -t=$selected_name 2> /dev/null; then
#     tmux new-session -ds $selected_name -c $selected
# fi
#
# tmux switch-client -t $selected_name

