#!/bin/bash
# Toggle game mode: disable animations, blur, gaps for performance

notif="$HOME/.config/swaync/images/ja.png"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ]; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"

    hyprctl keyword "windowrule opacity 1 override 1 override 1 override, ^(.*)$"
    notify-send -e -u low -i "$notif" "Gamemode:" "enabled"
else
    hyprctl reload
    sleep 0.5
    ${SCRIPTSDIR}/Refresh.sh
    notify-send -e -u normal -i "$notif" "Gamemode:" "disabled"
fi
