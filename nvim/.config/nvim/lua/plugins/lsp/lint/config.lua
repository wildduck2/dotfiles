local M = {}

function M.setup()
  local lint = require 'lint'

  -- Map filetypes to their linter(s)
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
  }

  -- clear=true prevents duplicate autocmds on re-source
  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  -- Lint on save and after leaving insert mode
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    -- Only run linters whose binary is installed
    callback = function()
      local ft = vim.bo.filetype
      local linters = lint.linters_by_ft[ft] or {}
      for _, name in ipairs(linters) do
        -- pcall guards against missing linter definitions
        local ok, linter = pcall(function() return lint.linters[name] end)
        if ok and linter then
          -- Resolve cmd (can be string or function)
          local cmd = type(linter.cmd) == 'function' and linter.cmd() or linter.cmd
          -- Skip if binary not found in PATH
          if cmd and vim.fn.executable(cmd) == 1 then
            lint.try_lint(name)
          end
        end
      end
    end,
  })
end

return M
