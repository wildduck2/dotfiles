local conform = require 'conform'
local formatters = require 'configs.conform.ftformatter'

conform.setup {
  notify_on_error = true,
  formatters = formatters,
  formatters_by_ft = {
    lua = { 'stylua' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    python = { 'isort', 'black' },
    go = { 'goimports', 'gofmt' },
    rust = { 'rustfmt', lsp_format = 'fallback' },
    javascript = { 'biome' },
    typescript = { 'biome' },
    javascriptreact = { 'biome' },
    typescriptreact = { 'biome' },
    json = { 'biome' },
    html = { 'prettier' },
    css = { 'prettier' },
    scss = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    bash = { 'shfmt' },
    sh = { 'shfmt' },
  },
  format_on_save = {
    lsp_fallback = true,
    timeout_ms = 1000,
  },
}
