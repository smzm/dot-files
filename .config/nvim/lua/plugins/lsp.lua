return { -- >>> LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },

		dependencies = {
			{ "folke/neodev.nvim", opts = {} },

			-- Automatically install LSPs to stdpath for Neovim
			{
				"mason-org/mason.nvim",
				opts = {
					ensure_installed = { "tree-sitter-cli" },
				},
			},

			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP
			{ "j-hui/fidget.nvim", opts = {} },
		},

		config = function()
			--------------------------------------------------------------------
			-- LSP SERVERS
			--------------------------------------------------------------------

			local servers = {
				bashls = {},
				marksman = {},
				sqlls = {},
				eslint = {},
				emmet_language_server = {},

				ts_ls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
					},

					root_markers = {
						"tsconfig.json",
						"jsconfig.json",
						"package.json",
						".git",
					},

					handlers = {
						-- Handle rename requests for certain TypeScript
						-- code actions such as extracting functions/types.
						["_typescript.rename"] = function(_, result, ctx)
							local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

							vim.lsp.util.show_document({
								uri = result.textDocument.uri,
								range = {
									start = result.position,
									["end"] = result.position,
								},
							}, client.offset_encoding)

							vim.lsp.buf.rename()

							return vim.NIL
						end,
					},

					commands = {
						["editor.action.showReferences"] = function(command, ctx)
							local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

							local file_uri, position, references = unpack(command.arguments)

							local quickfix_items = vim.lsp.util.locations_to_items(references, client.offset_encoding)

							vim.fn.setqflist({}, " ", {
								title = command.title,
								items = quickfix_items,
								context = {
									command = command,
									bufnr = ctx.bufnr,
								},
							})

							vim.lsp.util.show_document({
								uri = file_uri,
								range = {
									start = position,
									["end"] = position,
								},
							}, client.offset_encoding)

							vim.cmd("botright copen")
						end,
					},
				},

				html = {},
				cssls = {},
				tailwindcss = {},
				templ = {},

				-- pyright = {},
				ty = {},

				ruff = {
					commands = {
						RuffAutofix = {
							function()
								vim.lsp.buf.execute_command({
									command = "ruff.applyAutofix",
									arguments = {
										{
											uri = vim.uri_from_bufnr(0),
										},
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
										{
											uri = vim.uri_from_bufnr(0),
										},
									},
								})
							end,

							description = "Ruff: Fix imports",
						},
					},
				},

				dockerls = {},
				docker_compose_language_service = {},
				jsonls = {},
				taplo = {},

				-- rust_analyzer = {}, -- Installed/configured by rustaceanvim

				lua_ls = {
					settings = {
						Lua = {
							runtime = {
								version = "LuaJIT",
							},

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
								disable = {
									"missing-fields",
									"undefined-global",
								},
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

			--------------------------------------------------------------------
			-- MASON TOOLS
			--------------------------------------------------------------------

			local ensure_installed = vim.tbl_keys(servers)

			vim.list_extend(ensure_installed, {
				-- FORMATTERS
				"black",
				"isort",
				"shfmt",
				"stylua",
				"biome",
				"latexindent",

				-- LINTERS
				"codespell",
				"ruff",
				"shellcheck",

				-- DAP
				"debugpy",
				"codelldb",
			})

			--------------------------------------------------------------------
			-- IMPORTS
			--------------------------------------------------------------------

			local lspconfig = require("lspconfig")
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")

			--------------------------------------------------------------------
			-- MASON
			--------------------------------------------------------------------

			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			mason_tool_installer.setup({
				ensure_installed = ensure_installed,
				auto_update = true,
				run_on_start = true,
				start_delay = 2000,
			})

			--------------------------------------------------------------------
			-- LSP CAPABILITIES
			--------------------------------------------------------------------

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- For Blink instead:
			-- local capabilities =
			--     require("blink.cmp").get_lsp_capabilities()

			--------------------------------------------------------------------
			-- LSP SERVER SETUP
			--------------------------------------------------------------------

			mason_lspconfig.setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}

						server.capabilities = capabilities

						lspconfig[server_name].setup(server)
					end,
				},
			})

			--------------------------------------------------------------------
			-- DIAGNOSTIC CONFIGURATION
			--
			-- Diagnostics are completely hidden by default.
			--
			-- They are shown only when <Alt-e> is pressed.
			--------------------------------------------------------------------

			local diagnostic_opts = {
				-- Diagnostic signs in the sign column.
				--
				-- Disabled by default because we want diagnostics to be
				-- completely hidden until <Alt-e> is pressed.
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

				-- Do not display diagnostics inline.
				virtual_text = false,

				-- Do not display diagnostics on virtual lines.
				virtual_lines = false,

				-- Do not underline problematic code.
				underline = true,

				-- Don't update diagnostics while typing.
				update_in_insert = false,

				-- Sort diagnostics by severity.
				severity_sort = {
					reverse = false,
				},

				-- Configuration for diagnostic floating windows.
				float = {
					focusable = true,

					focus = true,

					style = "minimal",

					border = "rounded",

					source = "always",

					header = "",

					prefix = " ",
				},
			}

			vim.diagnostic.config(diagnostic_opts)

			--------------------------------------------------------------------
			-- LSP ATTACH
			--------------------------------------------------------------------

			local keymap = vim.keymap

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),

				callback = function(ev)
					local opts = {
						buffer = ev.buf,
						silent = true,
					}

					----------------------------------------------------------------
					-- NAVIGATION
					----------------------------------------------------------------

					opts.desc = "Show LSP references"
					keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

					opts.desc = "Go to declaration"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					opts.desc = "Show LSP definitions"
					keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

					opts.desc = "Go to definition"
					keymap.set("n", "gD", vim.lsp.buf.definition, opts)

					opts.desc = "Show LSP type definitions"
					keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

					----------------------------------------------------------------
					-- CODE ACTIONS
					----------------------------------------------------------------

					opts.desc = "See available code actions"
					keymap.set({ "n", "v" }, "<leader>lc", vim.lsp.buf.code_action, opts)

					----------------------------------------------------------------
					-- RENAME
					----------------------------------------------------------------

					opts.desc = "Smart rename"
					keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)

					----------------------------------------------------------------
					-- DIAGNOSTICS
					----------------------------------------------------------------

					-- Show diagnostics for the current line in a popup or Show LSP hover/documentation instead.
					-- Diagnostics remain completely hidden until this mapping is pressed.
					opts.desc = "Show diagnostic or documentation"
					keymap.set("n", "<M-e>", function()
						local line = vim.api.nvim_win_get_cursor(0)[1] - 1

						local diagnostics = vim.diagnostic.get(0, {
							lnum = line,
						})

						if #diagnostics > 0 then
							vim.diagnostic.open_float({
								scope = "line",
								focusable = true,
								border = "rounded",
							})
						else
							vim.lsp.buf.hover()
						end
					end, opts)

					----------------------------------------------------------------
					-- DIAGNOSTIC NAVIGATION
					----------------------------------------------------------------

					opts.desc = "Go to previous diagnostic"
					keymap.set("n", "<leader>lxn", vim.diagnostic.goto_prev, opts)

					opts.desc = "Go to next diagnostic"
					keymap.set("n", "<leader>lxN", vim.diagnostic.goto_next, opts)

					----------------------------------------------------------------
					-- DOCUMENTATION
					----------------------------------------------------------------

					opts.desc = "Show documentation for what is under cursor"
					keymap.set("n", "<leader>ld", vim.lsp.buf.hover, opts)

					----------------------------------------------------------------
					-- LSP RESTART
					----------------------------------------------------------------

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>", opts)

					----------------------------------------------------------------
					-- INLAY HINTS
					----------------------------------------------------------------

					opts.desc = "Enable Inlay Hints"
					keymap.set("n", "<M-r>", function()
						local enabled = vim.lsp.inlay_hint.is_enabled({
							bufnr = ev.buf,
						})

						vim.lsp.inlay_hint.enable(not enabled, {
							bufnr = ev.buf,
						})
					end, opts)
				end,
			})

			--------------------------------------------------------------------
			-- HIDE DIAGNOSTICS WHILE INSERTING
			--------------------------------------------------------------------

			vim.api.nvim_create_autocmd("InsertEnter", {
				group = vim.api.nvim_create_augroup("DiagnosticInsertMode", { clear = true }),

				callback = function()
					vim.diagnostic.config({
						signs = false,
						virtual_text = false,
						virtual_lines = false,
						underline = false,
					})
				end,
			})

			--------------------------------------------------------------------
			-- RESTORE DIAGNOSTIC CONFIGURATION
			--------------------------------------------------------------------

			vim.api.nvim_create_autocmd("InsertLeave", {
				group = vim.api.nvim_create_augroup("DiagnosticNormalMode", { clear = true }),

				callback = function()
					vim.diagnostic.config(diagnostic_opts)
				end,
			})

			--------------------------------------------------------------------
			-- RESIZE
			--------------------------------------------------------------------

			vim.api.nvim_create_autocmd("VimResized", {
				callback = function()
					vim.diagnostic.hide()
					vim.diagnostic.show()
				end,
			})
		end,
	},

	----------------------------------------------------------------------
	-- LSP SIGNATURE
	----------------------------------------------------------------------

	{
		"ray-x/lsp_signature.nvim",
		event = "InsertEnter",

		config = function()
			vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", {
				fg = "#606060",
				bg = "NONE",
			})

			local function escape_term_codes(str)
				return vim.api.nvim_replace_termcodes(str, true, false, true)
			end

			local function is_float_open(window_id)
				return window_id and window_id ~= 0 and vim.api.nvim_win_is_valid(window_id)
			end

			local function scroll_float(mapping)
				local win_id = _G._LSP_SIG_CFG and _G._LSP_SIG_CFG.winnr

				if is_float_open(win_id) then
					vim.fn.win_execute(win_id, ":normal! " .. mapping)
				end
			end

			local scroll_up_mapping = escape_term_codes("<c-u>")

			local scroll_down_mapping = escape_term_codes("<c-d>")

			vim.keymap.set("i", "<c-u>", function()
				scroll_float(scroll_up_mapping)
			end, {})

			vim.keymap.set("i", "<c-d>", function()
				scroll_float(scroll_down_mapping)
			end, {})

			require("lsp_signature").setup({
				bind = true,

				hint_enable = false,

				hint_prefix = {
					above = "↙ ",
					current = "← ",
					below = "↖ ",
				},

				padding = "  ",

				handler_opts = {
					border = "none",
				},
			})
		end,
	},

	----------------------------------------------------------------------
	-- FORMATTER
	----------------------------------------------------------------------

	{
		"stevearc/conform.nvim",

		enabled = true,

		config = function()
			require("conform").setup({
				notify_on_error = false,

				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = false,
				},

				formatters_by_ft = {
					javascript = { "biome" },
					typescript = { "biome" },
					javascriptreact = { "biome" },
					typescriptreact = { "biome" },

					svelte = { "prettier" },

					css = { "biome" },
					html = { "biome" },

					json = { "biome" },
					jsonc = { "biome" },

					yaml = { "prettier" },
					toml = { "taplo" },

					markdown = {
						"prettier",
						"injected",
					},

					graphql = { "prettier" },
					liquid = { "prettier" },

					lua = { "stylua" },

					python = {
						"isort",
						"black",
					},

					tex = { "latexindent" },

					rust = {
						"rustfmt",
						lsp_format = "fallback",
					},
				},

				formatters = {},
			})

			----------------------------------------------------------------
			-- MARKDOWN INJECTED FORMATTER
			----------------------------------------------------------------

			require("conform").formatters.injected = {
				options = {
					ignore_errors = false,

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
						mojo = "mojo",
					},

					lang_to_formatters = {
						python = {
							"isort",
							"black",
						},

						javascript = {
							"prettier",
						},

						typescript = {
							"prettier",
						},

						latex = {
							"latexindent",
						},

						mojo = {
							"mojo_format",
						},
					},
				},
			}
		end,
	},
}
