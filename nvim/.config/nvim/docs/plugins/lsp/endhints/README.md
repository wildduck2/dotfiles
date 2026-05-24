# endhints

`chrisgrieser/nvim-lsp-endhints` -- moves LSP inlay hints to the end of the
line as virtual text, instead of inline. Loads on `LspAttach`.

## Files

- `init.lua` -- spec + `opts`.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `autoEnableHints` | `true` | Turn on for every attached LSP. |
| `icons.type` | `'=> '` | Prefix for type hints. |
| `icons.parameter` | `'=> '` | Prefix for parameter hints. |
| `icons.offspec` | `'=> '` | Prefix for non-LSP-spec hints. |
| `icons.unknown` | `'=> '` | Fallback prefix. |
| `label.truncateAtChars` | `40` | Truncate end-hint label past this length. |

## Interaction with lspconfig

`plugins/lsp/lspconfig/config.lua`'s `on_attach` also enables inlay hints
via `vim.lsp.inlay_hint.enable(true, ...)` and binds `<leader>th` to toggle.
endhints reads those hints and renders them at end-of-line.

## Keymaps / commands

`<leader>th` (from lspconfig's on_attach) is the toggle.

## References

- https://github.com/chrisgrieser/nvim-lsp-endhints
