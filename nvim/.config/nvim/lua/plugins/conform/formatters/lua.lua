---@type conform.FileFormatterConfig
return {
  meta = {
    url = 'https://github.com/JohnnyMorganz/StyLua',
    description = 'Lua formatter',
    author = 'JohnnyMorganz',
  },
  command = 'stylua',
  args = { '--search-parent-directories', '--stdin-filepath', '$FILENAME', '-' },
  stdin = true,
}
