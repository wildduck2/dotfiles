local M = {}

M.opts = {
  -- AST (Abstract Syntax Tree) display settings
  ast = {
    -- Icons for AST node roles
    role_icons = {
      type = '', declaration = '', expression = '',
      specifier = '', statement = '', ['template argument'] = '',
    },
    -- Icons for AST node kinds
    kind_icons = {
      Compound = '', Recovery = '', TranslationUnit = '',
      PackExpansion = '', TemplateTypeParm = '',
      TemplateTemplateParm = '', TemplateParamObject = '',
    },
    highlights = { detail = 'Comment' }, -- Highlight group for details
  },
  memory_usage = { border = 'rounded' },
  symbol_info = { border = 'rounded' },
}

return M
