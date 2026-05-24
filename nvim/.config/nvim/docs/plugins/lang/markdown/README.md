# markdown

Three plugins for markdown work.

## Files

- `init.lua` -- returns a list of three specs.
- `config.lua` -- exports `setup_peek()` which configures `peek.nvim` and
  defines two custom commands.

## Plugins

### obsidian.nvim

`epwalsh/obsidian.nvim` -- Obsidian vault integration. Lazy on `ft = 'markdown'`,
`version = '*'`. No custom config (would need a `workspaces` table to be useful
in practice).

### mdx.nvim

`davidmh/mdx.nvim` -- highlight + treesitter support for `.mdx`. Lazy on
`ft = 'mdx'`. `config = true` so the plugin's default setup runs.

### peek.nvim

`toppair/peek.nvim` -- live markdown preview in a browser. Built with
`deno task --quiet build:fast`. `setup_peek()` configures it and defines
`:PeekOpen` and `:PeekClose` custom commands.

## Commands (peek)

| Command | Action |
| --- | --- |
| `:PeekOpen` | If not already open and current ft is `markdown`, runs `i3-msg split horizontal` then opens peek. |
| `:PeekClose` | Closes peek and runs `i3-msg move left` to put the editor back where it was. |

These commands assume i3 window manager. Strip the `vim.system({ 'i3-msg', ... })`
calls in `config.lua` if you run a different WM.

## peek configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `auto_load` | `false` | Open preview manually via `:PeekOpen`. |
| `close_on_bdelete` | `true` | Close when the buffer is deleted. |
| `syntax` | `true` | Syntax highlighting in preview. |
| `theme` | `'dark'` | Or `'light'`. |
| `update_on_change` | `true` | Live update. |
| `app` | `'browser'` | Or `'webview'`. |
| `filetype` | `{ 'markdown' }` | Activate only for these fts. |
| `throttle_at` | `200000` | Throttle past this many chars. |
| `throttle_time` | `'auto'` | Or ms number. |

## Keymaps

None defined here.

## External setup

- peek.nvim requires `deno` and a browser.
- obsidian.nvim is dormant until you call `setup{ workspaces = { ... } }`.
- i3wm is assumed for `:PeekOpen` / `:PeekClose`.

## References

- obsidian.nvim: https://github.com/epwalsh/obsidian.nvim
- mdx.nvim: https://github.com/davidmh/mdx.nvim
- peek.nvim: https://github.com/toppair/peek.nvim
