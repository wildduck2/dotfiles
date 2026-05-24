# cellular-automaton

`eandrju/cellular-automaton.nvim` -- runs cellular-automaton animations on the
current buffer. Used in `wild-duck/remap.lua` for the `<leader>mr` keymap.

## Files

- `init.lua` -- spec only, loads when `:CellularAutomaton` is invoked.

## Keymaps

| Key | Action |
| --- | --- |
| `<leader>mr` | `:CellularAutomaton make_it_rain` (defined in `wild-duck/remap.lua`) |

## Commands

- `:CellularAutomaton make_it_rain`
- `:CellularAutomaton game_of_life`
- `:CellularAutomaton scramble`

## Configurable knobs

None set; defaults from the plugin.

## References

- https://github.com/eandrju/cellular-automaton.nvim
