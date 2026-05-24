# wild-duck (editor core)

The pre-plugin core. Sets the leader key, all options that don't belong to a
plugin, the global keymaps, and bootstraps lazy.nvim.

`init.lua` (top of repo) requires `wild-duck`, which in turn loads `remap.lua`,
`set.lua`, then `lazy.lua` (which loads `lua/plugins/`).

## Files in this module

- `init.lua` -- requires `remap`, `set`, `lazy` in that order.
- `remap.lua` -- global keymaps and the yank-highlight autocmd.
- `set.lua` -- `vim.opt` / `vim.g` settings.
- `lazy.lua` -- bootstraps lazy.nvim and calls `require('lazy').setup('plugins', ...)`.

## Global options (`set.lua`)

| Option | Value | Note |
| --- | --- | --- |
| `vim.g.have_nerd_font` | `true` | Lets which-key, nvim-tree, lualine use icons. |
| `guicursor` | `''` | Block cursor everywhere. |
| `number`, `relativenumber` | true | Hybrid line numbers. |
| `mouse` | `'a'` | Mouse in all modes. |
| `showmode` | `false` | lualine shows the mode. |
| `breakindent` | true | Wrapped lines keep indentation. |
| `undodir` | `~/.config/nvim/.undo` | Persistent undo per file. |
| `undofile` | true | Save undo history. |
| `ignorecase`, `smartcase` | true | Smart case search. |
| `signcolumn` | `'yes'` | Always show signs column. |
| `updatetime` | `500` | Faster CursorHold for LSP highlight. |
| `timeoutlen` | `300` | Faster which-key popup. |
| `splitright`, `splitbelow` | true | New splits to right/below. |
| `list` | true | Show whitespace, plus `listchars eol:` arrow. |
| `inccommand` | `'split'` | Live preview substitutions. |
| `scrolloff` | `10` | 10 lines context around cursor. |
| `tabstop`, `softtabstop`, `shiftwidth` | `2` | 2-space indent. |
| `expandtab`, `smartindent` | true | Spaces, not tabs. |
| `swapfile`, `backup` | false | No swap or backup files. |
| `hlsearch`, `incsearch` | true | Highlight + incremental search. |
| `cursorline` | true | Highlight current line. |
| `termguicolors` | true | True color. |
| `winborder` | `'rounded'` | Rounded borders on all floats. |
| `isfname:append('@-@')` | -- | Allow @ in filenames. |
| `scrolljump` | `1` | Minimum scroll lines. |
| `textwidth`, `colorcolumn` | `100` | 100-column ruler. |
| `wrap`, `linebreak` | true | Soft-wrap at word boundaries. |

## Global keymaps (`remap.lua`)

Leader is `Space`. LocalLeader is `Space`.

| Mode | Keys | Action |
| --- | --- | --- |
| n | `<Esc>` | `:nohlsearch` |
| n | `[d` / `]d` | prev / next diagnostic (`vim.diagnostic.goto_prev`/`goto_next`) |
| n | `<leader>e` | open diagnostic float |
| n | `<leader>q` | open diagnostic in loclist |
| t | `<Esc><Esc>` | exit terminal mode |
| n | `<left>/<right>/<up>/<down>` | echo "use hjkl" (disabled arrows) |
| n | `<C-h>/<C-j>/<C-k>/<C-l>` | window focus left/down/up/right |
| x | `<leader>p` | paste over selection without yanking (`"_dP`) |
| n/v | `<leader>y` | yank to system clipboard |
| n | `<leader>Y` | yank line to system clipboard |
| n | `]q` / `[q` | next/prev quickfix item (zz centered) |
| i | `<C-c>` | acts as `<Esc>` |
| n | `<leader>mr` | `CellularAutomaton make_it_rain` |
| n | `]l` / `[l` | next/prev location list item |
| n/v | `<leader>d` | delete into blackhole (`"_d`) |
| n | `Q` | disabled (`<nop>`) |
| n | `<leader>S` | substitute word under cursor (prompts replacement) |
| n | `<leader>x` | `chmod +x %` on current file |
| n | `<leader>vpp` | edit `~/dotfiles/` |
| v | `J` / `K` | move selection down / up |
| n | `J` | join lines keeping cursor (`mzJ\`z`) |
| n | `<C-d>` / `<C-u>` | half-page jump centered |
| n | `n` / `N` | next/prev search centered |

## Autocmds

- `TextYankPost` -> `vim.highlight.on_yank()` (highlight yanked region briefly).
  Group `wild_duck_highlight`.

## Lazy bootstrap (`lazy.lua`)

Clones `folke/lazy.nvim` (stable branch) to `stdpath('data') .. '/lazy/lazy.nvim'`
if missing, prepends it to `rtp`, then `require('lazy').setup('plugins', { ui = ... })`.
The ui icons fall back to emoji when no nerd font.

## References

- lazy.nvim: https://github.com/folke/lazy.nvim
