local M = {}

function M.setup_comment()
  require('nvim_comment').setup {
    marker_padding = true,
    comment_empty = true,
    comment_empty_trim_whitespace = true,
    create_mappings = true,
    line_mapping = 'gcc',
    block_mapping = 'gbc',
    operator_mapping = 'gc',
    comment_chunk_text_object = 'ic',
    hook = function()
      require('ts_context_commentstring.internal').update_commentstring()
    end,
  }
end

M.cloak = {
  enabled = true,
  cloak_character = '*',
  highlight_group = 'Comment',
  patterns = {
    {
      file_pattern = { '.env*', 'wrangler.toml', '.dev.vars' },
      cloak_pattern = '=.+',
    },
  },
}

function M.setup_cloak()
  require('cloak').setup(M.cloak)
end

return M
