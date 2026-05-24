# snacks

`folke/snacks.nvim` -- folke's grab-bag of UI primitives. We only enable the
`indent` module here; `indent-blankline.nvim` owns scope guides (snacks
`indent.scope.enabled = false`).

## Files

- `init.lua` -- spec; `opts` returns the table from `config.lua`.
- `config.lua` -- the `opts` table.

## Why we use it

snacks' `indent` is a fast modern indent guide renderer. We pair it with
indent-blankline only because the latter handles scope highlighting better
for now; switch by enabling `scope` in this opts and disabling indent-blankline.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `indent.indent.enabled` | `true` | Master switch for guides. |
| `indent.indent.char` | bar glyph | -- |
| `indent.indent.only_scope` | `false` | -- |
| `indent.indent.only_current` | `false` | -- |
| `indent.indent.hl` | `'SnacksIndent'` | Replace with list of 8 highlight names for rainbow guides. |
| `indent.animate.enabled` | `false` | Animation off. |
| `indent.animate.style` | `'out'` | `'up_down'`, `'down'`, `'up'`. |
| `indent.animate.easing` | `'linear'` | -- |
| `indent.animate.duration.step` | `20` ms | -- |
| `indent.animate.duration.total` | `500` ms | -- |
| `indent.scope.enabled` | `false` | indent-blankline owns scope. |
| `indent.scope.char` | bar glyph | -- |
| `indent.scope.underline` | `false` | -- |
| `indent.chunk.enabled` | `false` | No box around the active block. |
| `indent.filter` | function | Skips special buftypes (help, terminal, etc.). |

## Other snacks modules (not enabled)

snacks also bundles `bufdelete`, `notifier`, `git`, `gitbrowse`, `lazygit`,
`zen`, `bigfile`, `quickfile`, `dashboard`, `picker`, etc. Enable by adding
top-level keys to `opts`, e.g. `notifier = { enabled = true }`.

## Keymaps / commands

None.

## References

- https://github.com/folke/snacks.nvim
