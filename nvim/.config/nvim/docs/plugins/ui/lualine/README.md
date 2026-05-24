# lualine

`nvim-lualine/lualine.nvim` -- statusline.

## Files

- `init.lua` -- spec; calls `require('plugins.ui.lualine.config').setup()`.
- `config.lua` -- `lualine.setup{}` and a short-mode-name map.

## Custom mode names

`M.mode_map` shortens `vim.api.nvim_get_mode().mode` to single letters / pairs:

| mode() | Display |
| --- | --- |
| `n`, `niI`, `niR`, `niV`, `nt` | `N` |
| `no`, `nov`, `noV` | `O-P` |
| `v`, `vs` | `V` |
| `V`, `Vs` | `V-L` |
| `s` | `S` |
| `S` | `S-L` |
| `i`, `ic`, `ix` | `I` |
| `R`, `Rc`, `Rx` | `R` |
| `Rv`, `Rvc`, `Rvx` | `V-R` |
| `c` | `C` |
| `cv`, `ce` | `EX` |
| `r`, `rm` | `R`, `MORE` |
| `r?` | `CONFIRM` |
| `!` | `SHELL` |
| `t` | `T` |

## Sections

| Section | Components |
| --- | --- |
| A (left) | mode (mapped) |
| B | branch, diagnostics |
| C | diff, filename |
| X | filetype |
| Y | progress (`%`) |
| Z | location (`line:col`) |

Inactive windows only show filename in C and location in X.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `options.icons_enabled` | `true` | -- |
| `options.theme` | `'auto'` | Picks colors from current colorscheme. |
| `options.section_separators` | powerline arrows | Set to `''`/`''` for no separators. |
| `branch.icon` | git glyph | -- |
| `branch.colored` | `true` | -- |
| `branch.update_in_insert` | `false` | Faster typing. |
| `branch.always_visible` | `false` | Hide when no branch. |
| `diagnostics.sources` | `nvim_diagnostic` | LSP source. |
| `diagnostics.sections` | `error warn info hint` | -- |
| `diagnostics.symbols` | `E W I H` | Plain letters. |
| `diff.colored` | `true` | -- |
| `diff.diff_color` | `LuaLineDiffAdd / Change / Delete` | Highlight groups. |
| `diff.symbols` | `+ ~ -` | -- |
| `filename.path` | `1` | Relative path. (`0` = name, `1` = relative, `2` = absolute, `3` = absolute with tilde) |
| `filename.shorting_target` | `40` | Trim before this length. |
| `filename.symbols` | `[+] [-] [No Name] [New]` | -- |
| `filetype.colored` | `true` | -- |
| `filetype.icon_only` | `false` | -- |
| `filetype.icons_enabled` | `false` | -- |
| `tabline` / `winbar` / `inactive_winbar` | `{}` | Disabled. |
| `extensions` | `{}` | Add `'nvim-tree'`, `'fugitive'`, `'trouble'` etc. for filtered statuslines in those buffers. |

## Keymaps / commands

None.

## References

- https://github.com/nvim-lualine/lualine.nvim
