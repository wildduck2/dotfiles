-- To have this work you have to install `stylua`,
-- with `cargo install stylua`, make sure that cargo is installed.
-- ```sh
-- cargo install stylua
-- ```
-- OR=>> install it using mason
---@type conform.FileFormatterConfig
return {
  meta = {
    url = 'https:e/github.com/JohnnyMorganz/StyLua',
    description = 'Lua formatter',
    author = 'JohnnyMorganz',
  },
  command = 'stylua',
  args = { '--search-parent-directories', '--stdin-filepath', '$FILENAME', '-' },
  stdin = true,
}
