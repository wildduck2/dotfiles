local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")

-- -- Here is the formatting config
-- local lSsources = {
--     null_ls.builtins.formatting.prettier.with({
--         filetypes = {
--             "javascript",
--             "typescript",
--             "css",
--             "scss",
--             "html",
--             "json",
--             "yaml",
--             "markdown",
--             "graphql",
--             "md",
--             "txt",
--         },
--     }),
--     null_ls.builtins.formatting.stylua,
-- }
-- null_ls.setup({
--     sources = lSsources,
-- })
-- vim.cmd("autocmd BufWritePost * lua vim.lsp.buf.formatting_seq_sync()")

local opts = {
    sources = {
        null_ls.builtins.formatting.prettierd,
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({
                group = augroup,
                buffer = bufnr,
            })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
}
null_ls.setup(opts)
