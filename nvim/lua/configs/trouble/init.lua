require('configs.trouble.keymaps')
local values = require('configs.trouble.values')

require("trouble").setup({
    position = "bottom",
    height = 10,
    width = 50,
    icons = true,
    mode = "workspace_diagnostics",
    severity = nil,
    fold_open = "",
    fold_closed = "",
    group = true,
    padding = true,
    cycle_results = true,
    action_keys = values.action_keys,
    multiline = true,
    indent_lines = true,
    win_config = { border = "single" },
    auto_open = false,
    auto_close = false,
    auto_preview = true,
    auto_fold = false,
    auto_jump = { "lsp_definitions" },
    include_declaration = { "lsp_references", "lsp_implementations", "lsp_definitions" },
    signs = values.signs,
    use_diagnostic_signs = false,
})

