#!/bin/bash
# Kill and restart waybar, swaync

# Kill running processes
_ps=(waybar rofi swaync)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# Ensure waybar fully stops
killall -SIGUSR2 waybar 2>/dev/null

# Signal any remaining processes
for pid in $(pidof waybar rofi swaync); do
    kill -SIGUSR1 "$pid" 2>/dev/null
done

# Restart waybar
sleep 1
waybar &

# Relaunch and reload swaync
sleep 0.5
swaync > /dev/null 2>&1 &
swaync-client --reload-config

exit 0
