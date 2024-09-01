local conform = require("conform")

conform.setup({
    notify_on_error = false,
    formatters_by_ft = {
        lua = { "stylua" },
        -- Conform can also run multiple formatters sequentially
        python = { "isort", "black" },

        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        javascript = { { "prettierd", "prettier" } },
    },

    format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = 'never'
        else
            lsp_format_opt = 'fallback'
        end
        return {
            timeout_ms = 500,
            lsp_format = lsp_format_opt,
        }
    end,
})


