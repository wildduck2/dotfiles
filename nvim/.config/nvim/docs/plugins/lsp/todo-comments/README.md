# todo-comments

`folke/todo-comments.nvim` -- highlights TODO / FIXME / NOTE / HACK / WARN /
PERF / TEST and provides a search/list panel. Loaded eagerly (`lazy = false`).

## Files

- `init.lua` -- spec; passes `opts = { signs = false }` to disable the sign
  column glyphs (we keep highlights only).

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `signs` | `false` | No glyphs in the sign column. |

Upstream defaults define keywords (TODO, FIX, FIXME, BUG, ISSUE, HACK, WARNING,
PERF, OPTIM, NOTE, INFO, TEST). To add a custom keyword, pass
`keywords = { CUSTOM = { icon = ' ', color = 'info' } }`.

## Commands

- `:TodoTelescope` -- fuzzy-find TODOs across the project.
- `:TodoQuickFix`, `:TodoLocList`, `:TodoTrouble`.

## Keymaps

None bound here. To search TODOs via telescope, call `:TodoTelescope`.

## Dependencies

- `nvim-lua/plenary.nvim`.

## References

- https://github.com/folke/todo-comments.nvim
