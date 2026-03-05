local M = {}

M.servers = {
  clangd = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = {
            '${3rd}/luv/library',
            unpack(vim.api.nvim_get_runtime_file('', true)),
          },
        },
        completion = { callSnippet = 'Replace' },
      },
    },
  },
  rust_analyzer = {},
  ts_ls = {
    root_dir = function(fname)
      return vim.fs.root(fname, { 'package.json', 'tsconfig.json', 'jsconfig.json' })
    end,
    single_file_support = false,
    formatting = { format_opts = { async = true } },
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

local function client_supports_method(client, method, bufnr)
  if vim.fn.has 'nvim-0.11' == 1 then
    return client:supports_method(method, bufnr)
  else
    return client.supports_method(method, { bufnr = bufnr })
  end
end

function M.on_attach(event)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

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

  vim.keymap.set('n', '<leader>f', function()
    require('conform').format { bufnr = event.buf }
  end)

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if
    client
    and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
  then
    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })
    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
      end,
    })
  end

  if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, '[T]oggle Inlay [H]ints')
  end
end

M.diagnostics = {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = true,
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
    severity = { min = vim.diagnostic.severity.HINT },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      return diagnostic.message
    end,
    severity = { min = vim.diagnostic.severity.HINT },
  },
}

function M.setup()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = M.on_attach,
  })

  vim.diagnostic.config(M.diagnostics)

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  require('mason').setup()
  require('mason-tool-installer').setup { ensure_installed = vim.tbl_keys(M.servers or {}) }

  require('mason-lspconfig').setup {
    handlers = {
      function(server_name)
        local server = M.servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
        vim.lsp.enable(server_name)
      end,
    },
  }
end

return M
