#!/bin/bash
# Play system sounds via pw-play

theme="freedesktop"
mute=false

muteScreenshots=false
muteVolume=false

# Exit if system sounds are muted
if [[ "$mute" = true ]]; then
    exit 0
fi

# Choose the sound to play
if [[ "$1" == "--screenshot" ]]; then
    if [[ "$muteScreenshots" = true ]]; then
        exit 0
    fi
    soundoption="screen-capture.*"
elif [[ "$1" == "--volume" ]]; then
    if [[ "$muteVolume" = true ]]; then
        exit 0
    fi
    soundoption="audio-volume-change.*"
elif [[ "$1" == "--error" ]]; then
    if [[ "$muteScreenshots" = true ]]; then
        exit 0
    fi
    soundoption="dialog-error.*"
else
    echo "Available sounds: --screenshot, --volume, --error"
    exit 0
fi

# Set directory defaults for system sounds
if [ -d "/run/current-system/sw/share/sounds" ]; then
    systemDIR="/run/current-system/sw/share/sounds"
else
    systemDIR="/usr/share/sounds"
fi
userDIR="$HOME/.local/share/sounds"
defaultTheme="freedesktop"

# Prefer user's theme, fall back to system
sDIR="$systemDIR/$defaultTheme"
if [ -d "$userDIR/$theme" ]; then
    sDIR="$userDIR/$theme"
elif [ -d "$systemDIR/$theme" ]; then
    sDIR="$systemDIR/$theme"
fi

# Get the inherited theme
iTheme=$(cat "$sDIR/index.theme" 2>/dev/null | grep -i "inherits" | cut -d "=" -f 2)
iDIR="$sDIR/../$iTheme"

# Find the sound file and play it
sound_file=$(find -L "$sDIR/stereo" -name "$soundoption" -print -quit 2>/dev/null)
if ! test -f "$sound_file"; then
    sound_file=$(find -L "$iDIR/stereo" -name "$soundoption" -print -quit 2>/dev/null)
    if ! test -f "$sound_file"; then
        sound_file=$(find -L "$userDIR/$defaultTheme/stereo" -name "$soundoption" -print -quit 2>/dev/null)
        if ! test -f "$sound_file"; then
            sound_file=$(find -L "$systemDIR/$defaultTheme/stereo" -name "$soundoption" -print -quit 2>/dev/null)
            if ! test -f "$sound_file"; then
                exit 1
            fi
        fi
    fi
fi

pw-play "$sound_file" || paplay "$sound_file"
