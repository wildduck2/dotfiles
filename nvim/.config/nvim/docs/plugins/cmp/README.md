# cmp -- nvim-cmp completion engine

`hrsh7th/nvim-cmp` provides insert-mode completion. LuaSnip handles snippet
expansion. Mason and mason-lspconfig are pulled in as dependencies so the
LSP servers in `plugins/lsp/lspconfig/` can install cleanly when cmp loads.

## Why we use it

Single unified completion menu fed by LSP, snippets, paths, and (for SQL)
the dadbod completion source. LuaSnip lets us define our own snippets in
`snippets/`.

## Files in this module

- `init.lua` -- lazy spec; loads on `InsertEnter`. Wires LuaSnip and registers
  the cmp dependency chain.
- `config.lua` -- runs `cmp.setup{}` with our keymaps, sources, and windows.
- `snippets/init.lua` -- requires both snippet files below.
- `snippets/lua.lua` -- Lua snippets: `req`, `req2`, `fun`.
- `snippets/typescript.lua` -- TypeScript snippets: `ea_func`, `ea_module`,
  `nest_service`.

## Dependencies pulled in here

- `L3MON4D3/LuaSnip` (built with `make install_jsregexp`)
- `neovim/nvim-lspconfig`, `williamboman/mason.nvim`, `williamboman/mason-lspconfig.nvim`
- `hrsh7th/cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp-nvim-lsp`, `cmp-nvim-lua`
- `saadparwaiz1/cmp_luasnip`
- `rafamadriz/friendly-snippets`

## Keymaps (insert mode unless noted)

| Key | Action |
| --- | --- |
| `<C-n>` | next suggestion |
| `<C-p>` | previous suggestion |
| `<C-b>` | scroll docs up |
| `<C-f>` | scroll docs down |
| `<C-y>` | confirm with `select = true` |
| `<C-Space>` | trigger completion manually |
| `<C-l>` (i,s) | jump forward through snippet placeholders (luasnip) |
| `<C-h>` (i,s) | jump backward through snippet placeholders |
| `<C-k>` (i,s) | expand or jump in LuaSnip (registered in LuaSnip config block) |

Note: `<C-h>` is also a window-nav key in normal mode; that conflict only
matters in insert/select where the snippet jump applies.

## Sources (priority order)

```lua
sources = {
  { name = 'lazydev', group_index = 0 },
  { name = 'nvim_lsp' },
  { name = 'luasnip' },
  { name = 'path' },
}
```

`group_index = 0` puts `lazydev` ahead of everything when editing Lua so that
`vim.api` / `vim.uv` completions win. SQL buffers override these sources from
`plugins/lang/dadbod/init.lua` to put `vim-dadbod-completion` first.

## Other knobs

- `snippet.expand` -- `luasnip.lsp_expand(args.body)`.
- `window.completion` / `window.documentation` -- `cmp.config.window.bordered`
  with `border = 'rounded'`.
- `completion.completeopt` -- `'menu,menuone,noinsert'` so the menu shows even
  with one match and nothing is auto-inserted.

## Custom snippets

See [snippets/README.md](snippets/README.md).

## References

- nvim-cmp: https://github.com/hrsh7th/nvim-cmp
- LuaSnip: https://github.com/L3MON4D3/LuaSnip
- friendly-snippets: https://github.com/rafamadriz/friendly-snippets
