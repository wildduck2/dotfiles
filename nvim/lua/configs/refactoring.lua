local refactoring = require("refactoring")

refactoring.setup({
    prompt_func_return_type = {
    },
    prompt_func_param_type = {
    },
    printf_statements = {},
    print_var_statements = {},
    -- show_success_message = falsge, -- shows a message with information about the refactor on success
    -- i.e. [Refactor] Inlined 3evariable occurrences
})




-- keymaps for refactoring
vim.keymap.set("x", "<leader>re", function() refactoring.refactor('Extract Function') end)
vim.keymap.set("x", "<leader>rf", function() refactoring.refactor('Extract Function To File') end)
-- Extract function supports only visual mode
vim.keymap.set("x", "<leader>rv", function() refactoring.refactor('Extract Variable') end)
-- Extract variable supports only visual mode
vim.keymap.set("n", "<leader>rI", function() refactoring.refactor('Inline Function') end)
-- Inline func supports only normal
vim.keymap.set({ "n", "x" }, "<leader>ri", function() refactoring.refactor('Inline Variable') end)
-- Inline var supports both normal and visual mode

vim.keymap.set("n", "<leader>rb", function() refactoring.refactor('Extract Block') end)
vim.keymap.set("n", "<leader>rbf", function() refactoring.refactor('Extract Block To File') end)
-- Extract block supports only normal mode
