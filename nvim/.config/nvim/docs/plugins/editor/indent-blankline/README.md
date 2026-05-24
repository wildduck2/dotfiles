# indent-blankline

`lukas-reineke/indent-blankline.nvim` (main module `ibl`). Indent guides with
scope highlighting.

## Files

- `init.lua` -- spec + `opts`. Loads on `BufReadPost`. `main = 'ibl'` so lazy
  calls `require('ibl').setup(opts)`.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `indent.char` | `'|'` (vertical bar, U+2502) | Guide character. |
| `indent.tab_char` | `'|'` | Used for tab-indented blocks. |
| `scope.enabled` | `true` | Highlight the active scope's guide. |
| `scope.show_start` | `false` | Don't draw the open-scope underline. |
| `scope.show_end` | `false` | Don't draw the close-scope underline. |
| `scope.highlight` | `'IblScope'` | Highlight group; override in colorscheme. |
| `exclude.filetypes` | `help, NvimTree, Trouble, lazy, mason, toggleterm, dashboard, ''` | No guides in these buffers. |

snacks.nvim's `indent.scope` is intentionally disabled so this plugin owns
scope highlighting -- see `plugins/ui/snacks/config.lua`.

## Keymaps / commands

None.

## References

- https://github.com/lukas-reineke/indent-blankline.nvim
