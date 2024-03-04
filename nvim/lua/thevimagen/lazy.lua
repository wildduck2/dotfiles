-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    ---- NOTE: First, some plugins that don't require any configuration

    ---- Git related plugins
    { "tpope/vim-fugitive" },

    ---- Detect tabstop and shiftwidth automatically
    { "theprimeagen/refactoring.nvim" },
    {
        -- Set lualine as statusline
        "nvim-lualine/lualine.nvim",
        -- See `:help lualine.txt`
        opts = require("configs.lualine"),
    },

    {
        -- Add indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help ibl`
        main = "ibl",
        opts = require("configs.iblconf"),
        config = function()
            require("ibl").setup()
        end,
    },

    {
        -- Zen mode
        "folke/zen-mode.nvim",
        opts = require("configs.zenmode"),
    },

    -- "gc" to comment visual regions/lines
    {
        "numToStr/Comment.nvim",
        opts = require("configs.comment"),
        config = function()
            require("Comment").setup()
        end,
    },

    -- Harpoon
    { "nvim-lua/plenary.nvim" },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },
    {
        -- Catppuccin theme
        "catppuccin/nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },
    --[[ {
        'rose-pine/neovim',
        as = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    }, ]]

    --[[     {
        'navarasu/onedark.nvim',
        as = 'onedark',
        config = function()
            vim.cmd('colorscheme onedark')
        end
    }, ]]

    ---- Undotree
    { "mbbill/undotree" },

    {
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
            { "nvim-telescope/telescope-ui-select.nvim" },
        },
        config = require("configs.telescope"),
    },

    {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/playground",
            "nvim-treesitter/nvim-treesitter-context",
        },
    },

    -- Codeium completion
    {
        "Exafunction/codeium.vim",
        config = function()
            -- Change '<C-g>' here to any keycode you like.
            vim.keymap.set("i", "<C-g>", function()
                return vim.fn["codeium#Accept"]()
            end, { expr = true })
            vim.keymap.set("i", "<c-;>", function()
                return vim.fn["codeium#CycleCompletions"](1)
            end, { expr = true })
            vim.keymap.set("i", "<c-,>", function()
                return vim.fn["codeium#CycleCompletions"](-1)
            end, { expr = true })
            vim.keymap.set("i", "<c-x>", function()
                return vim.fn["codeium#Clear"]()
            end, { expr = true })
        end,
    },

    -- Other plugins
    {
        "eandrju/cellular-automaton.nvim",
        "laytan/cloak.nvim",
    },
    --Null-ls
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = "VeryLazy",
        --opts =  require("configs.null-ls")
    },

    -- LSP Zero
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for neovim
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",

            -- Useful status updates for LSP.
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { "j-hui/fidget.nvim", opts = {} },
        },
        config = require("configs.lsp"),
    },
    -- { -- Autoformat
    --     "stevearc/conform.nvim",
    --     opts = {
    --         notify_on_error = false,
    --         format_on_save = {
    --             timeout_ms = 500,
    --             lsp_fallback = true,
    --         },
    --         formatters_by_ft = {
    --             -- lua = { "stylua" },
    --             -- Conform can also run multiple formatters sequentially
    --             -- python = { "isort", "black" },
    --             --
    --             -- You can use a sub-list to tell conform to run *until* a formatter
    --             -- is found.
    --             -- javascript = { { "prettierd", "prettier" } },
    --         },
    --     },
    -- },

    { -- Autocompletion
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            {
                "L3MON4D3/LuaSnip",
                build = (function()
                    -- Build Step is needed for regex support in snippets
                    -- This step is not supported in many windows environments
                    -- Remove the below condition to re-enable on windows
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
            },
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-cmdline" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
        },
    },

    { -- Collection of various small independent plugins/modules
        "echasnovski/mini.nvim",
        configs = require("configs.mini"),
    },
    {                        -- Useful plugin to show you pending keybinds.
        "folke/which-key.nvim",
        event = "VimEnter",  -- Sets the loading event to 'VimEnter'
        configs = function() -- This is the function that runs, AFTER loading
            require("which-key").setup()

            -- Document existing key chains
            require("which-key").register({
                ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
                ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
                ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
                ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
                ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
            })
        end,
    },

    -- Auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {}, -- this is equalent to setup({}) function
    },

    -- Auto tag
    "windwp/nvim-ts-autotag",
    "tmsvg/pear-tree",

    -- Tmux navigate
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },
    -- file managing , picker etc
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    },

    -- floke todo
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = require("configs.todo-comments"),
    },

    -- trouble
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        --opts = require("configs.trouble")
    },
}

require("lazy").setup(plugins, {})
