# conform -- format engine

`stevearc/conform.nvim`. Owns all formatting in the config. Runs on save by
default and on demand via `<leader>f`. LSP formatting is used as a fallback
when no conform formatter exists for a buffer.

## Why we use it

One declarative formatter registry, async-by-default, with per-buffer LSP
fallback. Replaces `null-ls` / `none-ls` and the formatter half of
`efm-langserver`.

## Files

- `init.lua` -- spec; loads on `BufReadPost`. Calls
  `require('plugins.conform.config').setup()`.
- `config.lua` -- runs `conform.setup{}` with `formatters_by_ft`, the custom
  formatter map, the `format_after_save` callback, and the `<leader>f` keymap.
- `formatters/` -- per-formatter `FileFormatterConfig` overrides. See
  [formatters/README.md](formatters/README.md).

## Keymaps

| Mode | Key | Action |
| --- | --- | --- |
| n / v | `<leader>f` | `conform.format { lsp_fallback = true, timeout_ms = 1000 }` |

## Format-on-save flow

`format_after_save` is a function:

```lua
format_after_save = function(bufnr)
  local available = conform.list_formatters(bufnr)
  if #available == 0 then
    return
  end
  return { lsp_fallback = true }
end
```

So save only triggers a format pass when at least one matching formatter is
registered. The pass itself falls back to LSP formatting if the formatter
program fails to run.

`notify_on_error = true` -- conform shows a notification when a formatter
exits non-zero.

## formatters_by_ft

```lua
formatters_by_ft = {
  lua            = { 'stylua' },
  c              = { 'clang_format' },
  cpp            = { 'clang_format' },
  python         = { 'isort', 'black' },
  go             = { 'goimports', 'gofmt' },
  rust           = { 'rustfmt', lsp_format = 'fallback' },
  javascript     = { 'biome' },
  typescript     = { 'biome' },
  javascriptreact= { 'biome' },
  typescriptreact= { 'biome' },
  json           = { 'biome' },
  html           = { 'prettier' },
  css            = { 'prettier' },
  scss           = { 'prettier' },
  yaml           = { 'prettier' },
  markdown       = { 'prettier' },
  mdx            = { 'prettier' },
  bash           = { 'shfmt' },
  sh             = { 'shfmt' },
  sql            = { 'sqlfluff' },
  mysql          = { 'sqlfluff' },
  plsql          = { 'sqlfluff' },
}
```

Sequence inside a list = run in that order (for example `isort` then `black`,
`goimports` then `gofmt`). The `lsp_format = 'fallback'` flag on `rust` means
`rustfmt` runs first and the LSP only formats if `rustfmt` is unavailable.

SQL is owned by conform; the `sqls` LSP server has its formatting capability
disabled in `plugins/lsp/lspconfig/config.lua` (`on_attach` sets
`documentFormattingProvider = false`).

## How to add a new formatter

1. Create `lua/plugins/conform/formatters/<name>.lua` returning a
   `conform.FileFormatterConfig` table (command, args, stdin, optional cwd).
2. Register it in `lua/plugins/conform/formatters/init.lua` (key = the name
   conform looks up).
3. Map filetypes to it in `lua/plugins/conform/config.lua`'s `formatters_by_ft`.
4. Install the binary (or add it to `mason-tool-installer` if there is a Mason
   package).

## External setup

- Binaries must be on PATH. The `sqlfluff` binary is added to
  `mason-tool-installer` `ensure_installed` in `plugins/lsp/lspconfig/config.lua`.
  Other binaries (stylua, biome, prettier, shfmt, gofmt, goimports, rustfmt,
  clang-format, black, isort, pylint, etc.) are not auto-installed -- install
  them via your system package manager or via Mason manually (`:Mason`).
- prettier picks up `.prettierrc` / `prettier.config.*`.
- biome picks up `biome.json` / `biome.jsonc`.
- stylua picks up `stylua.toml` (we pass `--search-parent-directories`).
- rustfmt requires `rustfmt.toml` or `.rustfmt.toml` in cwd (sets edition).
- sqlfluff picks up `.sqlfluff` from project root if present, otherwise our
  default dialect `postgres` applies.

## References

- conform.nvim: https://github.com/stevearc/conform.nvim
