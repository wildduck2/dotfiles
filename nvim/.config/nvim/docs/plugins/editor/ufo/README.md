# ufo

`kevinhwang91/nvim-ufo` -- fancy folds powered by Treesitter or indent. Combined
with the global fold options set in `init` (foldcolumn = 1, foldlevel/start = 99,
foldenable = false) so files open fully unfolded but with the column ready.

## Files

- `init.lua` -- spec; loads on `BufReadPost`. Depends on `promise-async`.
  `init` block sets fold-related options. `config` calls
  `require('plugins.editor.ufo.config').setup()`.
- `config.lua` -- `ufo.setup{}` plus keymaps.

## Window / fold options set on lazy `init`

| Option | Value |
| --- | --- |
| `foldcolumn` | `'1'` |
| `foldenable` | `false` |
| `foldlevel` | `99` |
| `foldlevelstart` | `99` |
| `fillchars` | `fold: ,foldopen:-,foldsep:│,diff:` |

## Keymaps

| Key | Action |
| --- | --- |
| `<leader>fR` | `ufo.openAllFolds` |
| `<leader>fM` | `ufo.closeAllFolds` |
| `<leader>fm` | toggle fold under cursor (open if closed, close if open) |

These compose with the standard vim fold motions (`zo`, `zc`, `zM`, `zR`, etc).

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `open_fold_hl_timeout` | `150` | ms to keep highlight after opening a fold. |
| `close_fold_kinds_for_ft` | `{}` | per-filetype list of LSP fold kinds to close automatically; e.g. `{ default = { 'imports' } }`. |
| `provider_selector` | returns `{ 'treesitter', 'indent' }` | Try treesitter first, fall back to indent. Switch to `{ 'lsp', ... }` for LSP-driven folds. |

## References

- https://github.com/kevinhwang91/nvim-ufo
