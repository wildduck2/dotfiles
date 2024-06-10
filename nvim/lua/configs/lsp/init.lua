local callback = require("configs.lsp.callback").callback
local servers = require("configs.lsp.servers").servers
local ensure__installedF = require("configs.lsp.ensure_install")

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
    callback = callback,
})

vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = {
            -- Use the new syntax for specifying severity
            severity = { min = vim.diagnostic.severity.Warning },
        },
        underline = false,
        update_in_insert = false,
        virtual_text = {
            spacing = 2,
            -- Similarly, use the new syntax for specifying severity
            severity = { min = vim.diagnostic.severity.Warning },
        },
    }
)
-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP Specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

--  You can press `g?` for help in this menu
require("mason").setup()

-- You can add other tools here that you want Mason to install
-- for you, so that they are available from within Neovim.
local ensure__installed = vim.tbl_keys(servers or ensure__installedF)
vim.list_extend(ensure__installedF, {})

require("mason-tool-installer").setup({ ensure_installed = ensure__installed })

require("mason-lspconfig").setup({
    handlers = {
        function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
        end,
    },
})
