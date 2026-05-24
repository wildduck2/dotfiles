# zen-mode

`folke/zen-mode.nvim` -- distraction-free single-window mode. Lazy on the two
defined keymaps.

## Files

- `init.lua` -- spec; declares keys for lazy-loading; calls
  `require('plugins.ui.zen-mode.config').setup()`.
- `config.lua` -- `zen-mode.setup{}` plus two keymaps that reconfigure window
  width on the fly.

## Keymaps

| Key | Action |
| --- | --- |
| `<leader>zz` | "wide zen": 105-col window, line numbers visible, no wrap |
| `<leader>zZ` | "minimal zen": 80-col window, no numbers, no colorcolumn |

Both reconfigure zen-mode on each invocation before toggling, so widths and
display options always match.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `window.backdrop` | `0.95` | Shade level for hidden areas (0=black, 1=normal). |
| `window.width` | `120` | Default width; overridden per-keymap. |
| `window.height` | `1` | 1 = full height. |
| `window.options` | `{}` | Vim window-locals to apply inside zen. |
| `plugins.options.enabled` | `true` | Hide ruler/showcmd/laststatus. |
| `plugins.options.ruler` | `false` | -- |
| `plugins.options.showcmd` | `false` | -- |
| `plugins.options.laststatus` | `0` | Hide statusline. |
| `plugins.twilight.enabled` | `true` | Dim inactive code via Twilight (would require Twilight installed; omit this if not). |
| `plugins.gitsigns.enabled` | `false` | Keep gitsigns. Set `true` to disable in zen. |
| `plugins.tmux.enabled` | `false` | -- |
| `plugins.kitty.enabled` | `false` | Set true + `font = '+4'` for kitty font scaling. |
| `plugins.alacritty.enabled` | `false` | -- |
| `plugins.wezterm.enabled` | `false` | -- |
| `on_open` / `on_close` | no-ops | Hook here for custom side effects. |

## References

- https://github.com/folke/zen-mode.nvim
- twilight.nvim (optional companion): https://github.com/folke/twilight.nvim
