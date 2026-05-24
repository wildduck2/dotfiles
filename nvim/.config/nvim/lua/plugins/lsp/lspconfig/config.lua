local M = {}

-- LSP server configurations. See docs/plugins/lsp/lspconfig/README.md.
M.servers = {
	clangd = {},
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				workspace = {
					checkThirdParty = false,
					-- Populated in setup() to defer rtp scan.
					library = {},
				},
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
				includeCompletionsForModuleExports = false,
				includeCompletionsWithObjectLiteralMethodSnippets = false,
				includePackageJsonAutoImports = "off",
			},
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
		init_options = { typescript = {} },
	},
	-- duck-sqllsp: our native SQL language server (Rust workspace at
	-- @duck-sqllsp). Binary installed to ~/.local/bin/duck-sqllsp.
	-- Connections are pushed in via plugins/lang/dadbod/db_manager at
	-- LspAttach time so the server gets the same list as dadbod-ui.
	duck_sqllsp = {
		filetypes = { "sql", "mysql", "plsql" },
		cmd = { "duck-sqllsp", "server" },
	},
}

local function client_supports_method(client, method, bufnr)
	if vim.fn.has("nvim-0.11") == 1 then
		return client:supports_method(method, bufnr)
	else
		return client.supports_method(method, { bufnr = bufnr })
	end
end

local function on_attach(event)
	local map = function(keys, func, desc, mode)
		mode = mode or "n"
		vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	end

	map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	map("gr", function() require("telescope.builtin").lsp_references() end, "[G]oto [R]eferences")
	map("gI", function() require("telescope.builtin").lsp_implementations() end, "[G]oto [I]mplementation")
	map("gd", function() require("telescope.builtin").lsp_definitions() end, "[G]oto [D]efinition")
	map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	map("<leader>ds", function() require("telescope.builtin").lsp_document_symbols() end, "[D]ocument [S]ymbols")
	map("<leader>ws", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "[W]orkspace [S]ymbols")
	map("<leader>D", function() require("telescope.builtin").lsp_type_definitions() end, "Type [D]efinition")
	-- Default nvim hover -- no custom float, no markdown overlay, no
	-- auto-close hook. Width / height / styling come straight from
	-- vim.lsp.buf.hover().
	map("K", vim.lsp.buf.hover, "Hover Documentation")
	map("<C-s>", vim.lsp.buf.signature_help, "Signature Help", "i")

	local client = vim.lsp.get_client_by_id(event.data.client_id)

	-- Auto-trigger signature help when the LSP advertises it. Fires on `(`
	-- and `,` so the parameter hint stays in sync as the user types args.
	if client and client.server_capabilities.signatureHelpProvider
		and not vim.b[event.buf]._lsp_sighelp_registered then
		vim.b[event.buf]._lsp_sighelp_registered = true
		local triggers = client.server_capabilities.signatureHelpProvider.triggerCharacters or { "(", "," }
		vim.api.nvim_create_autocmd("TextChangedI", {
			buffer = event.buf,
			callback = function()
				local col = vim.api.nvim_win_get_cursor(0)[2]
				if col == 0 then return end
				local line = vim.api.nvim_get_current_line()
				local ch = line:sub(col, col)
				for _, t in ipairs(triggers) do
					if ch == t then vim.lsp.buf.signature_help(); return end
				end
			end,
		})
	end

	-- ts_ls owns JS/TS diagnostics; suppress biome's to avoid duplicates.
	if client and client.name == "biome" then
		client.server_capabilities.diagnosticProvider = nil
	end

	-- duck-sqllsp advertises semantic tokens, but tree-sitter SQL has
	-- richer coverage. Letting both run lets the LSP tokens repaint
	-- identifiers in flat colours and the buffer ends up de-coloured.
	-- Drop the LSP provider so tree-sitter highlights remain authoritative.
	if client and client.name == "duck_sqllsp" then
		client.server_capabilities.semanticTokensProvider = nil
		-- nvim 0.11 renamed `vim.lsp.semantic_tokens.stop` -> nothing
		-- public; clearing the provider above is enough to halt future
		-- token requests, and existing highlights drop on the next
		-- buffer change.
	end

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
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
		callback = on_attach,
	})

	vim.diagnostic.config({
		update_in_insert = false,
		severity_sort = true,
		float = { border = "rounded", source = "if_many" },
		underline = true,
		signs = vim.g.have_nerd_font and {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.INFO] = "󰋽 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
			},
			severity = { min = vim.diagnostic.severity.HINT },
		} or {},
		virtual_text = {
			source = "if_many",
			spacing = 2,
			format = function(diagnostic)
				return diagnostic.message
			end,
			severity = { min = vim.diagnostic.severity.HINT },
		},
	})

	local lua_lib = { "${3rd}/luv/library" }
	vim.list_extend(lua_lib, vim.api.nvim_get_runtime_file("", true))
	M.servers.lua_ls.settings.Lua.workspace.library = lua_lib

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

	require("mason").setup({ ui = { border = "rounded" } })

	-- Mason auto-installs every server in M.servers EXCEPT duck_sqllsp,
	-- which is built from source under @duck-sqllsp and installed to
	-- ~/.local/bin via `cargo install` (or `install -m 0755 target/release/...`).
	local ensure = {}
	for name, _ in pairs(M.servers or {}) do
		if name ~= "duck_sqllsp" then
			table.insert(ensure, name)
		end
	end
	require("mason-tool-installer").setup({ ensure_installed = ensure })

	require("mason-lspconfig").setup({ automatic_enable = false })

	for server_name, server_config in pairs(M.servers) do
		local config = vim.tbl_deep_extend("force", {}, server_config)
		config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
		vim.lsp.config(server_name, config)
		vim.lsp.enable(server_name)
	end
end

return M
