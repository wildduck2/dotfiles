local filetypes = {
  'html',
  'javascript',
  'typescript',
  'javascriptreact',
  'typescriptreact',
  'svelte',
  'vue',
  'tsx',
  'jsx',
  'rescript',
  'xml',
  'php',
  'markdown',
  'astro',
  'glimmer',
  'handlebars',
  'hbs',
}
local skip_tags = {
  'area',
  'base',
  'br',
  'col',
  'command',
  'embed',
  'hr',
  'img',
  'slot',
  'input',
  'keygen',
  'link',
  'meta',
  'param',
  'source',
  'track',
  'wbr',
  'menuitem',
}

require('nvim-treesitter.configs').setup {
  autotag = {
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
    filetypes = filetypes,
  },
}

--[[ vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        underline = true,
        virtual_text = {
            spacing = 5,
            severity_limit = 'Warning',
        },
        update_in_insert = true,
    }
) ]]
