local util = require 'conform.util'

-- To have this work you have to install `rustfmt`,
-- with `cargo install rustfmt`, make sure that cargo is installed.
-- ```sh
-- cargo install rustfmt
-- ```
-- OR=>> install it using mason
-- You have to add this file `rustfmt.toml` with it's configuration to `rust` project
---@type conform.FileFormatterConfig
return {
  meta = {
    url = 'https://github.com/rust-lang/rustfmt',
    description = 'A tool for formatting rust code according to style guidelines.',
  },
  command = 'rustfmt',
  options = {
    -- The default edition of Rust to use when no Cargo.toml file is found
    default_edition = '2021',
  },
  args = function(self, ctx)
    local args = { '--emit=stdout' }
    local edition = util.parse_rust_edition(ctx.dirname) or self.options.default_edition
    table.insert(args, '--edition=' .. edition)

    return args
  end,
  cwd = util.root_file {
    'rustfmt.toml',
    '.rustfmt.toml',
  },
}

--[[
  max_width = 100
  tab_spaces = 2
  use_small_heuristics = "Default"
--]]
