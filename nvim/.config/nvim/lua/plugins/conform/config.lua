local M = {}

function M.setup()
  local custom_formatters = require 'plugins.conform.formatters'
  local conform = require 'conform'

  conform.setup {
    notify_on_error = true, -- Show error notifications on format fail
    formatters = custom_formatters, -- Custom formatter overrides

    -- Formatter(s) per filetype; runs in listed order
    formatters_by_ft = {
      lua = { 'stylua' },
      c = { 'clang_format' },
      cpp = { 'clang_format' },
      -- TODO: add 'docformatter' when untokenize supports Python 3.14+
      python = { 'isort', 'black' }, -- Sort imports, then format
      go = { 'goimports', 'gofmt' }, -- Fix imports, then format
      rust = { 'rustfmt', lsp_format = 'fallback' }, -- Use LSP if rustfmt unavailable
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
      mdx = { 'prettier' },
      bash = { 'shfmt' },
      sh = { 'shfmt' },
    },

    -- Async format after save; won't freeze editor on slow formatters
    format_after_save = function(bufnr)
      local available = conform.list_formatters(bufnr)
      if #available == 0 then
        return
      end
      return {
        lsp_fallback = true, -- Fall back to LSP formatting
      }
    end,
  }

  -- Manual format keymap (normal + visual mode)
  vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
    conform.format {
      lsp_fallback = true,
      timeout_ms = 1000,
    }
  end, { desc = '[F]ormat buffer' })
end

return M
