# rust

Two specs: `rust.vim` for filetype/format-on-save, `rustaceanvim` for the LSP
+ extras.

NOTE: this module is currently NOT included in `plugins/lang/init.lua` -- the
`add 'plugins.lang.rust'` line is commented out. The `rust_analyzer` LSP is
still set up via `plugins/lsp/lspconfig/config.lua`, so editing rust files
works without rustaceanvim's keymaps. Uncomment the include line to enable
this module.

## Files

- `init.lua` -- two specs:
  - `rust-lang/rust.vim` -- enables `vim.g.rustfmt_autosave = 1`.
  - `mrcjkb/rustaceanvim` -- `version = false` (always latest), `lazy = false`
    because the plugin handles its own lazy-loading on `ft = rust`.
- `config.lua` -- sets `vim.g.rustaceanvim` with tools, server settings, and
  the rust-specific `on_attach`.

## Keymaps (when enabled, inside rust buffers)

| Key | Action |
| --- | --- |
| `<leader>ca` | `RustLsp codeAction` (grouped) |
| `K` | `RustLsp hover actions` |
| `<leader>rd` | `RustLsp debuggables` |
| `<leader>rr` | `RustLsp runnables` |
| `<leader>rt` | `RustLsp testables` |
| `<leader>rm` | `RustLsp expandMacro` |
| `<leader>rc` | `RustLsp openCargo` |
| `<leader>rp` | `RustLsp parentModule` |
| `<leader>rj` | `RustLsp joinLines` |
| `<leader>re` | `RustLsp explainError` |
| `<leader>rD` | `RustLsp renderDiagnostic` |
| `<leader>rk` | `RustLsp moveItem up` |
| `<leader>rl` | `RustLsp moveItem down` |
| `<leader>rH` | `RustLsp view hir` |
| `<leader>rM` | `RustLsp view mir` |

## Configurable knobs

`vim.g.rustaceanvim`:

| Path | Value | Notes |
| --- | --- | --- |
| `tools.executor` | `'toggleterm'` | Runnables open in toggleterm. |
| `tools.test_executor` | `'background'` | Failed tests appear as diagnostics. |
| `tools.hover_actions.auto_focus` | `true` | Focus hover popup automatically. |
| `tools.code_actions.ui_select_fallback` | `true` | Use `vim.ui.select` if needed (telescope-ui-select). |
| `server.default_settings['rust-analyzer'].diagnostics.enable` | `true` | -- |
| `... checkOnSave` | `true` | Run check on save. |
| `... check.command` | `'clippy'` | Use clippy on save. |
| `... procMacro.enable` | `true` | -- |
| `... inlayHints` | type, parameter, chaining all `true` | -- |
| `... cargo.allFeatures` | `true` | -- |
| `... cargo.loadOutDirsFromCheck` | `true` | -- |

## External setup

- `rustup` toolchain installed (so `rust-analyzer`, `cargo`, `rustfmt`,
  `clippy` are available).
- `vim.g.rustfmt_autosave = 1` makes rust.vim format on save. With conform
  also doing `rust = { 'rustfmt', lsp_format = 'fallback' }`, you may want to
  pick one (set this to 0 if you only want conform).

## References

- rustaceanvim: https://github.com/mrcjkb/rustaceanvim
- rust.vim: https://github.com/rust-lang/rust.vim
