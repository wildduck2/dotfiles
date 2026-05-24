# tokyonight

`folke/tokyonight.nvim` -- dark colorscheme. Loaded eagerly (`lazy = false`,
`priority = 1000`) so other plugins see the theme on startup.

## Files

- `init.lua` -- spec with `lazy = false`, `priority = 1000`, calls
  `require('plugins.colorscheme.tokyonight.config').setup()`.
- `config.lua` -- runs `require('tokyonight').setup()` with defaults, then
  `vim.cmd.colorscheme 'tokyonight-night'`.

## Configurable knobs

| Setting | Current | Notes |
| --- | --- | --- |
| variant | `tokyonight-night` | Other variants: `-storm`, `-day`, `-moon`. Change in `config.lua`. |
| `setup{}` args | empty | Pass `transparent`, `styles`, `on_colors`, `on_highlights` here if you want to override anything. |

## Keymaps / commands

None defined here.

## References

- https://github.com/folke/tokyonight.nvim
