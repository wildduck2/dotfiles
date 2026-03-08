local M = {}

function M.setup()
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
  luasnip.config.setup {}

  cmp.setup {
    -- Snippet expansion via LuaSnip
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    -- Bordered floating windows for completion/docs
    window = {
      completion = cmp.config.window.bordered({
        border = 'rounded',
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        col_offset = -1,
        side_padding = 1,
      }),
      documentation = cmp.config.window.bordered({
        border = 'rounded',
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,Search:None',
      }),
    },
    -- Auto-select first item, show menu even with one match
    completion = { completeopt = 'menu,menuone,noinsert' },

    -- Keybindings for completion menu
    mapping = cmp.mapping.preset.insert {
      ['<C-n>'] = cmp.mapping.select_next_item(), -- Next suggestion
      ['<C-p>'] = cmp.mapping.select_prev_item(), -- Previous suggestion
      ['<C-b>'] = cmp.mapping.scroll_docs(-4), -- Scroll docs up
      ['<C-f>'] = cmp.mapping.scroll_docs(4), -- Scroll docs down
      ['<C-y>'] = cmp.mapping.confirm { select = true }, -- Accept completion
      ['<C-Space>'] = cmp.mapping.complete {}, -- Trigger completion manually
      -- Jump forward in snippet placeholders
      ['<C-l>'] = cmp.mapping(function()
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        end
      end, { 'i', 's' }),
      -- Jump backward in snippet placeholders
      ['<C-h>'] = cmp.mapping(function()
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        end
      end, { 'i', 's' }),
    },

    -- Completion sources in priority order
    sources = {
      { name = 'lazydev', group_index = 0 }, -- Neovim Lua API (highest priority)
      { name = 'nvim_lsp' }, -- LSP completions
      { name = 'luasnip' }, -- Snippet completions
      { name = 'path' }, -- Filesystem path completions
    },
  }
end

return M
