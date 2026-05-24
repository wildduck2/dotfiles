# lsp-lens

`VidocqH/lsp-lens.nvim` -- "codelens"-style inline counts (references,
definitions, implementations) above functions/classes. Loads on `LspAttach`.

## Files

- `init.lua` -- spec only, no custom config.

## Why we use it

Quick at-a-glance reference counts. Defaults are fine for most languages.

## Configurable knobs

We use defaults. To customise, pass `opts` in `init.lua`. Notable upstream
options:

- `enable` -- master switch.
- `include_declaration` -- count declaration site in references.
- `sections.definition` / `references` / `implements` / `git_authors` --
  per-feature toggle.
- `target_symbol_kinds` -- which symbol kinds get the lens (defaults: function, method).

## Keymaps / commands

`:LspLensOn`, `:LspLensOff`, `:LspLensToggle`.

## References

- https://github.com/VidocqH/lsp-lens.nvim
