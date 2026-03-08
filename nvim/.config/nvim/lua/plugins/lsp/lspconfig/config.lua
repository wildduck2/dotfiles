local M = {}

-- LSP server configurations (empty {} = use defaults)
-- NOTE: lua_ls library is built lazily in setup() to avoid
-- scanning runtimepath at require-time
M.servers = {
	clangd = {},
	lua_ls = {
		settings = {
			Lua = {
				-- Target LuaJIT runtime (alt: 'Lua 5.1'-'5.4')
				runtime = { version = "LuaJIT" },
				workspace = {
					-- Don't prompt to configure third-party libs
					checkThirdParty = false,
					-- Populated in setup() to defer rtp scan
					library = {},
				},
				-- 'Replace' inserts snippet body (alt: 'Disable')
				completion = { callSnippet = "Replace" },
			},
		},
	},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				inlayHints = {
					chainingHints = { enable = true },
					typeHints = { enable = true },
					parameterHints = { enable = true },
				},
			},
		},
	},
	ts_ls = {
		init_options = {
			preferences = {
				disableSuggestions = false,
				-- Reduce heavy operations that cause lag
				includeCompletionsForModuleExports = false,
				includeCompletionsWithObjectLiteralMethodSnippets = false,
				includePackageJsonAutoImports = "off",
			},
			-- Limit memory usage
			maxTsServerMemory = 4096,
		},
	},
	tailwindcss = {},
	cssls = {},
	html = {},
	jsonls = {},
	yamlls = {},
	prismals = {},
	typos_lsp = {
		filetypes = { "markdown", "text", "gitcommit" },
	},
	biome = {
		capabilities = {
			general = {
				positionEncodings = { "utf-16" },
			},
		},
	},
	bashls = {},
	dockerls = {},
	docker_compose_language_service = {},
	mdx_analyzer = {
		filetypes = { "mdx" },
		init_options = {
			typescript = {},
		},
	},
}

-- Compat wrapper: 0.11+ uses method syntax, older uses fn
local function client_supports_method(client, method, bufnr)
	if vim.fn.has("nvim-0.11") == 1 then
		return client:supports_method(method, bufnr)
	else
		return client.supports_method(method, { bufnr = bufnr })
	end
end

-- Runs when an LSP client attaches to a buffer
local function on_attach(event)
	-- Helper: set buffer-local keymap with LSP: prefix
	local map = function(keys, func, desc, mode)
		mode = mode or "n"
		vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	end

	-- LSP keymaps (buffer-local, only active when LSP attached)
	-- Wrap telescope requires in functions to avoid eager loading
	map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	map("gr", function() require("telescope.builtin").lsp_references() end, "[G]oto [R]eferences")
	map("gI", function() require("telescope.builtin").lsp_implementations() end, "[G]oto [I]mplementation")
	map("gd", function() require("telescope.builtin").lsp_definitions() end, "[G]oto [D]efinition")
	map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	map("<leader>ds", function() require("telescope.builtin").lsp_document_symbols() end, "[D]ocument [S]ymbols")
	map("<leader>ws", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "[W]orkspace [S]ymbols")
	map("<leader>D", function() require("telescope.builtin").lsp_type_definitions() end, "Type [D]efinition")
	map("K", vim.lsp.buf.hover, "Hover Documentation")

	local client = vim.lsp.get_client_by_id(event.data.client_id)

	-- Disable biome diagnostics (ts_ls handles diagnostics for JS/TS)
	if client and client.name == "biome" then
		client.server_capabilities.diagnosticProvider = nil
	end

	-- Document highlight: only register once per buffer (not per LSP client)
	local buf = event.buf
	if
		client
		and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, buf)
		and not vim.b[buf]._lsp_highlight_registered
	then
		vim.b[buf]._lsp_highlight_registered = true
		local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = buf,
			group = highlight_augroup,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			buffer = buf,
			group = highlight_augroup,
			callback = vim.lsp.buf.clear_references,
		})
		vim.api.nvim_create_autocmd("LspDetach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
			callback = function(event2)
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
				vim.b[event2.buf]._lsp_highlight_registered = nil
			end,
		})
	end

	-- Inlay hints: only enable once per buffer
	if
		client
		and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, buf)
		and not vim.b[buf]._lsp_inlay_registered
	then
		vim.b[buf]._lsp_inlay_registered = true
		vim.lsp.inlay_hint.enable(true, { bufnr = buf })
		map("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
		end, "[T]oggle Inlay [H]ints")
	end
end

function M.setup()
	-- Register on_attach for every LSP client connection
	vim.api.nvim_create_autocmd("LspAttach", {
		-- clear=true so re-sourcing doesn't duplicate
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
		callback = on_attach,
	})

	-- Diagnostic display settings
	vim.diagnostic.config({
		-- false = don't update diagnostics while typing
		update_in_insert = false,
		-- true = sort by severity (errors first)
		severity_sort = true,
		-- Floating window style (alt border: 'single','none')
		float = { border = "rounded", source = "if_many" },
		underline = true,
		-- Use nerd font icons for sign column if available
		signs = vim.g.have_nerd_font and {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.INFO] = "󰋽 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
			},
			-- Show signs for all severity levels
			severity = { min = vim.diagnostic.severity.HINT },
		} or {},
		virtual_text = {
			-- 'if_many' = show source only when multiple exist
			source = "if_many",
			-- Columns between code and virtual text
			spacing = 2,
			-- Display raw message (can transform here)
			format = function(diagnostic)
				return diagnostic.message
			end,
			-- Show virtual text for all severity levels
			severity = { min = vim.diagnostic.severity.HINT },
		},
	})

	-- Populate lua_ls library now (deferred from module load time)
	local lua_lib = { "${3rd}/luv/library" }
	vim.list_extend(lua_lib, vim.api.nvim_get_runtime_file("", true))
	M.servers.lua_ls.settings.Lua.workspace.library = lua_lib

	-- Merge nvim-cmp capabilities with default LSP caps
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

	-- Mason: portable LSP/tool installer
	require("mason").setup({
		ui = { border = "rounded" },
	})
	-- Auto-install all servers + extra tools (formatters, linters)
	-- Auto-install all servers listed in M.servers
	require("mason-tool-installer").setup({ ensure_installed = vim.tbl_keys(M.servers or {}) })

	-- Disable automatic_enable so we control server configs ourselves
	require("mason-lspconfig").setup({
		automatic_enable = false,
	})

	-- Configure and enable each server with our custom settings
	for server_name, server_config in pairs(M.servers) do
		local config = vim.tbl_deep_extend("force", {}, server_config)
		config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
		vim.lsp.config(server_name, config)
		vim.lsp.enable(server_name)
	end
end

return M
