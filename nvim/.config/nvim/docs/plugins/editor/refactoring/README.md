# refactoring

`ThePrimeagen/refactoring.nvim` -- treesitter-driven refactor operations
(extract function, extract variable, inline, etc.).

## Files

- `init.lua` -- spec only. Dependencies: `plenary.nvim`,
  `nvim-treesitter`. Loads on `BufReadPost`. No `config` block, so the plugin
  loads with defaults; we have not enabled any keymaps.

## Why we use it

Available for ad-hoc refactors via the `:Refactor` command and the lua API.
Not heavily customised in this config.

## Commands

Ex-command surface from the plugin (default):

- `:Refactor extract <name>` -- extract visual selection into a function.
- `:Refactor extract_to_file <name>` -- extract into a new file.
- `:Refactor extract_var <name>` -- extract selection into a local.
- `:Refactor inline_func` -- inline a function.
- `:Refactor inline_var` -- inline a variable.
- `:Refactor extract_block`, `:Refactor extract_block_to_file`.

These require a Treesitter-supported language (js/ts/lua/python/go/cpp/c/rb/etc.)
and usually a visual selection.

## Keymaps

None defined here.

## References

- https://github.com/ThePrimeagen/refactoring.nvim
