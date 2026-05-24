# clangd-extensions

`p00f/clangd_extensions.nvim` -- clangd-only extras: AST viewer, memory usage,
symbol info. Loaded on `ft = { 'c', 'cpp' }`.

## Files

- `init.lua` -- spec; `opts` returns the table in `config.lua`.
- `config.lua` -- icons + border options.

## Commands

The plugin registers these:

- `:ClangdAST` -- show the AST of the current node.
- `:ClangdSymbolInfo` -- LSP symbol info.
- `:ClangdMemoryUsage` -- clangd memory usage.
- `:ClangdTypeHierarchy` -- type hierarchy view.
- `:ClangdSwitchSourceHeader` -- jump between `.c` and `.h`.

## Configurable knobs

| Option | Value |
| --- | --- |
| `ast.role_icons` | nerd font icons for `type`, `declaration`, `expression`, `specifier`, `statement`, `template argument` |
| `ast.kind_icons` | icons for `Compound`, `Recovery`, `TranslationUnit`, `PackExpansion`, `TemplateTypeParm`, `TemplateTemplateParm`, `TemplateParamObject` |
| `ast.highlights.detail` | `'Comment'` |
| `memory_usage.border` | `'rounded'` |
| `symbol_info.border` | `'rounded'` |

## References

- https://github.com/p00f/clangd_extensions.nvim
