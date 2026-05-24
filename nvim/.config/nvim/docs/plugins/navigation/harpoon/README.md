# harpoon

`ThePrimeagen/harpoon` (`harpoon2` branch) -- per-cwd pinned file list. Loaded
on `VeryLazy`.

## Files

- `init.lua` -- spec; depends on `plenary.nvim`. Calls
  `require('plugins.navigation.harpoon.config').setup()`.
- `config.lua` -- `harpoon:setup{}` plus keymaps.

## Keymaps

| Key | Action |
| --- | --- |
| `<leader>a` | add current file to the list |
| `<C-e>` | toggle the quick-menu (the harpoon list popup) |
| `<C-t>` | jump to slot 1 |
| `<C-u>` | jump to slot 2 |
| `<C-n>` | jump to slot 3 |
| `<C-s>` | jump to slot 4 |

Note: `<C-n>` is also the cmp next-suggestion in insert mode. The harpoon
binding is in normal mode only -- no conflict.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `settings.save_on_toggle` | `true` | Persist list when menu closes. |
| `settings.sync_on_ui_close` | `true` | Persist when UI window closes. |
| `settings.key` | function returning `vim.uv.cwd()` | Scope harpoon lists per cwd. |

Lists live under `vim.fn.stdpath('data') .. '/harpoon/harpoon.json'`.

## References

- https://github.com/ThePrimeagen/harpoon
