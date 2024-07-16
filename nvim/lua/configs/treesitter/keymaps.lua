local M = {}


M.keymap1 = {
    init_selection = "<c-space>",
    node_incremental = "<c-space>",
    scope_incremental = "<c-s>",
    node_decremental = "<M-space>",
}

M.keymap2 = {
    -- You can use the capture groups defined in textobjects.scm
    ["aa"] = "@parameter.outer",
    ["ia"] = "@parameter.inner",
    ["af"] = "@function.outer",
    ["if"] = "@function.inner",
    ["ac"] = "@class.outer",
    ["ic"] = "@class.inner",
}

return M
