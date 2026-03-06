local M = {}

function M.setup()
  require('nvim_comment').setup {
    -- true: add space between comment marker and text
    marker_padding = true,
    -- true: allow commenting empty lines
    comment_empty = true,
    -- true: trim trailing whitespace on empty comments
    comment_empty_trim_whitespace = true,
    -- true: create default keymaps below
    create_mappings = true,
    -- keymap to toggle comment on current line
    line_mapping = 'gcc',
    -- keymap to toggle block comment
    block_mapping = 'gbc',
    -- operator-pending keymap (e.g. gc + motion)
    operator_mapping = 'gc',
    -- text object for selecting comment chunks
    comment_chunk_text_object = 'ic',
    -- updates commentstring via treesitter context
    hook = function()
      require('ts_context_commentstring.internal').update_commentstring()
    end,
  }
end

return M
