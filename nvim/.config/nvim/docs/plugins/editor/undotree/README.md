# undotree

`mbbill/undotree` -- visual tree of undo history. Pairs well with the
`undofile` setting in `wild-duck/set.lua` (undo persists across sessions in
`~/.config/nvim/.undo`).

## Files

- `init.lua` -- spec with `lazy = false`. Defines the `<leader>u` keymap in
  its own `config` block.
- `config.lua` -- also defines `<leader>u` (`vim.cmd.UndotreeToggle`). The two
  bindings target the same thing; the `init.lua` keymap wins because it's the
  one lazy.nvim actually invokes via `config`.

## Keymaps

| Key | Action |
| --- | --- |
| `<leader>u` | `:UndotreeToggle` |

## Commands

- `:UndotreeToggle`, `:UndotreeShow`, `:UndotreeHide`, `:UndotreeFocus`.

## Configurable knobs

`vim.g.undotree_*` options control panel placement and width. None are set in
this repo, so defaults apply (left panel, ~30 col wide).

## References

- https://github.com/mbbill/undotree
