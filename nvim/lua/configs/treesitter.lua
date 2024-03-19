-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
	require("nvim-treesitter.configs").setup({
		-- Add languages to be installed here that you want installed for treesitter
		ensure_installed = {
			"vimdoc",
			"javascript",
			"typescript",
			"tsx",
			"css",
			"scss",
			"bash",
			"c",
			"cpp",
			"vim",
			"elixir",
			"go",
			"gitignore",
			"haskell",
			"hjson",
			"html",
			"json",
			"json5",
			"lua",
			"ocaml",
			"php",
			"perl",
			"scala",
			"zig",
			"yaml",
			"lua",
			"rust",
			"prisma",
		},

		build = ":TSUpdate",
		-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
		auto_install = false,
		autotag = {
			enable = true,
			enable_rename = true,
			enable_close = true,
			enable_close_on_slash = true,
			filetypes = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact" },
		},
		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<c-space>",
				node_incremental = "<c-space>",
				scope_incremental = "<c-s>",
				node_decremental = "<M-space>",
			},
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["aa"] = "@parameter.outer",
					["ia"] = "@parameter.inner",
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
			swap = {
				enable = true,
				swap_next = {
					["<leader>s"] = "@parameter.inner",
				},
				swap_previous = {
					["<leader>S"] = "@parameter.inner",
				},
			},
		},
	})
end, 0)
