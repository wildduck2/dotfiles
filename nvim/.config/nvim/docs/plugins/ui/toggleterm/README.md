# toggleterm

`akinsho/toggleterm.nvim` -- managed terminal windows. Loaded eagerly (`version = '*'`).

## Files

- `init.lua` -- spec; `opts` returns the table from `config.lua`.
- `config.lua` -- the `opts` table.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `size` | `12` | Rows for horizontal / cols for vertical. |
| `hide_numbers` | `true` | No line numbers in the terminal. |
| `shade_terminals` | `true` | Dim background. |
| `insert_mappings` | `true` | Toggle binding works in insert. |
| `terminal_mappings` | `true` | Toggle binding works in terminal. |
| `start_in_insert` | `true` | -- |
| `persist_size` | `true` | Remember dimensions. |
| `persist_mode` | `true` | Remember insert/normal state. |
| `close_on_exit` | `true` | Auto-close when shell exits. |
| `clear_env` | `false` | Keep parent env. |
| `direction` | `'tab'` | `'horizontal'`, `'vertical'`, `'float'`, `'tab'`. |
| `shading_factor` | `-30` | Negative = darker shade. |
| `shading_ratio` | `-3` | Relative ratio. |
| `shell` | `vim.o.shell` | -- |
| `autochdir` | `false` | -- |
| `auto_scroll` | `true` | Scroll to bottom on output. |
| `winbar.enabled` | `false` | Hide winbar. |
| `winbar.name_formatter` | function | Renders `<id>:<display_name>` when winbar enabled. |
| `float_opts.border` | `'rounded'` | -- |
| `float_opts.winblend` | `0` | Opaque. |
| `float_opts.title_pos` | `'left'` | -- |
| `responsiveness.horizontal_breakpoint` | `0` | Disabled. |

## Keymaps / commands

No keymaps bound here. Default plugin commands:

- `:ToggleTerm` -- toggle a terminal.
- `:ToggleTerm direction=float` -- floating.
- `:TermExec cmd="..."` -- run a command in a terminal.
- `:ToggleTermSendCurrentLine`, `:ToggleTermSendVisualLines`.

Rustaceanvim's runnables use the toggleterm executor (see `plugins/lang/rust/`).

## References

- https://github.com/akinsho/toggleterm.nvim
