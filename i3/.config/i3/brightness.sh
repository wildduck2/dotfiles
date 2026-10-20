#!/usr/bin/env bash
# Steps the screen's backlight by a share of its range: brightness.sh +5 or -5, in percent. Written through
# logind, which lets the session's own user set it without root. The kernel's own AMD backlight is preferred:
# the NVIDIA firmware one this laptop also offers refuses every write.
set -euo pipefail

dev=""
for candidate in /sys/class/backlight/*; do
  [[ -e $candidate ]] || continue
  dev=$candidate
  [[ $(basename "$candidate") == amdgpu* ]] && break
done
[[ -n $dev ]] || exit 0

max=$(<"$dev/max_brightness")
next=$(( $(<"$dev/brightness") + max * ${1:-+5} / 100 ))
# Never fully dark: a black screen leaves nothing to find the key by.
(( next < 1 )) && next=1
(( next > max )) && next=$max
busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session \
  SetBrightness ssu backlight "$(basename "$dev")" "$next"
