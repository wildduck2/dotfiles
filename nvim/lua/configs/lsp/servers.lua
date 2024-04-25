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
    elixirls = {
        cmd = { "elixir-ls", "--stdio" },
        -- on_attach = custom_attach, -- this may be required for extended functionalities of the LSP
        -- capabilities = capabilities,
        flags = {
            debounce_text_changes = 150,
        },
        elixirLS = {
            dialyzerEnabled = false,
            fetchDeps = false,
        },
    },
    eslint_d = {
        settings = {
            -- helps eslint find the correct project root
            workingDirectory = {
                mode = 'root',
            },
        },
    },
    -- tailwindcss = {
    --     -- cmd = { "tailwindcss-language-server", "--stdio" },
    --     cmd = {
    --         "/home/wild_duck/.local/share/nvim/lsp_servers/vscode-eslint/node_modules/vscode-langservers-extracted/bin/vscode-eslint-language-server",
    --         "--stdio",
    --     },
    --     -- filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    --     root_dir = require('lspconfig').util.root_pattern("tailwind.config.js", "package.json"),
    --     settings = {},
    -- }
    tailwindcss = {
        init_options = {
            userLanguages = {
                heex = "html-eex",
                elixir = "html-eex",
            },
        },
        settings = {
            tailwindCSS = {
                experimental = {
                    classRegex = {
                        'class[:]\\s*"([^"]*)"',
                    },
                },
            },
        },
    },
    cssls = {
        settings = {
        }
    }
}


return M
