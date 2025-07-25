-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  ---- NOTE: First, some plugins that don't require any configuration

  -- Lualine
  {
    'nvim-lualine/lualine.nvim',
  },

  -- Cloak
  {
    'laytan/cloak.nvim',
  },

  -- Harpoon
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { { 'nvim-lua/plenary.nvim' } },
  },

  -- Color scheme
  {
    "tjdevries/colorbuddy.nvim",
    priority = 1001,
    config = function()
      vim.cmd.colorscheme "gruvbuddy"
    end,
  },
  {
    'catppuccin/nvim',
    priority = 1000,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'rose-pine/neovim',
    as = 'rose-pine',
  },
  {
    'navarasu/onedark.nvim',
    as = 'onedark',
  },

  -- Zen mode
  {
    'folke/zen-mode.nvim',
  },

  -- Comment
  {
    'numToStr/Comment.nvim',
    lazy = false,
  },

  -- Plenary
  { 'nvim-lua/plenary.nvim' },

  -- -- Undotree
  { 'mbbill/undotree' },

  -- floke todo
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { sings = false },
  },

  -- trouble
  {
    'folke/trouble.nvim',
    opts = {},
    cmd = 'Trouble',
  },
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
  },

  -- Treesitter
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/playground',
      -- "nvim-treesitter/nvim-treesitter-context",
    },
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
    },
  },

  -- Codeium completion
  {
    'Exafunction/codeium.vim',
  },

  --Null-ls
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = 'VeryLazy',
  },

  -- Git related plugins
  { 'tpope/vim-fugitive' },

  -- Nvim tree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
  },

  -- Fancey vim
  {
    'eandrju/cellular-automaton.nvim',
  },

  -- presence
  {
    'andweeb/presence.nvim',
  },

  {
    'vyfor/cord.nvim',
    build = './build',
    event = 'VeryLazy',
    opts = {},
  },

  -- LSP
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'MunifTanjim/prettier.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       opts = {} },
    },
  },
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-cmdline' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },

      -- Snippets
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
    },
  },

  -- Tmux navigate
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
  },

  -- Detect tabstop and shiftwidth automatically
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
  },
  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require 'configs.linting'
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    configs = require 'configs.mini',
  },
  {                     -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  },

  {
    'xiyaowong/transparent.nvim',
  },

  {
    'letieu/hacker.nvim',
  },
  {
    'ty-labs/randiverse.nvim',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
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
    'windwp/nvim-ts-autotag',
  },

  -- selicon snap
  {
    'michaelrommel/nvim-silicon',
    lazy = true,
    cmd = 'Silicon',
  },
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
  {
    'davidmh/mdx.nvim',
    config = true,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',

      -- see below for full list of optional dependencies 👇
    },
  },
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    'simrat39/rust-tools.nvim',
    config = function()
      local rt = require("rust-tools")

      rt.setup({
        server = {
          on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
          end,
        },
      })
    end
  },

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = require 'configs.mini',
  },

  -- DB
  {
    'kndndrj/nvim-dbee',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require('dbee').install()
    end,
  },

  -- -- Debug
  -- {
  --     -- NOTE: Yes, you can install new plugins here!
  --     'mfussenegger/nvim-dap',
  --     -- NOTE: And you can specify dependencies as well
  --     dependencies = {
  --         -- Creates a beautiful debugger UI
  --         'rcarriga/nvim-dap-ui',
  --
  --         -- Required dependency for nvim-dap-ui
  --         'nvim-neotest/nvim-nio',
  --
  --         -- Installs the debug adapters for you
  --         'williamboman/mason.nvim',
  --         'jay-babu/mason-nvim-dap.nvim',
  --
  --         -- Add your own debuggers here
  --         'leoluz/nvim-dap-go',
  --     },
  --     keys = function(_, keys)
  --         require('configs.dap').keys(_, keys)
  --     end,
  --     config = function()
  --         require('configs.dap').config()
  --     end,
  -- },
}

---@diagnostic disable-next-line: missing-fields
require('lazy').setup(plugins, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
