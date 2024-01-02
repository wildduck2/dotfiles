local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
    'tsserver',
    'rust_analyzer',
    'lua_ls',
    'rust_analyzer',
    'cssls',
    'bashls',
    'eslint',
    'html',
    'jsonls',
    'jdtls',
    'cssmodules_ls',
    'quick_lint_js',
    'tailwindcss',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()


local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

-- Enable chege while writing
lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        underline = true,
        virtual_text = {
            spacing = 5,
            severity_limit = 'Warning',
        },
        update_in_insert = true,
    }
)

-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lsp-zero')
local on_attach = lspconfig.on_attach
local capabilities = lspconfig.capabilities

--[[ lsp.configure('tsserver', {
    on_attach = on_attach,
    capabilities = capabilities,
    init_options = {
        preferences = {
            disableSuggestions = true
        }
    }
}) ]]

lsp.setup({
    tsserver = {
        filetypes = { "typescript", "typescriptreact" }, -- Specify the filetypes for this server
        on_attach = function(client, bufnr)
            -- Your custom on_attach function for tsserver
            local tsserver_opts = {
                -- Add any specific options for tsserver here
                -- For example:
                cmd = { "tsserver", "--stdio" }, -- Command to launch tsserver
                settings = {
                    -- Your tsserver settings go here
                },
                -- ... other options
            }

            -- Merge your custom options with the default options
            for key, value in pairs(tsserver_opts) do
                client[key] = value
            end

            -- Call the default on_attach function provided by lsp-zero
            lsp.on_attach(client, bufnr)
        end,
        capabilities = capabilities,
        init_options = {
            preferences = {
                disableSuggestions = true
            }
        }
    },
    tailwindcss = {
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
        on_attach = function(client, bufnr)
            local tailwindcss_opts = {
                -- Add any specific options for the Tailwind CSS LSP server here
                cmd = { "tailwindcss-lsp", "--stdio" }, -- Example command to launch the server
                settings = {
                    -- Your Tailwind CSS LSP server settings go here
                },
                -- ... other options
            }

            -- Merge your custom options with the default options
            for key, value in pairs(tailwindcss_opts) do
                client[key] = value
            end

            -- Call the default on_attach function provided by lsp-zero
            lsp.on_attach(client, bufnr)
        end,
    },
    --[[ prettier = {
        filetypes = { "javascript", "typescript", "css", "json", "html", "markdown" }, -- Add relevant filetypes
        on_attach = function(client, bufnr)
            local prettier_opts = {
                -- Add any specific options for the Prettier integration here
                cmd = { "prettier", "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), "--single-quote" },
                filetypes = { "javascript", "typescript", 'react', 'reacttypescript', "css", "json", "html", "markdown" },
                -- ... other options
            }

            -- Merge your custom options with the default options
            for key, value in pairs(prettier_opts) do
                client[key] = value
            end

            -- Call the default on_attach function provided by lsp-zero
            lsp.on_attach(client, bufnr)
        end,
    }, ]]
})


vim.diagnostic.config({
    virtual_text = true
})
