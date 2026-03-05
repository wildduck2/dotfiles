local config = function()
  local lint = require 'lint'
  lint.linters_by_ft = {
    markdown = { 'markdownlint' },
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    javascriptreact = { 'eslint_d' },
    typescriptreact = { 'eslint_d' },
    lua = { 'luacheck' },
    python = { 'pylint' },
    go = { 'golangcilint' },
    dockerfile = { 'hadolint' },
    json = { 'jsonlint' },
  }

  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
      lint.try_lint()
    end,
  })
end

return config
