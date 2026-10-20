#!/usr/bin/env bash
# Locks with i3lock-color over the blurred wallpaper i3/setup.sh renders, in i3's Catppuccin Mocha colours.
# xss-lock passes --nofork, so it can hold a suspend or hibernate until the screen is locked.
pgrep -x i3lock >/dev/null && exit 0

base=1e1e2ecc
text=cdd6f4ff
dim=a6adc8ff
blue=89b4faff
green=a6e3a1ff
red=f38ba8ff
font="JetBrainsMono Nerd Font"

exec i3lock \
  --image "$HOME/.config/i3/bgs/bg-blurred.png" --fill \
  --ignore-empty-password --show-failed-attempts \
  --pass-media-keys --pass-volume-keys --pass-screen-keys \
  --clock --indicator --radius 130 --ring-width 10 \
  --inside-color "$base" --ring-color "$blue" --line-uses-inside \
  --insidever-color "$base" --ringver-color "$blue" \
  --insidewrong-color "$base" --ringwrong-color "$red" \
  --keyhl-color "$green" --bshl-color "$red" --separator-color 00000000 \
  --time-str "%H:%M" --time-font "$font" --time-size 56 --time-color "$text" \
  --date-str "%A, %d %B" --date-font "$font" --date-size 20 --date-color "$dim" \
  --verif-text "Checking" --verif-font "$font" --verif-size 22 --verif-color "$text" \
  --wrong-text "Wrong password" --wrong-font "$font" --wrong-size 20 --wrong-color "$red" \
  --noinput-text "" --lock-text "" --modif-color "$dim" \
  "$@"
