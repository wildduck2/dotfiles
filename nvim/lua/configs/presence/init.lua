-- The setup config table shows all available config options with their default values:
-- require("presence").setup({
--     -- General options
--     auto_update         = true,                       -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
--     neovim_image_text   = "The One True Text Editor", -- Text displayed when hovered over the Neovim image
--     main_image          = "neovim",                   -- Main image display (either "neovim" or "file")
--     client_id           = "793271441293967371",       -- Use your own Discord application client id (not recommended)
--     log_level           = nil,                        -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
--     debounce_timeout    = 10,                         -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
--     enable_line_number  = false,                      -- Displays the current line number instead of the current project
--     blacklist           = {},                         -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
--     buttons             = true,                       -- Configure Rich Presence button(s), either a boolean to enable/disable, a static table (`{{ label = "<label>", url = "<url>" }, ...}`, or a function(buffer: string, repo_url: string|nil): table)
--     file_assets         = {},                         -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)
--     show_time           = true,                       -- Show the timer
--
--     -- Rich Presence text options
--     editing_text        = "Editing %s",               -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
--     file_explorer_text  = "Browsing %s",              -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
--     git_commit_text     = "Committing changes",       -- Format string rendered when committing changes in git (either string or function(filename: string): string)
--     plugin_manager_text = "Managing plugins",         -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
--     reading_text        = "Reading %s",               -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
--     workspace_text      = "Working on %s",            -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
--     line_number_text    = "Line %s out of %s",        -- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
-- })


require('cord').setup {
  usercmds = true,                              -- Enable user commands
  log_level = 'error',                          -- One of 'trace', 'debug', 'info', 'warn', 'error', 'off'
  timer = {
    interval = 1500,                            -- Interval between presence updates in milliseconds (min 500)
    reset_on_idle = false,                      -- Reset start timestamp on idle
    reset_on_change = false,                    -- Reset start timestamp on presence change
  },
  editor = {
    image = nil,                                -- Image ID or URL in case a custom client id is provided
    client = 'neovim',                          -- vim, neovim, lunarvim, nvchad, astronvim or your application's client id
    tooltip = 'The Superior Text Editor',       -- Text to display when hovering over the editor's image
  },
  display = {
    show_time = true,                           -- Display start timestamp
    show_repository = true,                     -- Display 'View repository' button linked to repository url, if any
    show_cursor_position = false,               -- Display line and column number of cursor's position
    swap_fields = false,                        -- If enabled, workspace is displayed first
    swap_icons = false,                         -- If enabled, editor is displayed on the main image
    workspace_blacklist = {},                   -- List of workspace names to hide
  },
  lsp = {
    show_problem_count = false,                 -- Display number of diagnostics problems
    severity = 1,                               -- 1 = Error, 2 = Warning, 3 = Info, 4 = Hint
    scope = 'workspace',                        -- buffer or workspace
  },
  idle = {
    enable = true,                              -- Enable idle status
    show_status = true,                         -- Display idle status, disable to hide the rich presence on idle
    timeout = 300000,                           -- Timeout in milliseconds after which the idle status is set, 0 to display immediately
    disable_on_focus = true,                    -- Do not display idle status when neovim is focused
    text = 'Idle',                              -- Text to display when idle
    tooltip = '💤',                             -- Text to display when hovering over the idle image
  },
  text = {
    viewing = 'Viewing {}',                     -- Text to display when viewing a readonly file
    editing = 'Editing {}',                     -- Text to display when editing a file
    file_browser = 'Browsing files in {}',      -- Text to display when browsing files (Empty string to disable)
    plugin_manager = 'Managing plugins in {}',  -- Text to display when managing plugins (Empty string to disable)
    lsp_manager = 'Configuring LSP in {}',      -- Text to display when managing LSP servers (Empty string to disable)
    vcs = 'Committing changes in {}',           -- Text to display when using Git or Git-related plugin (Empty string to disable)
    workspace = 'In {}',                        -- Text to display when in a workspace (Empty string to disable)
  },
  buttons = {
    {
      label = 'View Repository',                -- Text displayed on the button
      url = 'git',                              -- URL where the button leads to ('git' = automatically fetch Git repository URL)
    },
    -- {
    --   label = 'View Plugin',
    --   url = 'https://github.com/vyfor/cord.nvim',
    -- }
  },
  assets = nil,                                 -- Custom file icons, see the wiki*
  -- assets = {
  --   lazy = {                                 -- Vim filetype or file name or file extension = table or string
  --     name = 'Lazy',                         -- Optional override for the icon name, redundant for language types
  --     icon = 'https://example.com/lazy.png', -- Rich Presence asset name or URL
  --     tooltip = 'lazy.nvim',                 -- Text to display when hovering over the icon
  --     type = 2,                              -- 0 = language, 1 = file browser, 2 = plugin manager, 3 = lsp manager, 4 = vcs; defaults to language
  --   },
  --   ['Cargo.toml'] = 'crates',
  -- },
}
