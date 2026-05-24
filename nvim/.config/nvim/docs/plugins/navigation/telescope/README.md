# telescope

`nvim-telescope/telescope.nvim` -- fuzzy finder. Loaded on `VimEnter` so it's
ready immediately after startup.

## Files

- `init.lua` -- spec + dependencies (`plenary`, `telescope-fzf-native` built
  with make, `telescope-ui-select`, `nvim-web-devicons`).
- `config.lua` -- `telescope.setup{}`, extension loading, keymaps, and the
  `LiveGrepGitRoot` custom command.

## Extensions loaded

- `fzf` -- native fzf sorter (faster filtering). Conditional on `make` being
  available.
- `ui-select` -- replaces `vim.ui.select` with a telescope picker (dropdown
  theme).

## Keymaps

| Key | Picker |
| --- | --- |
| `<leader>sh` | help tags |
| `<leader>sk` | keymaps |
| `<leader>sf` | find files |
| `<leader>gf` | git files |
| `<leader>ss` | telescope builtin picker (list all pickers) |
| `<leader>sw` | grep word under cursor |
| `<leader>sg` | live grep |
| `<leader>sd` | diagnostics |
| `<leader>sr` | resume last picker |
| `<leader>s.` | oldfiles ("." for repeat) |
| `<leader><leader>` | buffers |
| `<leader>sa` | `:Telescope ast_grep` (requires the ast-grep extension to be loaded; not in this repo by default) |
| `<leader>sj` | `:Telescope dumb_jump` (requires dumb-jump extension) |
| `<leader>su` | open trouble in `document_diagnostics` mode |
| `<leader>/` | fuzzy-find within current buffer (dropdown theme, `winblend = 10`, no previewer) |
| `<leader>s/` | live grep restricted to open files |

Also: `<leader>n` (insert mode) and `<leader>tr` (normal mode) inside a
telescope picker send the result list to trouble (`trouble.sources.telescope.open`).

## Commands

- `:Telescope <picker>` -- run a picker manually.
- `:LiveGrepGitRoot` -- live grep restricted to the git root of the current
  file (falls back to cwd, prints a message). Defined in `config.lua`.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `defaults.borderchars` | unicode box-drawing | Rounded borders. |
| `defaults.mappings.i['<leader>n']` | `open_with_trouble` | Insert mode pipe to trouble. |
| `defaults.mappings.n['<leader>tr']` | `open_with_trouble` | Normal mode pipe to trouble. |
| `extensions['ui-select']` | dropdown theme | `vim.ui.select` picker. |
| `pickers` | `{}` | Per-picker overrides go here. |

LSP pickers (`lsp_references`, `lsp_implementations`, etc.) are bound from
`plugins/lsp/lspconfig/config.lua`'s `on_attach`, not here.

## How to add a picker keymap

1. Inside `config.lua`'s `setup()` add:

```lua
vim.keymap.set('n', '<leader>sx', builtin.<picker_name>, { desc = '...' })
```

Or for extension pickers, use `'<cmd>Telescope <ext> <picker><CR>'`.

## References

- https://github.com/nvim-telescope/telescope.nvim
- telescope-fzf-native.nvim: https://github.com/nvim-telescope/telescope-fzf-native.nvim
- telescope-ui-select.nvim: https://github.com/nvim-telescope/telescope-ui-select.nvim
