# ufo

`kevinhwang91/nvim-ufo` -- fancy folds powered by Treesitter or indent. Combined
with the global fold options set in `init` (foldcolumn = 1, foldlevel/start = 99,
foldenable = true) so files open fully unfolded but with the column ready.
`foldenable` must stay on: ufo computes no folds while it is off.

## Files

- `init.lua` -- spec; loads on `BufReadPost`. Depends on `promise-async`.
  `init` block sets fold-related options. `config` calls
  `require('plugins.editor.ufo.config').setup()`.
- `config.lua` -- `ufo.setup{}` plus keymaps.

## Window / fold options set on lazy `init`

| Option | Value |
| --- | --- |
| `foldcolumn` | `'1'` |
| `foldenable` | `true` |
| `foldlevel` | `99` |
| `foldlevelstart` | `99` |
| `fillchars` | `fold: ,foldopen:-,foldsep:│,diff:` |

## Keymaps

| Key | Action |
| --- | --- |
| `zR` | `ufo.openAllFolds` |
| `zM` | `ufo.closeAllFolds` |

The rest are the standard vim fold keys (`za` toggles the fold under the
cursor, `zo`, `zc`, etc). Folds are kept off `<leader>f`, since `<leader>f` is
Format and a mapping that is also a prefix fires early when typed fast.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `open_fold_hl_timeout` | `150` | ms to keep highlight after opening a fold. |
| `close_fold_kinds_for_ft` | `{}` | per-filetype list of LSP fold kinds to close automatically; e.g. `{ default = { 'imports' } }`. |
| `provider_selector` | returns `{ 'treesitter', 'indent' }` | Try treesitter first, fall back to indent. Switch to `{ 'lsp', ... }` for LSP-driven folds. |

## References

- https://github.com/kevinhwang91/nvim-ufo
