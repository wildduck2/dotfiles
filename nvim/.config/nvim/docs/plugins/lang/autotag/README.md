# autotag

`windwp/nvim-ts-autotag` -- auto-close and auto-rename HTML/JSX/XML tags using
treesitter. Loaded on `InsertEnter`.

## Files

- `init.lua` -- spec.
- `config.lua` -- runs `nvim-ts-autotag.setup{}` with our filetype list.

## Configurable knobs

| Option | Value | Notes |
| --- | --- | --- |
| `opts.enable_close` | `true` | Auto-close when typing `>`. |
| `opts.enable_rename` | `true` | Rename matching pair when one side changes. |
| `opts.enable_close_on_slash` | `true` | Auto-close on `</`. |
| `filetypes` | `html, javascript, typescript, javascriptreact, typescriptreact, svelte, vue, tsx, jsx, rescript, xml, php, markdown, astro, glimmer, handlebars, hbs` | Activate per buffer. |

Per-filetype overrides go inside the `opts` table -- see plugin README.

## Keymaps / commands

None.

## References

- https://github.com/windwp/nvim-ts-autotag
