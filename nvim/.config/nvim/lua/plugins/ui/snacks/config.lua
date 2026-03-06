local M = {}

M.opts = {
  indent = {
    -- Base indent guide settings
    indent = {
      priority = 1, -- render priority; lower = drawn first
      enabled = true,
      char = '┃', -- character for indent guides; e.g. '│', '|'
      only_scope = false, -- true: only show guides in current scope
      only_current = false, -- true: only show in current buffer
      hl = 'SnacksIndent', -- highlight group (or list for rainbow)
      -- hl = {
      --   'SnacksIndent1',
      --   'SnacksIndent2',
      --   'SnacksIndent3',
      --   'SnacksIndent4',
      --   'SnacksIndent5',
      --   'SnacksIndent6',
      --   'SnacksIndent7',
      --   'SnacksIndent8',
      -- },
    },
    -- Animation for indent guide appearance
    animate = {
      enabled = false, -- true: animate indent guides on scroll
      style = 'out', -- 'out' | 'up_down' | 'down' | 'up'
      easing = 'linear', -- easing function: 'linear', 'ease', etc.
      duration = {
        step = 20, -- ms between animation frames
        total = 500, -- max total animation duration in ms
      },
    },
    -- Highlighted guide for current scope (function, block, etc.)
    scope = {
      enabled = true,
      priority = 200, -- higher than indent to draw on top
      char = '┃', -- scope guide character
      underline = false, -- true: underline first line of scope
      only_current = false, -- true: only highlight active scope
      hl = 'SnacksIndentScope', -- highlight group for scope guide
    },
    -- Chunk: draws a box around the current code block
    chunk = {
      enabled = false, -- true: show chunk markers around blocks
      only_current = false, -- true: only mark active chunk
      priority = 200,
      hl = 'SnacksIndentChunk', -- highlight group for chunk lines
      char = { -- box-drawing chars for chunk outline
        corner_top = '┌',
        corner_bottom = '└',
        -- corner_top = '╭',  -- rounded alternative
        -- corner_bottom = '╰',
        horizontal = '─',
        vertical = '│',
        arrow = '>',
      },
    },
    filter = function(buf, win) -- skip special buffers (help, terminal, etc.)
      return vim.g.snacks_indent ~= false
        and vim.b[buf].snacks_indent ~= false
        and vim.bo[buf].buftype == ''
    end,
  },
}

return M
