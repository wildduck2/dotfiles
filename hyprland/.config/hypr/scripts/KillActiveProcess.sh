#!/bin/bash
# Kill the active window's process

active_pid=$(hyprctl activewindow | grep -o 'pid: [0-9]*' | cut -d' ' -f2)

if [ -n "$active_pid" ]; then
    kill "$active_pid"
fi
