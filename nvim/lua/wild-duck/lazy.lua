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

    -- Lualine
    {
        "nvim-lualine/lualine.nvim",
    },

    -- Cloak
    {
        "laytan/cloak.nvim",
    },

    -- Harpoon
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },

    -- Color scheme
    {
        "catppuccin/nvim",
        priority = 1000,
    },

    -- Tokyonight
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },

    {
        "rose-pine/neovim",
        as = "rose-pine",
    },

    -- onedark
    {
        "navarasu/onedark.nvim",
        as = "onedark",
    },

    -- Zen mode
    {
        "folke/zen-mode.nvim",
    },

    -- Comment
    {
        "numToStr/Comment.nvim",
        lazy = false,
    },

    -- Plenary
    { "nvim-lua/plenary.nvim" },

    -- -- Undotree
    { "mbbill/undotree" },

    -- floke todo
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- trouble
    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
    },
    -- {
    --     "folke/trouble.nvim",
    --     opts = {}, -- for default options, refer to the configuration section for custom setup.
    --     cmd = "Trouble",
    --     keys = {
    --         {
    --             "<leader>xx",
    --             "<cmd>Trouble diagnostics toggle<cr>",
    --             desc = "Diagnostics (Trouble)",
    --         },
    --         {
    --             "<leader>xX",
    --             "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    --             desc = "Buffer Diagnostics (Trouble)",
    --         },
    --         {
    --             "<leader>cs",
    --             "<cmd>Trouble symbols toggle focus=false<cr>",
    --             desc = "Symbols (Trouble)",
    --         },
    --         {
    --             "<leader>cl",
    --             "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
    --             desc = "LSP Definitions / references / ... (Trouble)",
    --         },
    --         {
    --             "<leader>xL",
    --             "<cmd>Trouble loclist toggle<cr>",
    --             desc = "Location List (Trouble)",
    --         },
    --         {
    --             "<leader>xQ",
    --             "<cmd>Trouble qflist toggle<cr>",
    --             desc = "Quickfix List (Trouble)",
    --         },
    --     },
    -- },

    -- Treesitter
    {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/playground",
            -- "nvim-treesitter/nvim-treesitter-context",
        },
    },

    -- Telescope
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
    },

    -- Codeium completion
    {
        "Exafunction/codeium.vim",
    },

    --Null-ls
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = "VeryLazy",
    },

    -- Git related plugins
    { "tpope/vim-fugitive" },

    -- Nvim tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    },

    -- Fancey vim
    {
        "eandrju/cellular-automaton.nvim",
    },

    -- presence
    {
        "andweeb/presence.nvim",
    },

    {
        'vyfor/cord.nvim',
        build = './build',
        event = 'VeryLazy',
        opts = {},
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for neovim
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            'MunifTanjim/prettier.nvim',

            -- Useful status updates for LSP.
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { "j-hui/fidget.nvim", opts = {} },
        },
    },

    -- Autocompletion
    {
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

    -- Tmux navigate
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },

    -- Detect tabstop and shiftwidth automatically
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
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

    -- { -- Autoformat
    -- 	"stevearc/conform.nvim",
    -- 	opts = {},
    -- },

    { -- Collection of various small independent plugins/modules
        "echasnovski/mini.nvim",
        configs = require("configs.mini"),
    },

    {                       -- Useful plugin to show you pending keybinds.
        "folke/which-key.nvim",
        event = "VimEnter", -- Sets the loading event to 'VimEnter'
        -- configs = require('configs.which-key') -- This is the function that runs, AFTER loading
    },

    {
        "xiyaowong/transparent.nvim",
    },

    {
        "letieu/hacker.nvim",
    },
    {
        "ty-labs/randiverse.nvim",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
    },
    -- Auto pairs
    -- {
    --     "windwp/nvim-autopairs",
    --     event = "InsertEnter",
    --     opts = {}, -- this is equalent to setup({}) function
    -- },
    -- "tmsvg/pear-tree",

    -- Auto tag
    {
        "windwp/nvim-ts-autotag",
    },

    -- selicon snap
    {
        "michaelrommel/nvim-silicon",
        lazy = true,
        cmd = "Silicon",
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
    }
}

require("lazy").setup(plugins, {})
