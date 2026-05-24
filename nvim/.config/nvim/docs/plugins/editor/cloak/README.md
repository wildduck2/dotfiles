# cloak

`laytan/cloak.nvim` -- masks secret values in dotenv-like files so they don't
leak in screen-shares or pair sessions.

## Why we use it

`.env` files routinely sit in tabs while debugging; cloak hides everything
after `=` so you see keys but not values.

## Files

- `init.lua` -- spec; loads on `BufReadPost`.
- `config.lua` -- returns the `opts` table.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `enabled` | `true` | Master switch. |
| `cloak_character` | `'*'` | Replacement glyph; could be `'.'` etc. |
| `highlight_group` | `'Comment'` | Style for masked text. |
| `patterns[1].file_pattern` | `{ '.env*', 'wrangler.toml', '.dev.vars' }` | Where masking applies. |
| `patterns[1].cloak_pattern` | `'=.+'` | Regex masking everything after `=`. |

Add more rules by appending to `patterns`, e.g. one for AWS credentials files.

## Keymaps / commands

Cloak's own commands (not bound here): `:CloakToggle`, `:CloakEnable`,
`:CloakDisable`, `:CloakPreviewLine`.

## References

- https://github.com/laytan/cloak.nvim
