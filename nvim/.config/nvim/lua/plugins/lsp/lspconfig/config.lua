local M = {}

-- LSP server configurations (empty {} = use defaults)
-- NOTE: lua_ls library is built lazily in setup() to avoid
-- scanning runtimepath at require-time
M.servers = {
  clangd = {},
  lua_ls = {
    settings = {
      Lua = {
        -- Target LuaJIT runtime (alt: 'Lua 5.1'-'5.4')
        runtime = { version = 'LuaJIT' },
        workspace = {
          -- Don't prompt to configure third-party libs
          checkThirdParty = false,
          -- Populated in setup() to defer rtp scan
          library = {},
        },
        -- 'Replace' inserts snippet body (alt: 'Disable')
        completion = { callSnippet = 'Replace' },
      },
    },
  },
  -- rust_analyzer: handled by rustaceanvim plugin (plugins/lang/rust)
  -- which wraps rust-analyzer with extras: debugging, runnables, expandMacro, etc.
  rust_analyzer = {},
  ts_ls = {
    -- Resolve project root from these config files
    root_dir = function(fname)
      return vim.fs.root(fname, { 'package.json', 'tsconfig.json', 'jsconfig.json' })
    end,
    -- false = don't start without a project root
    single_file_support = false,
    -- true = format without blocking the editor
    formatting = { format_opts = { async = true } },
    -- false = keep TS auto-import suggestions enabled
    init_options = { preferences = { disableSuggestions = false } },
  },
  tailwindcss = {},
  cssls = {},
  html = {},
  jsonls = {},
  yamlls = {},
  prismals = {},
  typos_lsp = {},
  biome = {},
  bashls = {},
  dockerls = {},
  docker_compose_language_service = {},
  mdx_analyzer = {},
}

-- Compat wrapper: 0.11+ uses method syntax, older uses fn
local function client_supports_method(client, method, bufnr)
  if vim.fn.has 'nvim-0.11' == 1 then
    return client:supports_method(method, bufnr)
  else
    return client.supports_method(method, { bufnr = bufnr })
  end
end

-- Runs when an LSP client attaches to a buffer
local function on_attach(event)
  -- Helper: set buffer-local keymap with LSP: prefix
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

  -- LSP keymaps (buffer-local, only active when LSP attached)
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  map('K', vim.lsp.buf.hover, 'Hover Documentation')

  -- Format current buffer via conform on <leader>f
  vim.keymap.set('n', '<leader>f', function()
    require('conform').format { bufnr = event.buf }
  end)

  -- Document highlight: highlight symbol under cursor
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if
    client
    and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
  then
    -- clear=false so multiple buffers can share the group
    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
    -- Highlight refs when cursor rests on a symbol
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })
    -- Clear highlights when cursor moves away
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })
    -- Clean up autocmds when LSP detaches from buffer
    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
      end,
    })
  end

  -- Inlay hints: show type/param hints at end of line (via endhints plugin)
  if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    -- enable by default so endhints can render them at end of line
    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, '[T]oggle Inlay [H]ints')
  end
end

function M.setup()
  -- Register on_attach for every LSP client connection
  vim.api.nvim_create_autocmd('LspAttach', {
    -- clear=true so re-sourcing doesn't duplicate
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = on_attach,
  })

  -- Diagnostic display settings
  vim.diagnostic.config {
    -- false = don't update diagnostics while typing
    update_in_insert = false,
    -- true = sort by severity (errors first)
    severity_sort = true,
    -- Floating window style (alt border: 'single','none')
    float = { border = 'rounded', source = 'if_many' },
    -- true = underline diagnostic text in buffer
    underline = true,
    -- Use nerd font icons for sign column if available
    signs = vim.g.have_nerd_font and {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
      -- Show signs for all severity levels
      severity = { min = vim.diagnostic.severity.HINT },
    } or {},
    virtual_text = {
      -- 'if_many' = show source only when multiple exist
      source = 'if_many',
      -- Columns between code and virtual text
      spacing = 2,
      -- Display raw message (can transform here)
      format = function(diagnostic)
        return diagnostic.message
      end,
      -- Show virtual text for all severity levels
      severity = { min = vim.diagnostic.severity.HINT },
    },
  }

  -- Populate lua_ls library now (deferred from module load time)
  local lua_lib = { '${3rd}/luv/library' }
  vim.list_extend(lua_lib, vim.api.nvim_get_runtime_file('', true))
  M.servers.lua_ls.settings.Lua.workspace.library = lua_lib

  -- Merge nvim-cmp capabilities with default LSP caps
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  -- Mason: portable LSP/tool installer
  require('mason').setup()
  -- Auto-install all servers listed in M.servers
  require('mason-tool-installer').setup { ensure_installed = vim.tbl_keys(M.servers or {}) }

  -- Bridge mason-installed servers to lspconfig
  require('mason-lspconfig').setup {
    handlers = {
      -- Default handler: configure and enable each server
      function(server_name)
        local server = M.servers[server_name] or {}
        -- Merge server-specific caps with shared caps
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
        vim.lsp.enable(server_name)
      end,
    },
  }
end

return M
