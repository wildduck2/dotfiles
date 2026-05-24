# lint

`mfussenegger/nvim-lint` -- async linters per filetype. Loaded on `BufReadPost`.

## Files

- `init.lua` -- spec.
- `config.lua` -- `linters_by_ft` map, the postgres-dialect injection for
  sqlfluff, and the `BufWritePost,InsertLeave` autocmd that runs lint only
  when the linter binary exists.

## linters_by_ft

```lua
linters_by_ft = {
  markdown   = { 'markdownlint' },
  lua        = { 'luacheck' },
  python     = { 'pylint' },
  go         = { 'golangcilint' },
  dockerfile = { 'hadolint' },

  sql        = { 'sqlfluff' },
  mysql      = { 'sqlfluff' },
  plsql      = { 'sqlfluff' },
}
```

Biome handles JS/TS linting via LSP -- there is no eslint_d entry on purpose.

## sqlfluff dialect injection

```lua
if lint.linters.sqlfluff then
  local args = vim.deepcopy(lint.linters.sqlfluff.args or {})
  table.insert(args, 1, '--dialect')
  table.insert(args, 2, 'postgres')
  lint.linters.sqlfluff.args = args
end
```

Default dialect is `postgres`. To switch globally edit this block; to switch
per project, drop a `.sqlfluff` config file at the project root with
`[sqlfluff] dialect = mysql` (or whatever) -- sqlfluff picks it up
automatically and our default is harmless.

## Autocmd

```lua
local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function() ... end,
})
```

Per fire:
1. Get linters for current ft.
2. For each, resolve its `cmd` (string or function).
3. If `vim.fn.executable(cmd) == 1`, call `lint.try_lint(name)`. Otherwise
   skip silently -- prevents "command not found" noise when a linter isn't
   installed.

## Keymaps / commands

None. nvim-lint has `:lua require('lint').try_lint()` for manual runs.

## External setup

Each linter binary must be installed and on PATH:

- `markdownlint` -- via npm: `npm i -g markdownlint-cli`.
- `luacheck` -- via luarocks: `luarocks install luacheck`.
- `pylint` -- via pip.
- `golangci-lint` -- official installer.
- `hadolint` -- prebuilt binary or `brew install hadolint`.
- `sqlfluff` -- auto-installed by mason-tool-installer (see
  `plugins/lsp/lspconfig/`).

## References

- https://github.com/mfussenegger/nvim-lint
