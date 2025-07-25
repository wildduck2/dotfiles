#!/bin/sh

# Optional: fallback if i3lock-fancy is missing
if ! command -v i3lock-fancy >/dev/null 2>&1; then
    echo "i3lock-fancy not found! Falling back to plain i3lock..."
    i3lock -c 000000
    exit
fi

# Call i3lock-fancy
i3lock-fancy


