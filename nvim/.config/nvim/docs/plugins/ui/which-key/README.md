# which-key

`folke/which-key.nvim` -- popup that shows pending keymaps after a partial
prefix. Loaded on `VimEnter`. `timeoutlen = 300` (set in `wild-duck/set.lua`)
controls how quickly the popup appears.

## Files

- `init.lua` -- spec; `opts` returns the table from `config.lua`.
- `config.lua` -- the `opts` table with `win`, `icons`, and `spec` (group
  labels).

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `win.border` | `'rounded'` | -- |
| `win.padding` | `{ 1, 2 }` | -- |
| `icons.mappings` | `vim.g.have_nerd_font` | Nerd font icons for groups. |
| `icons.keys` | text fallbacks | Used when no nerd font. |

## Group labels (`spec`)

These define the labels shown in the popup for the prefixes they cover. They
don't define the actual keymaps -- those live in the plugins that own them.

| Prefix | Label | Mode |
| --- | --- | --- |
| `<leader>c` | `[C]ode` | n, x |
| `<leader>d` | `[D]elete/Document` | n |
| `<leader>e` | `[E]rror diagnostics` | n |
| `<leader>h` | `Git [H]unk` | n, v |
| `<leader>p` | `[P]roject` | n |
| `<leader>q` | `[Q]uickfix` | n |
| `<leader>r` | `[R]ename/[R]ust` | n |
| `<leader>s` | `[S]earch` | n |
| `<leader>t` | `[T]oggle/Tab` | n |
| `<leader>v` | `[V]im config` | n |
| `<leader>w` | `[W]orkspace` | n |
| `<leader>x` | `Trouble/E[x]ecute` | n |
| `<leader>y` | `[Y]ank to clipboard` | n |

To add a label, append to `spec`:

```lua
{ '<leader>z', group = '[Z]en' },
```

## Keymaps / commands

`:WhichKey` shows the popup manually. No keymaps bound here.

## References

- https://github.com/folke/which-key.nvim
