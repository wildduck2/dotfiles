# outline

`hedyhli/outline.nvim` -- symbol tree sidebar. Lazy on `:Outline`.

## Files

- `init.lua` -- spec only, no custom config.

## Why we use it

Quick LSP symbol overview as a tree (functions, classes, fields). Alternative
to `<leader>cs` Trouble symbols panel.

## Commands

- `:Outline` -- toggle the sidebar.
- `:OutlineOpen`, `:OutlineClose`, `:OutlineFocus`.

## Keymaps

None bound here.

## Configurable knobs

We use defaults. To customise, pass `opts` in `init.lua`. Upstream supports
position (`left` / `right`), width, and symbol kind filtering.

## References

- https://github.com/hedyhli/outline.nvim
