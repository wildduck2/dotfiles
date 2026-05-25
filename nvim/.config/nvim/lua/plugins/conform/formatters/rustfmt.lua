local util = require('conform.util')

-- Default rustfmt config lives in this repo at nvim/.config/nvim/rustfmt.toml.
-- conform passes --config-path so every rust file gets the same style, even
-- when the project root has no rustfmt.toml of its own.
local DEFAULT_CONFIG = vim.fn.stdpath('config') .. '/rustfmt.toml'

---@type conform.FileFormatterConfig
return {
  meta = {
    url = 'https://github.com/rust-lang/rustfmt',
    description = 'A tool for formatting rust code according to style guidelines.',
  },
  command = 'rustfmt',
  options = {
    default_edition = '2024',
  },
  args = function(self, ctx)
    local args = { '--emit=stdout' }
    local edition = util.parse_rust_edition(ctx.dirname) or self.options.default_edition
    table.insert(args, '--edition=' .. edition)

    -- Only inject our default if the project itself does not ship one.
    local project_cfg = util.root_file({ 'rustfmt.toml', '.rustfmt.toml' })(self, ctx)
    if not project_cfg and vim.fn.filereadable(DEFAULT_CONFIG) == 1 then
      table.insert(args, '--config-path=' .. DEFAULT_CONFIG)
    end

    return args
  end,
  cwd = util.root_file({
    'rustfmt.toml',
    '.rustfmt.toml',
  }),
}
