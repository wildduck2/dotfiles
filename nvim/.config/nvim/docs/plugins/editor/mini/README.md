# mini

`echasnovski/mini.nvim` -- collection of small modules. We only activate two:
`mini.ai` and `mini.surround`.

## Files

- `init.lua` -- spec; loads on `BufReadPost`.
- `config.lua` -- runs `mini.ai.setup{}` and `mini.surround.setup{}`.

## mini.ai

Enhanced text objects. With our config `n_lines = 500`, searches up to 500
lines for the matching brackets/quotes/etc.

Default objects added by mini.ai (selection of useful ones):

| Object | Selects |
| --- | --- |
| `a)` / `i)`, `a]`, `a}` | brackets |
| `a"`, `a'`, `` a` `` | quote pairs |
| `at` / `it` | HTML/JSX tag |
| `af` / `if` | function call argument list |
| `aa` / `ia` | argument |

(Treesitter's textobjects in `plugins/lang/treesitter/` override some of these
with their own `af` / `if` / `ac` / `ic` / `aa` / `ia` keys -- treesitter wins
because it sets the keymaps directly.)

## mini.surround

| Key | Action |
| --- | --- |
| `sa<motion><char>` | add surrounding |
| `sd<char>` | delete surrounding |
| `sr<char><newchar>` | replace surrounding |
| `sf<char>` | find surrounding (forward) |
| `sF<char>` | find surrounding (backward) |
| `sh<char>` | highlight surrounding |

## Configurable knobs

| Module | Setting | Value |
| --- | --- | --- |
| `mini.ai` | `n_lines` | `500` |
| `mini.surround` | -- | defaults |

To enable more modules (mini.pairs, mini.statusline, etc.) add
`require('mini.<x>').setup()` to `config.lua`.

## References

- https://github.com/echasnovski/mini.nvim
