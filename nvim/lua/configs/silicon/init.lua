require('silicon').setup {
  -- Additional settings to match the Catppuccin theme
  -- disable_defaults will disable all builtin default settings apart
  -- from the base arguments, that are needed to call silicon at all, see
  -- mandatory_options below, also those options can be overridden
  -- all of the settings could be overridden in the lua setup call,
  -- but this clashes with the use of an external silicon --config=file,
  -- see issue #9
  disable_defaults = false,
  -- turn on debug messages
  debug = false,
  -- most of them could be overridden with other
  -- the font settings with size and fallback font
  font = 'JetBrainsMono NF=34;',
  -- the theme to use, depends on themes available to silicon
  theme = 'TwoDark',
  -- the background color outside the rendered os window
  -- (in hexcode string e.g "#076678")
  background = nil,
  -- a path to a background image
  no_line_number = false,
  -- with which number the line numbering shall start
  -- background_image = '/home/wild_duck/Downloads/arch.jpg',
  -- the paddings to either side
  pad_horiz = 100,
  pad_vert = 80,
  -- whether to have the os window rendered with rounded corners
  no_round_corner = false,
  -- whether to put the close, minimize, maximise traffic light
  -- controls on the border
  no_window_controls = false,
  -- whether to turn off the line numbers
  line_offset = 1,
  -- here a function is used to return the actual source code line number
  -- line_offset = function(args)
  --     return args.line1
  -- end,
  -- the distance between lines of code
  line_pad = 0,
  -- the rendering of tab characters as so many space characters
  tab_width = 2,
  -- with which language the syntax highlighting shall be done, should be
  -- a function that returns either a language name or an extension like "js"
  language = function()
    return vim.bo.filetype
  end,
  -- if the shadow below the os window should have be blurred
  shadow_blur_radius = 0,
  -- the offset of the shadow in x and y directions
  shadow_offset_x = 0,
  shadow_offset_y = 0,
  -- the color of the shadow (in hexcode string e.g "#100808")
  shadow_color = nil,
  -- whether to strip of superfluous leading whitespace
  gobble = true,
  -- a string to pad each line with after gobbling removed larger indents,
  num_separator = nil,
  -- here a bar glyph is used to draw a vertial line and some space
  -- num_separator = "\u{258f} ",
  -- whether to put the image onto the clipboard, may produce an error,
  -- if run on WSL2
  to_clipboard = true,
  -- a string or function returning a string that defines the title
  -- showing in the image, only works in silicon versions greater than v0.5.1
  window_title = 'wild_duck',
  -- here a function is used to get the name of the current buffer
  -- window_title = function()
  --     return vim.fn.fnamemodify(
  --         vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
  --         ":t"
  --     )
  -- end,
  -- the silicon command, put an absolute location here, if the
  -- command is not in your ${PATH}
  command = 'silicon',
  -- a string or function that defines the path to the output image
  output = function()
    return '~/Pictures/Silicon/' .. os.date '!%Y-%m-%dT%H-%M-%S' .. '_code.png'
  end,
}
