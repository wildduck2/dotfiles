# treesitter

`nvim-treesitter/nvim-treesitter` (main branch) plus
`MeanderingProgrammer/treesitter-modules.nvim` and
`nvim-treesitter/nvim-treesitter-textobjects`.

The main branch of nvim-treesitter dropped its built-in `setup{}`; the
`treesitter-modules` plugin provides the old `highlight/indent/incremental_selection/textobjects`
modules on top of it.

## Files

- `init.lua` -- two specs (`nvim-treesitter` on main, `treesitter-modules`
  with the textobjects dep). Builds with `:TSUpdate`.
- `config.lua` -- runs `treesitter-modules.setup{}` with all modules.

## ensure_installed parsers

```
bash, c, cpp, css, eex, elixir, erlang, go, gitignore, haskell, heex, hjson,
html, javascript, jsdoc, json, json5, lua, ocaml, perl, php, markdown,
markdown_inline, prisma, rust, scala, scss, sql, surface, tsx, typescript,
vim, vimdoc, yaml, zig
```

`auto_install = false` -- new parsers are not pulled silently. Add to the
list above (or run `:TSInstall <lang>` ad-hoc).

## Modules

| Module | State | Notes |
| --- | --- | --- |
| `highlight.enable` | `true` | -- |
| `indent.enable` | `true` | -- |
| `incremental_selection` | enabled | keymaps below |
| `textobjects.select` | enabled, lookahead | keymaps below |
| `textobjects.move` | enabled, sets jumps | -- |
| `textobjects.swap` | enabled | -- |

## Incremental selection

| Key | Action |
| --- | --- |
| `<C-Space>` | init selection / node-incremental |
| `<C-s>` | scope-incremental |
| `<M-Space>` | node-decremental |

## Textobjects (select)

| Key | Selects |
| --- | --- |
| `af` | `@function.outer` |
| `if` | `@function.inner` |
| `ac` | `@class.outer` |
| `ic` | `@class.inner` |
| `aa` | `@parameter.outer` |
| `ia` | `@parameter.inner` |

## Textobjects (move)

| Key | Target |
| --- | --- |
| `]m` | next `@function.outer` start |
| `]]` | next `@class.outer` start |
| `]M` | next `@function.outer` end |
| `][` | next `@class.outer` end |
| `[m` | prev `@function.outer` start |
| `[[` | prev `@class.outer` start |
| `[M` | prev `@function.outer` end |
| `[]` | prev `@class.outer` end |

`set_jumps = true` so these go in the jumplist (`<C-o>` / `<C-i>`).

## Textobjects (swap)

| Key | Action |
| --- | --- |
| `<leader>sp` | swap current parameter with next |
| `<leader>sP` | swap current parameter with previous |

Note: `<leader>s` is the which-key search group; these still resolve because
swap is the only sub-mapping that uses `sp`/`sP`.

## Commands

`:TSInstall <lang>`, `:TSUpdate`, `:TSPlaygroundToggle` (if playground loaded).

## References

- nvim-treesitter: https://github.com/nvim-treesitter/nvim-treesitter
- nvim-treesitter-textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
- treesitter-modules.nvim: https://github.com/MeanderingProgrammer/treesitter-modules.nvim
