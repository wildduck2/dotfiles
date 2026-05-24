# supermaven

`supermaven-inc/supermaven-nvim` -- AI inline completion. Lighter than Copilot,
no external login flow in this repo (Supermaven Free runs out of the box).

## Files

- `init.lua` -- spec; loads on `VeryLazy`. `opts` returns the table from
  `config.lua`.
- `config.lua` -- the `opts` table.

## Keymaps

Bound by Supermaven itself:

| Key | Action |
| --- | --- |
| `<Tab>` | accept full suggestion |
| `<C-]>` | clear current suggestion |
| `<C-j>` | accept next word only |

These conflict with snippet jumping if you bind LuaSnip to the same key --
LuaSnip is bound to `<C-k>`/`<C-l>`/`<C-h>` in `plugins/cmp/`, so no overlap.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `keymaps.accept_suggestion` | `'<Tab>'` | -- |
| `keymaps.clear_suggestion` | `'<C-]>'` | -- |
| `keymaps.accept_word` | `'<C-j>'` | Conflicts with `<C-j>` window-nav in normal mode; this binding is insert-mode only. |
| `ignore_filetypes` | `{}` | Add `{ markdown = true }` etc. to silence in specific buffers. |
| `disable_inline_completion` | `false` | Set true to hide ghost text. |
| `disable_keymaps` | `false` | Set true to define your own. |
| `condition` | returns `false` | Function -> bool; return true to disable per-buffer. |
| `color.cterm` | `244` | Grey ghost text. |
| `log_level` | `'info'` | `info`/`debug`/`warn`/`error`. |

## External setup

- Run `:SupermavenUseFree` to use the free tier, or `:SupermavenUsePro` if you
  have an account. First use opens an auth flow in your browser.
- `:SupermavenStop` / `:SupermavenStart` to control the daemon.
- `:SupermavenStatus` reports state.

## References

- https://github.com/supermaven-inc/supermaven-nvim
