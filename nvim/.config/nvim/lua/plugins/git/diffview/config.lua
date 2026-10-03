local M = {}

function M.setup()
  require('diffview').setup({
    enhanced_diff_hl = true,
    view = {
      merge_tool = {
        layout = 'diff3_horizontal',
      },
    },
  })
end

return M
