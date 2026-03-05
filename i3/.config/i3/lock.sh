#!/usr/bin/env bash
# ============================================================================
# i3 Lock Screen - Catppuccin Mocha Theme
# ============================================================================
# Instant blur of current screen with clock and themed ring indicator.
# Only dependency: i3lock-color (AUR)
# ============================================================================

i3lock \
    --nofork \
    --ignore-empty-password \
    --blur 12 \
    --force-clock \
    --indicator \
    --radius 150 \
    --ring-width 8 \
    --inside-color 313244ff \
    --ring-color cba6f7ff \
    --line-color 00000000 \
    --separator-color 6c7086ff \
    --keyhl-color b4befeff \
    --bshl-color fab387ff \
    --insidever-color 313244ff \
    --ringver-color a6e3a1ff \
    --insidewrong-color 313244ff \
    --ringwrong-color f38ba8ff \
    --time-str "%H:%M" \
    --time-color cdd6f4ff \
    --time-size 64 \
    --time-font "Berkeley Mono Trial" \
    --time-pos "ix:iy-40" \
    --date-str "%A, %B %d" \
    --date-color a6adc8ff \
    --date-size 24 \
    --date-font "Berkeley Mono Trial" \
    --date-pos "tx:ty+50" \
    --verif-text "Verifying..." \
    --wrong-text "Wrong!" \
    --noinput-text "" \
    --verif-color a6e3a1ff \
    --wrong-color f38ba8ff \
    --layout-color cdd6f4ff \
    --pass-media-keys \
    --pass-volume-keys
