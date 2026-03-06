#!/usr/bin/env bash
set -euo pipefail

#NOTE: this script is for use in tmux sessions
if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/ -mindepth 1 -maxdepth 2 -type d | fzf --height 40% --inline-info)
fi

if [[ -z "$selected" ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux || true)

tmux neww -n "$selected_name" -c "$selected"
if [[ -z "${TMUX:-}" ]] && [[ -z "$tmux_running" ]]; then
    exit 0
fi

