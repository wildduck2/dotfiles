-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- NOTE: First, some plugins that don't require any configuration
  ----------------------------------------------------------------------
  --                      Aesthetic & UI Plugins                    --
  ----------------------------------------------------------------------

  -- Color schemes
  {
    'tjdevries/colorbuddy.nvim',
    priority = 1001,
    config = function()
      vim.cmd.colorscheme 'gruvbuddy'
    end,
  },
  { 'tjdevries/gruvbuddy.nvim' },
  { 'catppuccin/nvim', priority = 1000 },
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000, opts = {} },
  { 'rose-pine/neovim', as = 'rose-pine' },
  { 'navarasu/onedark.nvim', as = 'onedark' },
  { 'rebelot/kanagawa.nvim', as = 'kanagawa' },

  -- UI Components & Enhancements
  { 'nvim-lualine/lualine.nvim' }, -- Lualine
  { 'nvim-tree/nvim-web-devicons' }, -- Useful for getting pretty icons, but requires a Nerd Font.
  -- Terminal tab
  { 'akinsho/toggleterm.nvim', version = '*', opts = { direction = 'tab' } },

  -- Visual Modes
  { 'folke/zen-mode.nvim' }, -- Zen mode
  { 'xiyaowong/transparent.nvim' },
  { 'letieu/hacker.nvim' },
  { 'ty-labs/randiverse.nvim', version = '*' },
  { 'eandrju/cellular-automaton.nvim' }, -- Fancey vim

  -- Indentation
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
  },

  ----------------------------------------------------------------------
  --                          Core Utilities                       --
  ----------------------------------------------------------------------

  { 'nvim-lua/plenary.nvim' }, -- Plenary (Dependency for many plugins)
  { 'mbbill/undotree' }, -- Undotree
  { 'tpope/vim-fugitive' }, -- Git related plugins
  { 'christoomey/vim-tmux-navigator', lazy = false }, -- Tmux navigate

  ----------------------------------------------------------------------
  --                          Search & File Tree                   --
  ----------------------------------------------------------------------

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
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
  },

  -- Nvim tree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
  },

  -- Harpoon
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { { 'nvim-lua/plenary.nvim' } },
  },

  ----------------------------------------------------------------------
  --                      Treesitter & Syntax                       --
  ----------------------------------------------------------------------

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

  -- Auto tag
  { 'windwp/nvim-ts-autotag' },

  ----------------------------------------------------------------------
  --                      Editing & Text Manipulation              --
  ----------------------------------------------------------------------

  { 'laytan/cloak.nvim' }, -- Cloak

  -- Comment
  { 'terrortylor/nvim-comment', lazy = false },
  { 'JoosepAlviste/nvim-ts-context-commentstring' },

  {
    'ThePrimeagen/refactoring.nvim', -- Detect tabstop and shiftwidth automatically
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },

  ----------------------------------------------------------------------
  --                       LSP, Formatting, & Linting              --
  ----------------------------------------------------------------------

  -- LSP Core
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
      { 'j-hui/fidget.nvim', opts = {} },
    },
  },

  { 'hedyhli/outline.nvim' },

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

  -- Formatting
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require 'configs.linting'
    end,
  },

  -- LSP Enhancements
  { 'VidocqH/lsp-lens.nvim' }, -- LSP lens/code annotations

  -- {
  --   'ray-x/telescope-ast-grep.nvim',
  --   dependencies = {
  --     { 'nvim-lua/plenary.nvim' },
  --     { 'nvim-telescope/telescope.nvim' },
  --   },
  -- },

  ----------------------------------------------------------------------
  --                         Autocompletion                        --
  ----------------------------------------------------------------------

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

      -- Autocompletion Sources
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-cmdline' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },

      -- Snippets
      { 'rafamadriz/friendly-snippets' },
    },
  },

  -- AI/Copilot-like
  { 'supermaven-inc/supermaven-nvim' },
  -- -- Codeium completion
  -- {
  --   'Exafunction/codeium.vim',
  -- },

  ----------------------------------------------------------------------
  --                      Project & Workflow Aids                   --
  ----------------------------------------------------------------------

  -- Git
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

  -- Task/Error Management
  {
    'folke/todo-comments.nvim', -- floke todo
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'folke/trouble.nvim', -- trouble
    opts = {},
    cmd = 'Trouble',
  },

  -- Keymaps
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  },

  -- Discord/Presence
  { 'andweeb/presence.nvim' },
  { 'vyfor/cord.nvim', build = './build', event = 'VeryLazy', opts = {} },

  ----------------------------------------------------------------------
  --                     Language-Specific Plugins                  --
  ----------------------------------------------------------------------

  -- Rust
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
      local rt = require 'rust-tools'
      rt.setup()
    end,
  },

  -- Clang
  { 'p00f/clangd_extensions.nvim' },

  -- Package Info (e.g., npm)
  {
    'vuki656/package-info.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
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

  ----------------------------------------------------------------------
  --                      Markdown & Note-Taking                   --
  ----------------------------------------------------------------------

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
    'davidmh/mdx.nvim',
    config = true,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'toppair/peek.nvim',
    event = { 'VeryLazy' },
    build = 'deno task --quiet build:fast',
    config = function()
      require('peek').setup()
      vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
      vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    end,
  },

  ----------------------------------------------------------------------
  --                      Miscellaneous & Utility                   --
  ----------------------------------------------------------------------

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = require 'configs.mini',
  },

  { 'kevinhwang91/promise-async' },
  { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' },

  {
    'michaelrommel/nvim-silicon', -- selicon snap
    lazy = true,
    cmd = 'Silicon',
  },

  -- Auto pairs
  -- {
  --     "windwp/nvim-autopairs",
  --     event = "InsertEnter",
  --     opts = {}, -- this is equalent to setup({}) function
  -- },
  -- "tmsvg/pear-tree",

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
