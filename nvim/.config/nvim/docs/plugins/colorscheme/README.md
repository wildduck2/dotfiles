# colorscheme

Single active theme: tokyonight (variant `night`). Other themes are commented
out in `init.lua` and can be swapped in.

## Files

- `init.lua` -- returns a list of color scheme specs; only tokyonight is active.

## Active theme

| Module | Plugin | Link |
| --- | --- | --- |
| tokyonight | `folke/tokyonight.nvim` (`tokyonight-night`) | [tokyonight](tokyonight/README.md) |

## Switching themes

`init.lua` contains commented-out specs for catppuccin, rose-pine, onedark,
kanagawa, and `xiyaowong/transparent.nvim`. To switch, comment the tokyonight
require line and uncomment the one you want, then `:Lazy sync`.
