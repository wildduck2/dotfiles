local util = require 'conform.util'

-- You will have to install `biome` on your system
-- ```sh
-- sudo pacman -S biome
-- ```
-- OR
-- ```sh
-- sudo npm install @biomejs/biome -g
-- ```
-- OR =>> use mason to install it.
---@type conform.FileFormatterConfig
return {
  meta = {
    url = 'https://github.com/biomejs/biome',
    description = 'A toolchain for web projects, aimed to provide functionalities to maintain them.',
  },
  command = util.from_node_modules 'biome',
  stdin = true,
  args = { 'format', '--stdin-file-path', '$FILENAME' },
  cwd = util.root_file {
    'biome.json',
    'biome.jsonc',
  },
}
