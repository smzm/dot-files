return {
	-- >>> LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "folke/neodev.nvim", opts = {} },
			-- Automatically install LSPs to stdpath for neovim
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
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
				ts_ls = {}, -- Javascript, TypeScript
				html = {}, -- HTML
				htmx = {}, -- HTMX
				cssls = {}, -- CSS
				tailwindcss = {}, -- Tailwind CSS
				templ = {}, -- Templ
				pyright = {}, -- Python
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
			local formatters = {
				-- FORMATTERS
				{ "black" }, -- Python
				{ "isort" }, -- Python
				{ "prettierd" }, -- JS and Many More
				{ "prettier" }, -- JS and Many More
				{ "shfmt" }, -- Shell Script
				{ "stylua" }, -- Lua

				-- LINTERS
				{ "codespell" },
				-- { "eslint_d" },
				{ "pylint" },
				{ "shellcheck" },

				--DAP
				{ "debugpy" },
			}

			-- imports
			local lspconfig = require("lspconfig")
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
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
			mason_lspconfig.setup({ ensure_installed = servers })
			mason_tool_installer.setup({ ensure_installed = formatters })
			lsp_lines.setup()

			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()
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

					opts.desc = "Smart rename"
					keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts) -- smart rename

					opts.desc = "Show buffer diagnostics"
					keymap.set("n", "<leader>lD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

					opts.desc = "Show line diagnostics"
					keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts) -- show diagnostics for line

					opts.desc = "Go to previous diagnostic"
					keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

					opts.desc = "Go to next diagnostic"
					keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

					opts.desc = "Show documentation for what is under cursor"
					keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>ls", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
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
					active = true,
					values = {
						{ name = "DiagnosticSignError", text = "" },
						{ name = "DiagnosticSignWarn", text = "" },
						{ name = "DiagnosticSignHint", text = "󰌶" },
						{ name = "DiagnosticSignInfo", text = "" },
					},
				},
				virtual_text = false, -- Because of lsp-line remove the regular virtual text diagnostics to avoid pointless duplication
				virtual_lines = {
					only_current_line = true,
					highlight_whole_line = true,
				},
				update_in_insert = false,
				underline = true,
				severity_sort = true,
				float = {
					focusable = true,
					style = "minimal",
					border = "none",
					source = "always",
					header = "",
					prefix = "", -- Could be '■', '▎', 'x'
				},
			})

			-- Change the Diagnostic symbols in the sign column (gutter)
			-- (not in youtube nvim video)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			-- Change Color of hints
			vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#52577d", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#52577d", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#52577d", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#424561", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#424561", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#e8546a", bg = None })
		end,
	},
	-- >>> Formatter
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					svelte = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					graphql = { "prettier" },
					liquid = { "prettier" },
					lua = { "stylua" },
					python = { "isort", "black" },
				},
				format_on_save = {
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				},
			})
			vim.keymap.set({ "n", "v" }, "<leader>lf", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file or range (in visual mode)" })
		end,
	},
	-- >>> Auto completion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer", -- source for text in buffer
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path", -- source for file system paths
			{
				"L3MON4D3/LuaSnip",
				-- follow latest release.
				version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				-- install jsregexp (optional!).
				build = "make install_jsregexp",
			},
			"saadparwaiz1/cmp_luasnip", -- for autocompletion
			"rafamadriz/friendly-snippets", -- useful snippets
			"onsails/lspkind.nvim", -- vs-code like pictograms
		},
		event = "InsertEnter",
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()

			local function border(hl_name)
				return {
					{ "╭", hl_name },
					{ "─", hl_name },
					{ "╮", hl_name },
					{ "│", hl_name },
					{ "╯", hl_name },
					{ "─", hl_name },
					{ "╰", hl_name },
					{ "│", hl_name },
				}
			end

			vim.api.nvim_set_hl(0, "CmpWin", { bg = "#07080d" })

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
					["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Up>"] = cmp.mapping(function(fallback)
						fallback() -- Allows Up arrow to fall back without interacting with cmp
					end, { "i", "c" }),
					["<Down>"] = cmp.mapping(function(fallback)
						fallback() -- Allows Down arrow to fall back without interacting with cmp
					end, { "i", "c" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" }, -- text within current buffer
					{ name = "path" }, -- file system paths
					{ name = "dadbod" }, -- database
				},
				window = {
					completion = {
						winhighlight = "Normal:CmpWin,FloatBorder:Title,Search:None",
						col_offset = -3,
						side_padding = 0,
					},
					documentation = {
						-- border = border("CmpDocBorder"),
						winhighlight = "Normal:CmpWin",
					},
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind =
							require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. (strings[1] or "") .. " "
						kind.menu = "    (" .. (strings[2] or "") .. ")"

						return kind
					end,
				},
				enabled = function()
					-- Disable nvim-cmp in a telescope prompt
					if buftype == "prompt" then
						return false
					end
					-- Disable completion in comments
					local context = require("cmp.config.context")
					-- Keep command mode completion enabled when cursor is in a comment
					if vim.api.nvim_get_mode().mode == "c" then
						return true
					else
						return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
					end
				end,
			})
		end,
	},
	-- >>> parser
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		lazy = false,
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				init = function()
					-- PERF: no need to load the plugin, if we only need its queries for mini.ai
					local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
					local opts = require("lazy.core.plugin").values(plugin, "opts", false)
					local enabled = false
					if opts.textobjects then
						for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
							if opts.textobjects[mod] and opts.textobjects[mod].enable then
								enabled = true
								break
							end
						end
					end
					if not enabled then
						require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
					end
				end,
			},
			{
				"windwp/nvim-ts-autotag",
			},
			{
				"echasnovski/mini.ai",
				event = "BufReadPre",
				opts = {},
			},
		},
		keys = {
			{ "<c-space>", desc = "Increment selection" },
			{ "<bs>", desc = "Schrink selection", mode = "x" },
		},
		opts = {
			highlight = { enable = true },
			indent = { enable = true, disable = { "python" } },
			autotag = { enable = true },
			context_commentstring = { enable = true, enable_autocmd = false },
			ensure_installed = {
				"bash",
				"diff",
				"dockerfile",
				"gitignore",
				"sql",
				"html",
				"css",
				"scss",
				"json",
				"javascript",
				"typescript",
				"prisma",
				"tsx",
				"jsdoc",
				"lua",
				"markdown",
				"markdown_inline",
				"regex",
				"python",
				"rust",
				"ron",
				"toml",
				"vim",
				"vimdoc",
				"yaml",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = "<nop>",
					node_decremental = "<bs>",
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
						["ii"] = "@conditional.inner",
						["ai"] = "@conditional.outer",
						["il"] = "@loop.inner",
						["al"] = "@loop.outer",
						["at"] = "@comment.outer",
					},
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]f"] = "@function.outer",
						["]]"] = "@class.outer",
					},
					goto_next_end = {
						["]F"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[]"] = "@class.outer",
					},
				},
				-- swap = {
				-- 	enable = true,
				-- 	swap_next = {
				-- 		["<leader>a"] = "@parameter.inner",
				-- 	},
				-- 	swap_previous = {
				-- 		["<leader>A"] = "@parameter.inner",
				-- 	},
				-- },
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
