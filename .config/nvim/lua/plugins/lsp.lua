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
		},
		config = function()
			local servers = {
				bashls = {}, -- Bash
				marksman = {}, -- Markdown lsp
				sqlls = {}, -- SQL
				eslint = {}, -- React/NextJS/Svelte
				emmet_language_server = {}, -- HTML
				ts_ls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
					},
					root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
					handlers = {
						-- handle rename request for certain code actions like extracting functions / types
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
				{ "rustfmt" }, -- Rust
				{ "shfmt" }, -- Shell Script
				{ "stylua" }, -- Lua
				{ "biome" }, -- JS and Many More
				-- { "prettierd" }, -- JS and Many More
				-- { "prettier" }, -- JS and Many More
				{ "latexindent" },
				-- LINTERS
				{ "codespell" },
				{ "ruff" },
				-- { "eslint_d" },
				{ "shellcheck" },
				--DAP
				{ "debugpy" },
				{ "codelldb" }, -- Rust Debugger
			})

			-- imports
			local lspconfig = require("lspconfig")
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")

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
				auto_update = true,
				run_on_start = true,
				start_delay = 2000,
			})

			-- used to enable autocompletion (assign to every lsp server config)

			-- >>> CMP
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- >>> Blink
			-- local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Install handlers for LSP servers with their configuration
			mason_lspconfig.setup({
				handlers = {
					function(server_name)
						local server = (servers and servers[server_name]) or {}
						server.capabilities = capabilities
						lspconfig[server_name].setup(server)
					end,
				},
			})

			-- Install Mojo manually because it's not in mason
			vim.lsp.config("mojo", {
				capabilities = capabilities,
				cmd = { "mojo-lsp-server" },
				filetypes = { "mojo" },
				root_markers = { "mojoproject", ".git", "mojo.toml" },
			})
			vim.lsp.enable("mojo")

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

					opts.desc = "Smart rename"
					keymap.set("n", "<F2>", vim.lsp.buf.rename, opts) -- smart rename

					opts.desc = "Show buffer diagnostics"
					keymap.set("n", "<leader>lX", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

					opts.desc = "Show line diagnostics"
					keymap.set("n", "<leader>lx", vim.diagnostic.open_float, opts) -- show diagnostics for line

					opts.desc = "Go to previous diagnostic"
					keymap.set("n", "<leader>lxn", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

					opts.desc = "Go to next diagnostic"
					keymap.set("n", "<leader>lxN", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

					opts.desc = "Show documentation for what is under cursor"
					keymap.set("n", "<leader>ld", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>lr", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
				end,
			})

			-- INFO: Configuring Appearance of LSP diagnostics
			local function buf_to_win(bufnr)
				local current_win = vim.fn.win_getid()

				-- Check if current window has the buffer
				if vim.fn.winbufnr(current_win) == bufnr then
					return current_win
				end

				-- Otherwise, find a visible window with this buffer
				local win_ids = vim.fn.win_findbuf(bufnr)
				local current_tabpage = vim.fn.tabpagenr()

				for _, win_id in ipairs(win_ids) do
					if vim.fn.win_id2tabwin(win_id)[1] == current_tabpage then
						return win_id
					end
				end

				return 0
			end
			-- Split a string into multiple lines, each no longer than max_width
			-- The split will only occur on spaces to preserve readability
			-- @param str string
			-- @param max_width integer
			local function split_line(str, max_width)
				if #str <= max_width then
					return { str }
				end

				local lines = {}
				local current_line = ""

				for word in string.gmatch(str, "%S+") do
					-- If adding this word would exceed max_width
					if #current_line + #word + 1 > max_width then
						-- Add the current line to our results
						table.insert(lines, current_line)
						current_line = word
					else
						-- Add word to the current line with a space if needed
						if current_line ~= "" then
							current_line = current_line .. " " .. word
						else
							current_line = word
						end
					end
				end

				-- Don't forget the last line
				if current_line ~= "" then
					table.insert(lines, current_line)
				end

				return lines
			end

			---@param diagnostic vim.Diagnostic
			local function virtual_lines_format(diagnostic)
				-- Only render hints on the current line
				-- Note this MUST be paired with an autocmd that hides/shows diagnostics to force a re-render
				-- if diagnostic.severity == vim.diagnostic.severity.HINT and diagnostic.lnum + 1 ~= vim.fn.line(".") then
				-- 	return nil
				-- end

				local win = buf_to_win(diagnostic.bufnr)
				if win == 0 then
					return nil
				end
				-- Get window info and check if it exists
				local win_info = vim.fn.getwininfo(win)
				if not win_info or #win_info == 0 then
					return nil
				end
				local sign_column_width = win_info[1].textoff
				local text_area_width = vim.api.nvim_win_get_width(win) - sign_column_width
				local center_width = 30
				local left_width = 1

				---@type string[]
				local lines = {}
				for msg_line in diagnostic.message:gmatch("([^\n]+)") do
					local max_width = text_area_width - diagnostic.col - center_width - left_width
					vim.list_extend(lines, split_line(msg_line, max_width))
				end

				return table.concat(lines, "\n")
			end

			-- Re-render diagnostics when the window is resized
			vim.api.nvim_create_autocmd("VimResized", {
				callback = function()
					vim.diagnostic.hide()
					vim.diagnostic.show()
				end,
			})
			-- Set DiagnosticUnderlineError to red color
			vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { fg = "#E38C8C" })

			-- ==> Show diagnostic inline text :
			local opts = {
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
					current_line = true,
					format = virtual_lines_format,
				},
				update_in_insert = false, -- Don't update diagnostics in insert mode
				underline = true,
				severity_sort = { reverse = false },
				float = {
					focusable = true,
					style = "border",
					border = "none",
					source = "always",
					header = "",
					prefix = " ", -- Could be '■', '▎', 'x'
				},
			}
			vim.diagnostic.config(opts)

			-- Hide diagnostics in insert mode, show in normal mode
			vim.api.nvim_create_autocmd("InsertEnter", {
				group = vim.api.nvim_create_augroup("DiagnosticInsertMode", { clear = true }),
				callback = function()
					vim.diagnostic.config({
						virtual_text = false,
						virtual_lines = false,
						signs = false,
						underline = false,
						update_in_insert = false,
					})
				end,
			})

			vim.api.nvim_create_autocmd("InsertLeave", {
				group = vim.api.nvim_create_augroup("DiagnosticNormalMode", { clear = true }),
				callback = function()
					vim.diagnostic.config(opts)
				end,
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
	{
		"ray-x/lsp_signature.nvim",
		event = "InsertEnter",
		config = function(_, opts)
			vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { fg = "#606060", bg = None })
			local function escape_term_codes(str)
				return vim.api.nvim_replace_termcodes(str, true, false, true)
			end

			local function is_float_open(window_id)
				return window_id and window_id ~= 0 and vim.api.nvim_win_is_valid(window_id)
			end

			local function scroll_float(mapping)
				local win_id = _G._LSP_SIG_CFG.winnr

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
					above = "↙ ", -- when the hint is on the line above the current line
					current = "← ", -- when the hint is on the same line
					below = "↖ ", -- when the hint is on the line below the current line
				},
				padding = "  ",
				handler_opts = {
					border = "none",
				},
			})
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
					markdown = { "prettier", "injected" },
					graphql = { "prettier" },
					liquid = { "prettier" },
					lua = { "stylua" },
					python = { "isort", "black" },
					tex = { "latexindent" },
					rust = { "rustfmt", lsp_format = "fallback" },
					mojo = { "mojo_format" },
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
						mojo = "mojo",
					},
					-- Map of treesitter language to formatters to use
					-- (defaults to the value from formatters_by_ft)
					lang_to_formatters = {
						python = { "isort", "black" },
						javascript = { "prettier" },
						typescript = { "prettier" },
						latex = { "latexindent" },
						mojo = { "mojo_format" },
					},
				},
			}
		end,
	},
}
