local servers= require('configs.lsp.servers')

local M = {}

-- Ensure the servers and tools above are installed
--  To check the current status of installed tools and/or manually install
--  other tools, you can run
--    :Mason

M.ensure_installed = vim.tbl_keys(servers or {
    "tsserver",
    "rust_analyzer",
    "lua_ls",
    "rust_analyzer",
    "cssls",
    "bashls",
    "eslint",
    "html",
    "jsonls",
    "jdtls",
    "cssmodules_ls",
    "quick_lint_js",
    "tailwindcss",
    "clangd",
    "bashls",
    "prismals",
    "graphql",
    "htmx",
    "prettier",
})


return M
