# lazydev

`folke/lazydev.nvim` -- patches `lua_ls` so it understands Neovim's API and
plugin runtimepath lazily (faster than the old `vim.api.nvim_get_runtime_file()`
dump into `workspace.library`).

## Files

- `init.lua` -- spec; loads on `ft = 'lua'`. `opts` returns the table from
  `config.lua`.
- `config.lua` -- the `opts` table.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `library[1]` | `{ path = 'luvit-meta/library', words = { 'vim%.uv' } }` | Only loads luv types when the file references `vim.uv`. Speeds up lua_ls. |

To add more on-demand libraries:

```lua
library = {
  { path = 'luvit-meta/library', words = { 'vim%.uv' } },
  { path = 'lazy.nvim/lua/lazy', words = { 'LazyPluginSpec' } },
}
```

## Why we use it

Avoids stuffing the entire runtimepath into `lua_ls`'s `workspace.library`,
which was slow. Each library is loaded only when referenced. The lspconfig
config also still populates `workspace.library` once (deferred to `setup()`),
so both work together.

## Cmp source

`lazydev` registers a cmp source named `lazydev`; the cmp `sources` table in
`plugins/cmp/config.lua` lists it first with `group_index = 0`.

## References

- https://github.com/folke/lazydev.nvim
