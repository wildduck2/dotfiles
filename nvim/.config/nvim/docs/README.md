# Wildduck Neovim Config

Reference documentation for this Neovim setup. Every module folder under `lua/`
has a matching `README.md` here. Use the tree below to find a specific plugin
or setting.

## Top-level summary

- Plugin manager: `lazy.nvim` (bootstrapped in `lua/wild-duck/lazy.lua`).
- LSP install: `mason.nvim` + `mason-lspconfig` + `mason-tool-installer`. Every
  server listed in `plugins/lsp/lspconfig/config.lua` `M.servers` is auto
  installed, plus `sqlfluff`.
- Format on save: `conform.nvim` (see `plugins/conform/`). LSP fallback when
  no formatter is available.
- Lint on save and on InsertLeave: `nvim-lint` (see `plugins/lsp/lint/`).
  Linter is skipped when its binary is not in PATH.
- Treesitter: `nvim-treesitter` (main branch) plus `treesitter-modules.nvim`
  for highlight/indent/textobjects/incremental selection.
- Completion: `nvim-cmp` with `LuaSnip` for snippets. SQL buffers prepend
  `vim-dadbod-completion` as the top source.
- Fuzzy finder: `telescope.nvim` with `telescope-fzf-native` and
  `telescope-ui-select`.
- Colorscheme: `tokyonight-night`.
- AI completion: `supermaven-nvim` (Tab to accept).

## Where things live

- Editor settings: `wild-duck/set.lua`
- Global keymaps: `wild-duck/remap.lua`
- Lazy bootstrap: `wild-duck/lazy.lua`
- Plugin specs: `plugins/<category>/<module>/init.lua`
- Plugin configs: `plugins/<category>/<module>/config.lua`
- Custom filetype mappings: `filetype.lua`
- Plugin lockfile: `lazy-lock.json`

## Categories

| Category | What's there | Link |
| --- | --- | --- |
| Editor settings + global keymaps | options, leader keymaps, lazy bootstrap | [wild-duck](wild-duck/README.md) |
| Completion | nvim-cmp, LuaSnip, custom snippets | [plugins/cmp](plugins/cmp/README.md) |
| Colorscheme | tokyonight | [plugins/colorscheme](plugins/colorscheme/README.md) |
| Formatting | conform.nvim and per-filetype formatters | [plugins/conform](plugins/conform/README.md) |
| Editor enhancements | comment, surround, undotree, folds, AI, indent guides | [plugins/editor](plugins/editor/README.md) |
| Fun extras | hacker, randiverse, cellular-automaton, Discord presence | [plugins/fun](plugins/fun/README.md) |
| Git | fugitive, gitsigns | [plugins/git](plugins/git/README.md) |
| Language tooling | treesitter, rust, dadbod, markdown, package-info, autotag, clangd | [plugins/lang](plugins/lang/README.md) |
| LSP and diagnostics | lspconfig, lazydev, lint, trouble, todo-comments, inlay hints, outline, **dap** | [plugins/lsp](plugins/lsp/README.md) |
| Navigation | telescope, harpoon, tmux navigator | [plugins/navigation](plugins/navigation/README.md) |
| Tools | silicon code screenshots | [plugins/tools](plugins/tools/README.md) |
| UI | lualine, nvim-tree, which-key, snacks, toggleterm, zen-mode | [plugins/ui](plugins/ui/README.md) |

## How to add a new plugin

1. Create `lua/plugins/<category>/<module>/init.lua` returning a lazy spec.
2. If config is non-trivial, put it in `lua/plugins/<category>/<module>/config.lua`
   exporting a `setup()` or `opts` table; require it from `init.lua`.
3. Add the require in the category's `init.lua` so lazy picks it up.
4. Add a `docs/.../README.md` mirroring the new folder.
