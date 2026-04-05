#!/bin/bash
# Output current song details via playerctl

status=$(playerctl status 2>/dev/null)

if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    if [[ -n "$title" ]]; then
        echo "$title - $artist"
    else
        echo ""
    fi
else
    echo ""
fi
