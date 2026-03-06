local M = {}

function M.setup()
  require('nvim-ts-autotag').setup {
    opts = {
      enable_close = true, -- Auto-close tags when typing >
      enable_rename = true, -- Auto-rename matching tag pair
      enable_close_on_slash = true, -- Auto-close on </ input
    },
    -- Filetypes where autotag is active
    filetypes = {
      'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact',
      'svelte', 'vue', 'tsx', 'jsx', 'rescript', 'xml', 'php', 'markdown',
      'astro', 'glimmer', 'handlebars', 'hbs',
    },
  }
end

return M
