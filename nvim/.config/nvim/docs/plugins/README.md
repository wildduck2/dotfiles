# Plugins

Lazy specs live under `lua/plugins/<category>/<module>/`. Every category folder
has an `init.lua` that returns the list of child specs, so lazy autoloads
everything by virtue of `require('lazy').setup('plugins', ...)` in
`wild-duck/lazy.lua`.

| Category | Description | Link |
| --- | --- | --- |
| cmp | nvim-cmp completion + LuaSnip + snippets | [cmp](cmp/README.md) |
| colorscheme | Theme (tokyonight) | [colorscheme](colorscheme/README.md) |
| conform | Formatter engine and per-language formatters | [conform](conform/README.md) |
| editor | Comment, surround, AI, indent guides, undotree, folds | [editor](editor/README.md) |
| fun | Discord presence, hacker, random data, cellular automaton | [fun](fun/README.md) |
| git | fugitive + gitsigns | [git](git/README.md) |
| lang | Treesitter, Rust, dadbod SQL stack, markdown, etc. | [lang](lang/README.md) |
| lsp | lspconfig, lazydev, lint, trouble, todo-comments, outline, inlay hints | [lsp](lsp/README.md) |
| navigation | telescope, harpoon, tmux navigator | [navigation](navigation/README.md) |
| tools | silicon code screenshots | [tools](tools/README.md) |
| ui | lualine, nvim-tree, which-key, snacks, toggleterm, zen-mode | [ui](ui/README.md) |
