# lspconfig

`neovim/nvim-lspconfig` plus `mason.nvim`, `mason-lspconfig.nvim`,
`mason-tool-installer.nvim`, and `j-hui/fidget.nvim`. The heart of the LSP
setup: defines every server we use, the on-attach keymaps, diagnostic display,
and the mason install pipeline.

## Files

- `init.lua` -- spec + dependencies; calls
  `require('plugins.lsp.lspconfig.config').setup()`. Configures fidget with
  `notification.window.avoid = { 'NvimTree' }` so progress popups never
  overlap the file tree.
- `config.lua` -- the full setup. Owns:
  - `M.servers` -- table of LSP servers and their per-server config.
  - `on_attach(event)` -- registers buffer-local LSP keymaps, document
    highlighting, inlay hints toggle, signature-help autocmd, and the
    duck_sqllsp / biome capability overrides.
  - `M.setup()` -- creates the `LspAttach` autocmd, configures
    `vim.diagnostic`, installs servers via mason-tool-installer (excluding
    `duck_sqllsp` which is built from source), enables every server with our
    custom settings.

## Servers configured (`M.servers` keys)

Every server below is auto-installed via `mason-tool-installer` EXCEPT
`duck_sqllsp`, which lives at `~/.local/bin/duck-sqllsp` (built from the
`@duck-sqllsp` Rust workspace).

| Server | Filetypes | Custom settings |
| --- | --- | --- |
| `clangd` | c, c++ | `{}` defaults; see also `plugins/lang/clangd-extensions/` |
| `lua_ls` | lua | `runtime.version = LuaJIT`; `workspace.checkThirdParty = false`; `workspace.library` filled lazily in `setup()` with `${3rd}/luv/library` + `nvim_get_runtime_file('', true)`; `completion.callSnippet = 'Replace'` |
| `rust_analyzer` | rust | inlay hints (chaining, type, parameter) enabled |
| `ts_ls` | js/ts | `disableSuggestions = false`; `includeCompletionsForModuleExports = false`; `includeCompletionsWithObjectLiteralMethodSnippets = false`; `includePackageJsonAutoImports = 'off'`; `maxTsServerMemory = 4096`. Reduces tsserver load on large repos. |
| `tailwindcss` | -- | defaults |
| `cssls` | -- | defaults |
| `html` | -- | defaults |
| `jsonls` | -- | defaults |
| `yamlls` | -- | defaults |
| `prismals` | -- | defaults |
| `typos_lsp` | `markdown`, `text`, `gitcommit` | spell checker, restricted to prose filetypes |
| `biome` | -- | `capabilities.general.positionEncodings = { 'utf-16' }`. `on_attach` also strips biome diagnostics so ts_ls owns them. |
| `bashls` | -- | defaults |
| `dockerls` | -- | defaults |
| `docker_compose_language_service` | -- | defaults |
| `mdx_analyzer` | `mdx` | `init_options.typescript = {}` (uses local tsserver) |
| `duck_sqllsp` | `sql`, `mysql`, `plsql` | `cmd = { 'duck-sqllsp', 'server' }`. Built from source; connections are pushed in via `plugins/lang/dadbod/db_manager`. `on_attach` strips its `semanticTokensProvider` so tree-sitter remains the authoritative highlighter. |

## Global on_attach

`vim.api.nvim_create_autocmd('LspAttach', ...)` registers `on_attach`. For
every attaching client it does:

### LSP keymaps (buffer-local, prefixed `LSP:` in descriptions)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ca` | n | `vim.lsp.buf.code_action` |
| `<leader>rn` | n | `vim.lsp.buf.rename` |
| `gr` | n | telescope `lsp_references` |
| `gI` | n | telescope `lsp_implementations` |
| `gd` | n | telescope `lsp_definitions` |
| `gD` | n | `vim.lsp.buf.declaration` |
| `<leader>ds` | n | telescope `lsp_document_symbols` |
| `<leader>ws` | n | telescope `lsp_dynamic_workspace_symbols` |
| `<leader>D` | n | telescope `lsp_type_definitions` |
| `K` | n | `vim.lsp.buf.hover` (default float — no custom border / overlay) |
| `<C-s>` | i | `vim.lsp.buf.signature_help` |

### Signature-help autocmd

If the attaching client advertises `signatureHelpProvider`, a buffer-local
`TextChangedI` autocmd fires `vim.lsp.buf.signature_help()` whenever the
character just typed matches the server's `triggerCharacters` (defaults to
`(` and `,`). Registered once per buffer via
`vim.b[buf]._lsp_sighelp_registered` so multiple LSPs do not stack
duplicates.

### Biome diagnostics override

If `client.name == 'biome'`, sets
`client.server_capabilities.diagnosticProvider = nil` so ts_ls owns JS/TS
diagnostics (avoids double-reporting).

### duck_sqllsp highlights override

If `client.name == 'duck_sqllsp'`, sets
`client.server_capabilities.semanticTokensProvider = nil`. duck-sqllsp
advertises semantic tokens, but the tree-sitter SQL parser (see
`parser/sql.so` + `queries/sql/`) has richer coverage. Dropping the LSP
provider leaves tree-sitter as the sole highlighter.

### Document highlight

If the client supports `textDocument/documentHighlight` and the buffer
hasn't been registered yet, creates `kickstart-lsp-highlight` autocmd group:

- `CursorHold` -> `vim.lsp.buf.document_highlight`
- `CursorMoved` -> `vim.lsp.buf.clear_references`
- `LspDetach` -> clear references + tear down autocmds.

Buffer-local flag (`vim.b[buf]._lsp_highlight_registered`) prevents
duplicate registration when multiple LSPs attach to the same buffer.

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
| `virtual_text.format` | identity (returns `diagnostic.message`) |
| `virtual_text.severity.min` | `HINT` |

## Mason setup

- `require('mason').setup({ ui = { border = 'rounded' } })`.
- `mason-tool-installer`: ensures every server in `M.servers` is installed,
  EXCEPT `duck_sqllsp` (built externally — see below).
- `mason-lspconfig`: `automatic_enable = false` — we enable servers ourselves
  so per-server custom settings apply.

Fidget shows install progress; its window-avoid list keeps notifications
clear of the nvim-tree sidebar.

## How to add a new LSP server

1. Add a key to `M.servers` in `config.lua`. Empty table `{}` if only
   defaults are needed; otherwise include `settings`, `init_options`,
   `filetypes`, `on_attach`, or `capabilities` overrides.
2. mason-tool-installer auto-picks it up via `vim.tbl_keys(M.servers)`
   (minus duck_sqllsp). Run `:Lazy reload nvim-lspconfig` then `:Mason` if
   the install does not trigger on next start.
3. If the server requires a binary Mason cannot install, add a guard like
   the duck_sqllsp skip and document the external install here.

## duck_sqllsp — native SQL language server

Lives at `@duck-sqllsp` (separate Rust workspace). Binary expected at
`~/.local/bin/duck-sqllsp`. Build with `cargo install --path .` from that
workspace, or `install -m 0755 target/release/duck-sqllsp ~/.local/bin/`.

Connections are NOT configured via a YAML file. They are pushed in by
`plugins/lang/dadbod/db_manager` at LspAttach time so the SQL LS sees the
same connection list as dadbod-ui.

Formatting also routes through duck_sqllsp (conform has no SQL formatter
entry; its `format_after_save` returns `{ lsp_fallback = 'always' }` for SQL
filetypes — see `plugins/conform/`).

Diagnostics are reported by duck_sqllsp directly; `nvim-lint` has no SQL
entry.

## References

- nvim-lspconfig: https://github.com/neovim/nvim-lspconfig
- mason.nvim: https://github.com/williamboman/mason.nvim
- mason-lspconfig.nvim: https://github.com/williamboman/mason-lspconfig.nvim
- mason-tool-installer.nvim: https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
- fidget.nvim: https://github.com/j-hui/fidget.nvim
