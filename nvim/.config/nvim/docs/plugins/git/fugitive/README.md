# fugitive

`tpope/vim-fugitive` -- the Git wrapper. Loaded eagerly (`lazy = false`).

## Files

- `init.lua` -- spec; binds the global `<leader>gs` keymap, calls
  `require('plugins.git.fugitive.config').setup()`.
- `config.lua` -- defines a `FileType fugitive` autocmd that adds
  fugitive-buffer-only keymaps.

## Keymaps

Global:

| Key | Action |
| --- | --- |
| `<leader>gs` | `:Git` (open fugitive status window) |

Buffer-local (only inside fugitive buffers, group `wildduck_fugitive`):

| Key | Action |
| --- | --- |
| `<leader>p` | `git push` |
| `<leader>P` | `git pull` |
| `<leader>Pr` | `git pull --rebase` |
| `<leader>Pn` | `git pull --no-rebase` |
| `<leader>t` | `:Git push -u origin ` (prompts for branch name) |

`<leader>p` in normal global scope is the paste-without-yank in `remap.lua`;
inside fugitive's status window it's overridden to push.

## Commands

Plain fugitive commands: `:Git`, `:Gwrite`, `:Gread`, `:Gdiffsplit`, `:Gblame`,
`:Gclog`, `:Gedit`. None are bound to keymaps here beyond `<leader>gs`.

## References

- https://github.com/tpope/vim-fugitive
