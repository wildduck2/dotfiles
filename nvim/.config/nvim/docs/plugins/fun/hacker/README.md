# hacker

`letieu/hacker.nvim` -- types fake code into the buffer as if you were a
movie hacker. Loaded on `:Hack` or `:HackFollowAuto`.

## Files

- `init.lua` -- spec; lazy-loaded by command.
- `config.lua` -- sets up the plugin and binds keymaps.

## Keymaps

| Key | Action |
| --- | --- |
| `<leader>h` | `:Hack` |
| `<leader>ha` | `:HackFollowAuto` |

## Commands

- `:Hack`
- `:HackFollowAuto`

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `content` | `[[ Code want to show.... ]]` | Text "typed" by hacker mode. |
| `filetype` | `'lua'` | Syntax highlighting applied to the fake code. |
| `speed.min` / `speed.max` | `2`, `2` | Chars per tick. |
| `is_popup` | `false` | Render in current buffer. Set true for popup. |
| `popup_after` | `5` | Seconds before popup mode kicks in (when `is_popup = true`). |

## References

- https://github.com/letieu/hacker.nvim
