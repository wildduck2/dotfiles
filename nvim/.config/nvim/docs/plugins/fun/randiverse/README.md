# randiverse

`ty-labs/randiverse.nvim` -- random data generators inserted at cursor. Useful
for test fixtures and seed data.

## Files

- `init.lua` -- spec; lazy on `:Randiverse`.
- `config.lua` -- `randiverse.setup{}` with keymaps and data tables.

## Keymaps

All under `<leader>r` followed by a single letter. Bound by the plugin from
the `keymaps` table.

| Key | Generates |
| --- | --- |
| `<leader>rc` | country |
| `<leader>rd` | datetime |
| `<leader>re` | email |
| `<leader>rf` | float |
| `<leader>rh` | hex color |
| `<leader>ri` | int |
| `<leader>rI` | ip |
| `<leader>rl` | lorem ipsum |
| `<leader>rN` | name |
| `<leader>ru` | url |
| `<leader>rU` | uuid |
| `<leader>rw` | word |

Disable a generator by setting `enabled = false` on its entry in `config.lua`,
or override the keymap there.

Note: `<leader>r` is also the which-key group for "Rename/Rust" (see
`plugins/ui/which-key/config.lua`). It still works because randiverse uses the
unused single-letter children.

## Commands

`:Randiverse <name>` -- e.g. `:Randiverse uuid`.

## Configurable knobs

- `keymaps_enabled` -- master switch for keymaps.
- `keymaps.<name>` -- per-generator keymap, command, desc, enabled flag.
- `DATA.<name>` -- data sources and defaults. Most interesting ones:
  - `datetime.formats` / `default_formats` -- ISO, RFC, sortable, human, etc.
  - `email.domains`, `tlds`, `digits`, `specials`, `separators`.
  - `float.default_start/stop/decimals`, `int.default_start/stop`.
  - `lorem.sentence_lengths`, `default_corpus`, `default_length`.
  - `url.protocols`, `tlds`, default corpuses.

## References

- https://github.com/ty-labs/randiverse.nvim
