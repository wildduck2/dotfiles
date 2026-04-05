#!/bin/bash
# Clipboard manager using cliphist + rofi

rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
msg='CTRL DEL = delete entry | ALT DEL = wipe all'

# Check if rofi is already running
if pidof rofi > /dev/null; then
    pkill rofi
fi

while true; do
    result=$(
        rofi -i -dmenu \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -config "$rofi_theme" < <(cliphist list) \
            -mesg "$msg"
    )

    case "$?" in
        1)
            exit
            ;;
        0)
            case "$result" in
                "")
                    continue
                    ;;
                *)
                    cliphist decode <<<"$result" | wl-copy
                    exit
                    ;;
            esac
            ;;
        10)
            cliphist delete <<<"$result"
            ;;
        11)
            cliphist wipe
            ;;
    esac
done
