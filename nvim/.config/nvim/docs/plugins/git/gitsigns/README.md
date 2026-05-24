# gitsigns

`lewis6991/gitsigns.nvim` -- hunk signs in the sign column, hunk preview,
stage/reset/blame from the buffer. Loaded on `BufReadPre`.

## Files

- `init.lua` -- spec; calls `require('plugins.git.gitsigns.config').setup()`.
- `config.lua` -- runs `gitsigns.setup{}` with our signs, blame settings, and
  the `on_attach` callback that defines all hunk keymaps.

## Sign glyphs

| Type | Symbol |
| --- | --- |
| add | `+` |
| change | `~` |
| delete | `_` |
| topdelete | overline (U+203E) |
| changedelete | `~` |

## Keymaps (buffer-local, from `on_attach`)

| Mode | Key | Action |
| --- | --- | --- |
| n | `]c` / `[c` | next/prev hunk (falls through to native diff jump in `&diff` mode) |
| n | `<leader>hs` | stage hunk |
| n | `<leader>hr` | reset hunk |
| v | `<leader>hs` | stage selected lines |
| v | `<leader>hr` | reset selected lines |
| n | `<leader>hS` | stage entire buffer |
| n | `<leader>hu` | undo last staged hunk |
| n | `<leader>hR` | reset buffer (discard changes) |
| n | `<leader>hp` | preview hunk (floating window) |
| n | `<leader>hb` | full blame for current line |
| n | `<leader>tb` | toggle inline blame |
| n | `<leader>hd` | diff vs index |
| n | `<leader>hD` | diff vs HEAD~ |
| n | `<leader>td` | toggle deleted line display |
| o, x | `ih` | text object for current hunk (`:<C-U>Gitsigns select_hunk<CR>`) |

The `<leader>h` which-key group label is set to "Git [H]unk" in
`plugins/ui/which-key/config.lua`.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `signs_staged_enable` | `true` | Different signs for staged hunks. |
| `signcolumn` | `true` | Show signs in the sign column. |
| `numhl` | `false` | Don't color line numbers. |
| `linehl` | `false` | Don't background-highlight changed lines. |
| `culhl` | `false` | Don't highlight cursorline sign column. |
| `show_deleted` | `false` | Virtual lines for deletes off by default; `<leader>td` toggles. |
| `sign_priority` | `6` | Above diagnostics signs (default lspconfig signs use lower priority). |
| `auto_attach` | `true` | Attach when buffer is git-tracked. |
| `attach_to_untracked` | `false` | Don't track new files. |
| `update_debounce` | `500` | ms delay before updating signs. |
| `max_file_length` | `40000` | Skip giant files. |
| `word_diff` | `false` | No inline word diff. |
| `current_line_blame` | `false` | Off by default; `<leader>tb` toggles. |
| `current_line_blame_opts.virt_text_pos` | `'eol'` | Position. |
| `current_line_blame_opts.delay` | `1000` | ms after cursor stops. |
| `current_line_blame_opts.use_focus` | `true` | Only show in focused window. |
| `current_line_blame_formatter` | `' <author>, <author_time:%R> - <summary> '` | Format string. |
| `preview_config.border` | `'rounded'` | Hunk preview window. |
| `watch_gitdir.enable` | `true` | Refresh when `.git` changes (CLI commits). |
| `watch_gitdir.follow_files` | `true` | Track renames. |

## References

- https://github.com/lewis6991/gitsigns.nvim
