local util = require 'conform.util'

-- You need `clang-format` to be installed.
-- ```sh
-- sudo pacman -S clang-format
-- ```
-- You will have to add the `.clang-format` file in you codebase to get formatting with your
-- configs.
---@type conform.FileFormatterConfig
return {
  meta = {
    url = 'https://clang.llvm.org/docs/ClangFormat.html',
    description = 'Tool to format C/C++/… code according to a set of rules and heuristics.',
  },
  command = 'clang-format',
  args = { '-assume-filename', '$FILENAME' },
  range_args = function(self, ctx)
    local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
    local length = end_offset - start_offset
    return {
      '-assume-filename',
      '$FILENAME',
      '--offset',
      tostring(start_offset),
      '--length',
      tostring(length),
    }
  end,
}

--[[
  BasedOnStyle: Google
  IndentWidth: 4
  ColumnLimit: 100
  AlignConsecutiveAssignments: true
  AllowAllParametersOfDeclarationOnNextLine: true
]]
