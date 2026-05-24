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
      -- SQL formatting handled by duck_sqllsp via LSP; conform stays out.
    },

    -- Format after save; falls back to LSP when conform has no formatter
    -- (used by SQL via duck-sqllsp, Rust via rust-analyzer, etc.).
    format_after_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype
      local available = conform.list_formatters(bufnr)
      if #available == 0 then
        if ft == 'sql' or ft == 'plsql' or ft == 'psql' then
          return { lsp_fallback = 'always' }
        end
        return
      end
      return { lsp_fallback = true }
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
