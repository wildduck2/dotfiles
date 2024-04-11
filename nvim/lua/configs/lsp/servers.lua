local M = {}

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. Available keys are:
--  - cmd (table): Override the default command used to start the server
--  - filetypes (table): Override the default list of associated filetypes for the server
--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--  - settings (table): Override the default settings passed when initializing the server.
--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
--
-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP Specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

M.servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`tsserver`) will work just fine
    tsserver = {
        capabilities = M.capabilities_final,
        formatting = {
            format_opts = {
                async = true,
            },
        },
        init_options = {
            preferences = {
                disableSuggestions = true,
            },
        },
    },

    lua_ls = {
        -- cmd = {...},
        -- filetypes { ...},
        -- capabilities = {},
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                workspace = {
                    checkThirdParty = false,
                    -- Tells lua_ls where to find all the Lua files that you have loaded
                    -- for your neovim configuration.
                    library = {
                        "${3rd}/luv/library",
                        unpack(vim.api.nvim_get_runtime_file("", true)),
                    },
                    -- If lua_ls is really slow on your computer, you can try this instead:
                    -- library = { vim.env.VIMRUNTIME },
                },
                completion = {
                    callSnippet = "Replace",
                },
                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- diagnostics = { disable = { 'missing-fields' } },
            },
        },
    },
    elixir = {
        -- // here we specify the path we built our elixir-ls,
        -- // here we setup this in home directory,
        -- //make sure you are pointing to right path
        -- cmd = { "/home/nishanth/.elixir-ls/release/language_server.sh" },
        cmd = { "elixir-ls", "--stdio" },
        settings = {
            elixirLS = {
                dialyzerEnabled = true,
                fetchDeps = true,
            }
        }
    },
    eslint_d ={
        settings = {
            -- helps eslint find the correct project root
            workingDirectory = {
                mode = 'root',
            },
        },
    }
}

return M
