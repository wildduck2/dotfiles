# lspconfig

`neovim/nvim-lspconfig` plus `mason.nvim`, `mason-lspconfig.nvim`,
`mason-tool-installer.nvim`, and `j-hui/fidget.nvim`. The heart of the LSP
setup: defines every server we use, the on-attach keymaps, diagnostic display,
and the mason install pipeline.

## Files

- `init.lua` -- spec + dependencies; calls
  `require('plugins.lsp.lspconfig.config').setup()`.
- `config.lua` -- the full setup. Owns:
  - `M.servers` -- table of LSP servers and their per-server config.
  - `on_attach(event)` -- registers buffer-local LSP keymaps, document
    highlighting, inlay hints toggle.
  - `M.setup()` -- creates the `LspAttach` autocmd, configures
    `vim.diagnostic`, installs servers via mason-tool-installer, calls
    `vim.lsp.config(name, cfg)` + `vim.lsp.enable(name)` for each server.

## Servers configured (`M.servers` keys)

All servers below are auto-installed via `mason-tool-installer`
(`ensure_installed = vim.tbl_keys(M.servers)` plus `sqlfluff`).

| Server | Filetypes | Custom settings |
| --- | --- | --- |
| `clangd` | c, c++ | `{}` defaults; see also `plugins/lang/clangd-extensions/` |
| `lua_ls` | lua | `runtime.version = LuaJIT`; `workspace.checkThirdParty = false`; `workspace.library` is filled lazily in `setup()` with `${3rd}/luv/library` + `nvim_get_runtime_file('', true)`; `completion.callSnippet = 'Replace'` |
| `rust_analyzer` | rust | inlay hints (chaining, type, parameter) all enabled. Most rust users will prefer rustaceanvim (see `plugins/lang/rust/`); rustaceanvim is currently commented out in `plugins/lang/init.lua`. |
| `ts_ls` | js/ts | `init_options.preferences.disableSuggestions = false`; `includeCompletionsForModuleExports = false`; `includeCompletionsWithObjectLiteralMethodSnippets = false`; `includePackageJsonAutoImports = 'off'`; `maxTsServerMemory = 4096`. All four reduce typescript-language-server load on large projects. |
| `tailwindcss` | -- | defaults |
| `cssls` | -- | defaults |
| `html` | -- | defaults |
| `jsonls` | -- | defaults |
| `yamlls` | -- | defaults |
| `prismals` | -- | defaults |
| `typos_lsp` | `markdown`, `text`, `gitcommit` | spell checker, restricted to prose filetypes |
| `biome` | -- | `capabilities.general.positionEncodings = { 'utf-16' }`. `on_attach` (global) also disables biome diagnostics so ts_ls owns them. |
| `bashls` | -- | defaults |
| `dockerls` | -- | defaults |
| `docker_compose_language_service` | -- | defaults |
| `mdx_analyzer` | `mdx` | `init_options.typescript = {}` (lets mdx_analyzer use a local tsserver) |
| `sqls` | `sql`, `mysql`, `plsql` | connections live at `~/.config/sqls/config.yml`; `on_attach` disables `documentFormattingProvider` and `documentRangeFormattingProvider` so conform owns SQL formatting |

`sqlfluff` is added to `mason-tool-installer.ensure_installed` separately
(it's a CLI tool, not an LSP server).

## Global on_attach

`vim.api.nvim_create_autocmd('LspAttach', ...)` registers `on_attach`. For
every attaching client it does:

### LSP keymaps (buffer-local, prefixed `LSP:` in descriptions)

| Key | Action |
| --- | --- |
| `<leader>ca` | `vim.lsp.buf.code_action` |
| `<leader>rn` | `vim.lsp.buf.rename` |
| `gr` | telescope `lsp_references` |
| `gI` | telescope `lsp_implementations` |
| `gd` | telescope `lsp_definitions` |
| `gD` | `vim.lsp.buf.declaration` |
| `<leader>ds` | telescope `lsp_document_symbols` |
| `<leader>ws` | telescope `lsp_dynamic_workspace_symbols` |
| `<leader>D` | telescope `lsp_type_definitions` |
| `K` | `vim.lsp.buf.hover` |

### Biome diagnostics override

If `client.name == 'biome'`, sets `client.server_capabilities.diagnosticProvider = nil`
so ts_ls owns JS/TS diagnostics (avoids double-reporting).

### Document highlight

If the client supports `textDocument/documentHighlight` and the buffer hasn't
been registered yet, creates `kickstart-lsp-highlight` autocmd group:
- `CursorHold` -> `vim.lsp.buf.document_highlight`
- `CursorMoved` -> `vim.lsp.buf.clear_references`
- `LspDetach` -> clear references + tear down autocmds.

A buffer-local flag (`vim.b[buf]._lsp_highlight_registered`) prevents
duplicate registration if multiple LSPs attach to the same buffer.

### Inlay hints

If the client supports `textDocument/inlayHint`, enables hints for the buffer
(`vim.lsp.inlay_hint.enable(true, { bufnr = buf })`) and binds:

| Key | Action |
| --- | --- |
| `<leader>th` | toggle inlay hints for this buffer |

## Diagnostic display

`vim.diagnostic.config{ ... }` is set globally:

| Field | Value |
| --- | --- |
| `update_in_insert` | `false` |
| `severity_sort` | `true` |
| `float.border` | `'rounded'` |
| `float.source` | `'if_many'` |
| `underline` | `true` |
| `signs.text` | nerd-font icons per severity (when nerd font available) |
| `signs.severity.min` | `HINT` (show signs for all severities) |
| `virtual_text.source` | `'if_many'` |
| `virtual_text.spacing` | `2` |
| `virtual_text.format` | identity (just returns `diagnostic.message`) |
| `virtual_text.severity.min` | `HINT` |

## Mason setup

- `require('mason').setup({ ui = { border = 'rounded' } })`.
- `mason-tool-installer`: ensures every server in `M.servers` plus
  `sqlfluff` is installed.
- `mason-lspconfig`: `automatic_enable = false` -- we enable servers ourselves
  so per-server custom settings apply.

Fidget shows install progress with `notification.window.avoid = { 'NvimTree' }`
to prevent overlap with the file tree.

## How to add a new LSP server

1. Add a key to `M.servers` in `config.lua`. Empty table `{}` if you only need
   defaults. Otherwise include `settings`, `init_options`, `filetypes`,
   `on_attach`, or `capabilities` overrides.
2. The mason-tool-installer line will pick it up automatically (since it does
   `vim.tbl_keys(M.servers)`). Run `:Lazy reload nvim-lspconfig` then
   `:Mason` to install if it doesn't trigger on next start.
3. If the server requires a binary that Mason cannot install (e.g. system
   compilers), document it under "External setup" here.

To opt OUT of mason install for one server but keep the config, append its
name to a skip list before `mason-tool-installer.setup{}` (no such list
currently).

## sqls -- SQL LSP server

`sqls` provides hover, go-to-definition, and completion for SQL identifiers,
backed by live database connections.

### Connection config

Global connections live at `~/.config/sqls/config.yml`:

```yaml
lowercaseKeywords: false
connections:
  - alias: Local
    driver: postgresql
    dataSourceName: "host=localhost port=5432 user=postgres password=postgres dbname=mydb sslmode=disable"
  - alias: Prod
    driver: mysql
    dataSourceName: "user:pass@tcp(db.example.com:3306)/proddb"
```

Per-project connections override the global file at `<project_root>/.sqls/config.json`:

```json
{
  "lowercaseKeywords": false,
  "connections": [
    { "alias": "ProjectDb", "driver": "postgresql",
      "dataSourceName": "host=localhost port=5432 user=app password=secret dbname=app_dev sslmode=disable" }
  ]
}
```

### Commands (registered by sqls)

| Command | What it does |
| --- | --- |
| `:LspSqlsExecuteQuery` | run the query under the cursor / selection |
| `:LspSqlsSwitchConnection` | switch the active connection for this buffer |
| `:LspSqlsSwitchDatabase` | switch the active database within a connection |
| `:LspSqlsShowConnections` | list all configured connections |
| `:LspSqlsShowDatabases` | list databases in the active connection |
| `:LspSqlsShowTables` | list tables in the active database |
| `:LspSqlsShowSchemas` | list schemas |

### Formatting

The on_attach for sqls disables `documentFormattingProvider` and
`documentRangeFormattingProvider`. Formatting goes through conform
(`sqlfluff`) -- see `plugins/conform/`.

## References

- nvim-lspconfig: https://github.com/neovim/nvim-lspconfig
- mason.nvim: https://github.com/williamboman/mason.nvim
- mason-lspconfig.nvim: https://github.com/williamboman/mason-lspconfig.nvim
- mason-tool-installer.nvim: https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
- fidget.nvim: https://github.com/j-hui/fidget.nvim
- sqls: https://github.com/sqls-server/sqls
