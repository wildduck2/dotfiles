# trouble

`folke/trouble.nvim` -- diagnostics / LSP results / quickfix viewer. Loaded
on `VeryLazy`.

## Files

- `init.lua` -- spec; defines five keymaps directly in its `config` block,
  then calls `require('plugins.lsp.trouble.config').setup()`.
- `config.lua` -- runs `trouble.setup{}` with our layout, action keys, and
  appearance settings.

## Keymaps (defined in `init.lua`)

| Key | Action |
| --- | --- |
| `<leader>xx` | `Trouble diagnostics toggle` (workspace) |
| `<leader>xX` | `Trouble diagnostics toggle filter.buf=0` (current buffer) |
| `<leader>cs` | `Trouble symbols toggle focus=false` |
| `<leader>cl` | `Trouble lsp toggle focus=false win.position=right` (defs / refs) |
| `<leader>xL` | `Trouble loclist toggle` |
| `<leader>xQ` | `Trouble qflist toggle` |

Telescope also forwards results to Trouble via the mappings in
`plugins/navigation/telescope/config.lua` (insert mode `<leader>n`, normal
mode `<leader>tr`).

## Action keys inside Trouble window

| Key | Action |
| --- | --- |
| `q` | close |
| `<esc>` | cancel |
| `r` | refresh |
| `<cr>` / `<tab>` / dbl-click | jump |
| `<c-x>` | open in horizontal split |
| `<c-v>` | open in vertical split |
| `<c-t>` | open in new tab |
| `o` | jump and close |
| `m` | toggle mode (workspace / document) |
| `s` | cycle severity filter |
| `P` | toggle preview |
| `K` | hover |
| `p` | preview |
| `c` | open URL from diagnostic code |
| `zM/zm` | close folds |
| `zR/zr` | open folds |
| `zA/za` | toggle fold |
| `j`/`k` | next / previous |
| `?` | help |

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `position` | `'bottom'` | `'top'`, `'left'`, `'right'`. |
| `height` | `10` | Rows when bottom/top. |
| `width` | `50` | Cols when left/right. |
| `mode` | `'workspace_diagnostics'` | Default starting mode. |
| `severity` | `nil` | nil = all severities. Filter with `vim.diagnostic.severity.WARN` etc. |
| `fold_open`/`fold_closed` | nerd-font glyphs | -- |
| `group` | `true` | Group by file. |
| `padding` | `true` | -- |
| `cycle_results` | `true` | Wrap navigation. |
| `multiline` | `true` | Allow multi-line messages. |
| `indent_lines` | `true` | Tree indent guides. |
| `win_config.border` | `'rounded'` | -- |
| `auto_open` | `false` | Don't pop open automatically. |
| `auto_close` | `false` | Don't close on empty results. |
| `auto_preview` | `true` | Inline preview of selected item. |
| `auto_fold` | `false` | -- |
| `auto_jump` | `{ 'lsp_definitions' }` | Auto-jump for these result modes. |
| `include_declaration` | `{ 'lsp_references', 'lsp_implementations', 'lsp_definitions' }` | -- |
| `signs.<severity>` | nerd-font glyphs | -- |
| `use_diagnostic_signs` | `false` | Use our `signs` table, not the vim diag ones. |
| `telescope.theme` | `'dropdown'` | -- |

## References

- https://github.com/folke/trouble.nvim
