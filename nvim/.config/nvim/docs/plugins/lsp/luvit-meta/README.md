# luvit-meta

`Bilal2453/luvit-meta` -- pure-data plugin that ships type annotations for the
`luv` library (`vim.uv.*`). Consumed by `lazydev.nvim` via the
`library = { { path = 'luvit-meta/library', words = { 'vim%.uv' } } }`
entry in `plugins/lsp/lazydev/config.lua`.

## Files

- `init.lua` -- spec only, `lazy = true`. Never loaded by command -- it just
  has to exist on the rtp so lazydev can find `luvit-meta/library`.

## Why we use it

Without it, `vim.uv.<anything>` shows up as `unknown` in `lua_ls`.

## Configurable knobs

None.

## Keymaps / commands

None.

## References

- https://github.com/Bilal2453/luvit-meta
