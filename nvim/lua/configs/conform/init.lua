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
  },
  format_on_save = {
    lsp_fallback = true,
    timeout_ms = 500,
  },
}

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(args)
    vim.lsp.buf.format()
    require('conform').format { bufnr = args.buf }
  end,
})
