# markdown

Two plugins for markdown work.

## Files

- `init.lua` -- returns a list of two specs.

## Plugins

### obsidian.nvim

`epwalsh/obsidian.nvim` -- Obsidian vault integration. Lazy on `ft = 'markdown'`,
`version = '*'`. No custom config (would need a `workspaces` table to be useful
in practice).

### mdx.nvim

`davidmh/mdx.nvim` -- highlight + treesitter support for `.mdx`. Lazy on
`ft = 'mdx'`. `config = true` so the plugin's default setup runs.

## Keymaps

None defined here.

## External setup

- obsidian.nvim is dormant until you call `setup{ workspaces = { ... } }`.

## References

- obsidian.nvim: https://github.com/epwalsh/obsidian.nvim
- mdx.nvim: https://github.com/davidmh/mdx.nvim
