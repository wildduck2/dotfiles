# nvim-tree

`nvim-tree/nvim-tree.lua` -- file tree sidebar. Loaded eagerly. Replaces
netrw (`vim.g.loaded_netrw = 1`, `vim.g.loaded_netrwPlugin = 1` set in `init`).

## Files

- `init.lua` -- spec; depends on `nvim-web-devicons` (with our icon overrides
  defined in `config.devicons_opts`). Disables netrw in the `init` block.
  Defines `<leader>pv` and `<leader>l` after `setup`.
- `config.lua` -- the `devicons_opts` table, tab management keymaps, custom
  highlights, and `nvim-tree.setup{}`.

## Keymaps (global)

| Key | Action |
| --- | --- |
| `<leader>pv` | `NvimTreeToggle` |
| `<leader>l` | `NvimTreeFocus` |
| `<leader>tn` | new tab |
| `<leader>to` | close other tabs (`tabonly`) |
| `<leader>tc` | close tab |
| `<leader>t.` | next tab |
| `<leader>t,` | previous tab |

## Keymaps (inside tree, on_attach)

Default mappings from `api.config.mappings.default_on_attach(bufnr)` plus:

| Key | Action |
| --- | --- |
| `s` | open under cursor in the system file manager (`nautilus`) |

Replace `nautilus` in `config.lua` if you use a different DE.

## Custom highlights

Set via `vim.api.nvim_set_hl`:

- `SpellCap` -- empty (clears the underline).
- `NvimTreeSpecialFile` -- pink, underline.
- `NvimTreeSymlink` -- yellow italic.
- `NvimTreeImageFile` -- linked to `Title`.

## devicons overrides

| Target | Icon / color |
| --- | --- |
| `zsh` filetype | green Zsh glyph |
| `.gitignore` filename | orange Gitignore glyph |
| `.log` extension | green Log glyph |

`color_icons = true`, `default = true`, `strict = true`,
`override_by_filename` and `override_by_extension` tables.

## Configurable knobs (selected)

| Option | Value | Notes |
| --- | --- | --- |
| `auto_reload_on_write` | `true` | Refresh on `:w`. |
| `sort.sorter` | `'case_sensitive'` | `'name'`, `'modification_time'` also valid. |
| `filters.dotfiles` | `false` | Show dotfiles. |
| `disable_netrw` | `true` | -- |
| `hijack_netrw` | `true` | Open tree instead of netrw. |
| `hijack_cursor` | `true` | Cursor lands on filename. |
| `sync_root_with_cwd` | `true` | Root follows `:cd`. |
| `update_focused_file.enable` | `true` | Highlight current file. |
| `update_focused_file.update_root` | `false` | Don't change root when jumping. |
| `view.side` | `'left'` | Or `'right'`. |
| `view.width` | `45` | Cols. |
| `view.preserve_window_proportions` | `true` | -- |
| `git.enable` | `true` | -- |
| `git.ignore` | `false` | Show ignored files. |
| `filesystem_watchers.enable` | `true` | Live updates. |
| `filesystem_watchers.debounce_delay` | `100` | ms. |
| `actions.open_file.resize_window` | `true` | -- |
| `renderer.root_folder_label` | `false` | -- |
| `renderer.highlight_git` | `true` | Color filenames by git status. |
| `renderer.highlight_opened_files` | `'none'` | `'icon'`, `'name'`, `'all'` also valid. |
| `renderer.indent_markers.enable` | `true` | -- |
| `renderer.icons.glyphs` | nerd-font icons for folders, symlinks, git states | full table in `config.lua` |

## References

- https://github.com/nvim-tree/nvim-tree.lua
- https://github.com/nvim-tree/nvim-web-devicons
