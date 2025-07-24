return { -- >>> LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "folke/neodev.nvim", opts = {} },
			-- Automatically install LSPs to stdpath for neovim
			{
				"mason-org/mason.nvim",
				opts = { ensure_installed = { "tree-sitter-cli" } },
			},
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			-- Useful status updates for LSP
			{ "j-hui/fidget.nvim", opts = {} },
			-- Show nvim diagnostics using virtual lines
			{ "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },
		},
		config = function()
			local servers = {
				bashls = {}, -- Bash
				marksman = {}, -- Markdown lsp
				sqlls = {}, -- SQL
				eslint = {}, -- React/NextJS/Svelte
				emmet_language_server = {}, -- HTML
				ts_ls = {
					-- inlayHints = {
					-- 	includeInlayParameterNameHints = "literal",
					-- 	includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					-- 	includeInlayFunctionParameterTypeHints = false,
					-- 	includeInlayVariableTypeHints = false,
					-- 	includeInlayPropertyDeclarationTypeHints = false,
					-- 	includeInlayFunctionLikeReturnTypeHints = false,
					-- 	includeInlayEnumMemberValueHints = false,
					-- },
				}, -- Javascript, TypeScript
				html = {}, -- HTML
				htmx = {}, -- HTMX
				cssls = {}, -- CSS
				tailwindcss = {}, -- Tailwind CSS
				templ = {}, -- Templ
				pyright = {}, -- Python : pyright
				-- ty = {},
				ruff = {
					commands = {
						RuffAutofix = {
							function()
								vim.lsp.buf.execute_command({
									command = "ruff.applyAutofix",
									arguments = {
										{ uri = vim.uri_from_bufnr(0) },
									},
								})
							end,
							description = "Ruff: Fix all auto-fixable problems",
						},
						RuffOrganizeImports = {
							function()
								vim.lsp.buf.execute_command({
									command = "ruff.applyOrganizeImports",
									arguments = {
										{ uri = vim.uri_from_bufnr(0) },
									},
								})
							end,
							description = "Ruff: Format imports",
						},
					},
				},
				dockerls = {}, -- Docker
				docker_compose_language_service = {}, --Docker-Compose
				jsonls = {}, -- JSON
				taplo = {}, -- TOML
				lua_ls = { -- Lua
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								callSnippet = "Replace",
								displayContext = 10,
								keywordSnippet = "Both",
							},
							diagnostics = {
								globals = { "vim" },
								disable = { "missing-fields", "undefined-global" },
							},
							codeLens = {
								enable = true,
							},
							doc = {
								privateName = { "^_" },
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				},
			}

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				-- FORMATTERS
				{ "black" }, -- Python
				{ "isort" }, -- Python
				{ "shfmt" }, -- Shell Script
				{ "stylua" }, -- Lua
				{ "biome" },
				{ "prettierd" }, -- JS and Many More
				{ "prettier" }, -- JS and Many More

				-- LINTERS
				{ "codespell" },
				{ "ruff" },
				-- { "eslint_d" },
				{ "shellcheck" },

				--DAP
				{ "debugpy" },
			})

			-- imports
			local lspconfig = require("lspconfig")
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")
			local lsp_lines = require("lsp_lines")

			-- Setup Mason
			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			-- mason_lspconfig.setup({ ensure_installed = servers_to_install })
			mason_tool_installer.setup({
				ensure_installed = ensure_installed,
				auro_update = true,
				run_on_start = true,
				start_delay = 2000,
			})
			lsp_lines.setup()

			-- used to enable autocompletion (assign to every lsp server config)

			-- >>> CMP
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- >>> Blink
			-- local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Install handlers for LSP servers with their configuration
			mason_lspconfig.setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = capabilities
						lspconfig[server_name].setup(server)
					end,
				},
			})

			-- Keymaps
			local keymap = vim.keymap
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf, silent = true }

					-- set keybinds
					opts.desc = "Show LSP references"
					keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

					opts.desc = "Go to declaration"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

					opts.desc = "Show LSP definitions"
					keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

					opts.desc = "Show LSP implementations"
					keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

					opts.desc = "Show LSP type definitions"
					keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

					opts.desc = "See available code actions"
					keymap.set({ "n", "v" }, "<leader>lc", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

					-- opts.desc = "Smart rename"
					-- keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts) -- smart rename

					opts.desc = "Show buffer diagnostics"
					keymap.set("n", "<leader>lD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

					opts.desc = "Show line diagnostics"
					keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts) -- show diagnostics for line

					opts.desc = "Go to previous diagnostic"
					keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

					opts.desc = "Go to next diagnostic"
					keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

					opts.desc = "Show documentation for what is under cursor"
					keymap.set("n", "<leader>lo", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>ls", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

					opts.desc = "Toggle LSP diagnostics on hover"
					keymap.set("n", "<leader>le", require("lsp_lines").toggle, opts) -- mapping to restart lsp if necessary
				end,
			})
			-- Configuring Appearance
			-- ==> Show diagnostic windows on hover :
			-- vim.diagnostic.config({
			-- 	virtual_text = true,
			-- })
			-- -- Show line diagnostics automatically in hover window
			-- vim.o.updatetime = 250
			-- vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])

			-- -- ==> Show diagnostic inline text :
			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.HINT] = "󰌶",
						[vim.diagnostic.severity.INFO] = "",
					},
					texthl = {
						[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
						[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
						[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
						[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
					},

					numhl = {},
				},
				virtual_text = false, -- Because of lsp-line remove the regular virtual text diagnostics to avoid pointless duplication
				virtual_lines = {
					only_current_line = true,
					highlight_whole_line = true,
				},
				update_in_insert = false,
				underline = false,
				severity_sort = true,
				float = {
					focusable = true,
					style = "border",
					border = "none",
					source = "always",
					header = "",
					prefix = "", -- Could be '■', '▎', 'x'
				},
			})

			-- Change Color of hints
			vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#606060", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#606060", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#606060", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#606060", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#606060", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#e8546a", bg = None })
		end,
	},
	-- >>> Formatter
	{
		"stevearc/conform.nvim",
		enabled = true,
		config = function()
			require("conform").setup({
				notify_on_error = false,
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
				formatters_by_ft = {
					javascript = { "biome" },
					typescript = { "biome" },
					javascriptreact = { "biome" },
					typescriptreact = { "biome" },
					svelte = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					toml = { "taplo" },
					markdown = { "prettier", "injected" },
					graphql = { "prettier" },
					liquid = { "prettier" },
					lua = { "stylua" },
					python = { "isort", "black", "ruff" },
				},
				formatters = {},
			})
			-- Customize the "injected" formatter : For Code Blocks in Markdown
			require("conform").formatters.injected = {
				-- Set the options field
				options = {
					-- Set to true to ignore errors
					ignore_errors = false,
					-- Map of treesitter language to file extension
					-- A temporary file name with this extension will be generated during formatting
					-- because some formatters care about the filename.
					lang_to_ext = {
						bash = "sh",
						c_sharp = "cs",
						elixir = "exs",
						javascript = "js",
						julia = "jl",
						latex = "tex",
						markdown = "md",
						python = "py",
						ruby = "rb",
						rust = "rs",
						teal = "tl",
						r = "r",
						typescript = "ts",
					},
					-- Map of treesitter language to formatters to use
					-- (defaults to the value from formatters_by_ft)
					lang_to_formatters = {
						python = { "isort", "black" },
						javascript = { "prettier" },
						typescript = { "prettier" },
					},
				},
			}
		end,
	},
}
