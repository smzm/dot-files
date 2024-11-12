return {
	-- mason.nvim
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		cmd = "Mason",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	-- null-ls.nvim
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"williamboman/mason.nvim",
		},
		event = {
			"BufReadPre",
			"BufNewFile",
		},
		opts = function()
			local nls = require("null-ls")
			local sources = {
				nls.builtins.formatting.stylua,
				nls.builtins.formatting.markdownlint,
				nls.builtins.diagnostics.markdownlint,
				nls.builtins.formatting.fixjson,
				nls.builtins.formatting.isort,
				nls.builtins.formatting.black.with({
					extra_args = { "--line-length=150" },
				}),
			}
			nls.setup({
				sources = sources,
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						-- Enable formatting on sync
						local format_on_save = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = format_on_save,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({
									bufnr = bufnr,
									filter = function(_client)
										return _client.name == "null-ls"
									end,
								})
							end,
						})
					end
				end,
			})
		end,
	},

	-- nvim-lspconfig
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"jayp0521/mason-null-ls.nvim",
			"SmiteshP/nvim-navic",
		},
		keys = {
			{ "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Goto Definition" },
			{ "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
			{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
			{ "gI", "<cmd>Telescope lsp_implementations<cr>", desc = "Goto Implementation" },
			{ "gy", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Goto T[y]pe Definition" },
			-- { "K", vim.lsp.buf.hover, desc = "Hover" },
			{ "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
			{ "<leader>r", vim.lsp.buf.rename, desc = "Rename" },
		},
		event = {
			"BufReadPre",
			"BufNewFile",
		},
		config = function()
			local lsp_servers = {
				"lua_ls",
				"marksman",
				"pyright",
				"dockerls",
				"docker_compose_language_service",
				"cssls",
				"tailwindcss",
				"emmet_ls",
				"html",
				"jsonls",
				"ts_ls",
				"taplo",
			}

			-- Mason config
			local mason = require("mason")
			mason.setup()

			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				-- list of servers for mason to install
				ensure_installed = lsp_servers,
				-- auto-install configured servers (with lspconfig)
				automatic_installation = true, -- not the same as ensure_installed
			})

			local mason_null_ls = require("mason-null-ls")
			mason_null_ls.setup({
				ensure_installed = {
					"eslint_d", -- ts/js linter
					"prettierd", -- ts/js formatter
					"stylua", -- lua formatter
				},
				-- auto-install configured formatters & linters (with null-ls)
				automatic_installation = true,
			})

			-- LSPConfig
			local lspconfig = require("lspconfig")
			local navic = require("nvim-navic")

			local on_attach = function(client, bufnr)
				navic.attach(client, bufnr)
			end

			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- ==> Show diagnostic windows on hover :
			-- vim.diagnostic.config({
			--    virtual_text = false
			-- })
			-- -- Show line diagnostics automatically in hover window
			-- vim.o.updatetime = 250
			-- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

			-- -- ==> Show diagnostic inline text :
			vim.diagnostic.config({
				virtual_text = true,
				--{
				-- prefix = '●', -- Could be '■', '▎', 'x'
				--},
				severity_sort = true,
				float = {
					source = "always", -- Or "if_many"
				},
				update_in_insert = false,
			})

			-- Show Signs instead of letters : to affect disable lsp-lines.lua
			local signs = { Error = "", Warn = "", Hint = "", Info = "" }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end

			vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#52577d", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#52577d", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#52577d", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#424561", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#424561", bg = bg })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#e8546a", bg = None })

			for _, server in pairs(lsp_servers) do
				if server == "lua_ls" then
					-- configure lua server (with special settings)
					lspconfig[server].setup({
						capabilities = capabilities,
						on_attach = on_attach,
						settings = {
							-- custom settings for lua
							Lua = {
								-- make the language server recognize 'vim' global
								diagnostics = {
									globals = { "vim" },
								},
								workspace = {
									-- make language server aware of runtime files
									library = {
										[vim.fn.expand("$VIMRUNTIME/lua")] = true,
										[vim.fn.stdpath("config") .. "/lua"] = true,
									},
								},
								telemetry = {
									enable = false,
								},
							},
						},
					})
				elseif server == "pyright" then
					lspconfig[server].setup({})
				else
					lspconfig[server].setup({
						capabilities = capabilities,
						on_attach = on_attach,
					})
				end
			end
		end,
	},
	-- Auto-completion : cmp
	{
		"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"FelipeLema/cmp-async-path",
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-calc",
		"rafamadriz/friendly-snippets",
	},
	event = "InsertEnter",
	config = function()
		local cmp = require("cmp")

		local check_backspace = function()
			local col = vim.fn.col(".") - 1
			return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
		end

		local kind_icons = {
			Array = " ",
			Boolean = " ",
			Class = " ",
			Color = " ",
			Constant = " ",
			Constructor = " ",
			Copilot = " ",
			Enum = " ",
			EnumMember = " ",
			Event = " ",
			Field = " ",
			File = " ",
			Folder = " ",
			Function = " ",
			Interface = " ",
			Key = " ",
			Keyword = " ",
			Method = " ",
			Module = " ",
			Namespace = " ",
			Null = " ",
			Number = " ",
			Object = " ",
			Operator = " ",
			Package = " ",
			Property = " ",
			Reference = " ",
			Snippet = " ",
			String = " ",
			Struct = " ",
			Text = " ",
			TypeParameter = " ",
			Unit = " ",
			Value = " ",
			Variable = " ",
		}

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

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
				["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
				["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
				["<C-e>"] = cmp.mapping({
					i = cmp.mapping.abort(),
					c = cmp.mapping.close(),
				}),
				-- Accept currently selected item. If none selected, `select` first item.
				-- Set `select` to `false` to only confirm explicitly selected items.
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				-- ["<Tab>"] = cmp.mapping(function(fallback)
				-- 	if cmp.visible() then
				-- 		cmp.select_next_item()
				-- 	elseif luasnip.expandable() then
				-- 		luasnip.expand()
				-- 	elseif luasnip.expand_or_jumpable() then
				-- 		luasnip.expand_or_jump()
				-- 	elseif check_backspace() then
				-- 		fallback()
				-- 	else
				-- 		fallback()
				-- 	end
				-- end, {
				-- 	"i",
				-- 	"s",
				-- }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, {
					"i",
					"s",
				}),
			}),
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					vim_item.kind = kind_icons[vim_item.kind]
					vim_item.menu = ({
						nvim_lsp = "",
						nvim_lua = "",
						luasnip = "",
						buffer = "",
						path = "",
						emoji = "",
					})[entry.source.name]
					return vim_item
				end,
			},
			sources = {
				{ name = "nvim_lsp" },
				{ name = "nvim_lua" },
				{ name = "buffer" },
				{ name = "async_path" },
				{ name = "calc" },
				{ name = "crates" },
			},
			confirm_opts = {
				behavior = cmp.ConfirmBehavior.Replace,
				select = false,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = {
					border = border("CmpDocBorder"),
					winhighlight = "Normal:CmpDoc",
				},
				--cmp.config.window.bordered(),
			},
			experimental = {
				ghost_text = true,
			},
			enabled = function()
				-- Disable nvim-cmp in a telescope prompt
				buftype = vim.api.nvim_buf_get_option(0, "buftype")
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

		-- cmp-cmdline setup
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{
					name = "cmdline",
					option = {
						ignore_cmds = { "Man", "!" },
					},
				},
			}),
		})
	end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		version = false, -- last release is way too old and doesn't work on Windows
		build = ':TSUpdate',
		event = { 'BufReadPost', 'BufNewFile' },
		lazy = false,
		dependencies = {
		  {
			'nvim-treesitter/nvim-treesitter-textobjects',
			init = function()
			  -- PERF: no need to load the plugin, if we only need its queries for mini.ai
			  local plugin = require('lazy.core.config').spec.plugins['nvim-treesitter']
			  local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
			  local enabled = false
			  if opts.textobjects then
				for _, mod in ipairs({ 'move', 'select', 'swap', 'lsp_interop' }) do
				  if opts.textobjects[mod] and opts.textobjects[mod].enable then
					enabled = true
					break
				  end
				end
			  end
			  if not enabled then
				require('lazy.core.loader').disable_rtp_plugin('nvim-treesitter-textobjects')
			  end
			end,
		  },
		  {
			'windwp/nvim-ts-autotag',
		  },
		},
		keys = {
		  { '<c-space>', desc = 'Increment selection' },
		  { '<bs>', desc = 'Schrink selection', mode = 'x' },
		},
		opts = {
		  highlight = { enable = true },
		  indent = { enable = true, disable = { 'python' } },
		  autotag = { enable = true },
		  context_commentstring = { enable = true, enable_autocmd = false },
		  ensure_installed = {
			'bash',
			'dockerfile',
			'gitignore',
			'sql',
			'html',
			'css',
			'scss',
			'json',
			'javascript',
			'typescript',
			'prisma',
			'tsx',
			'jsdoc',
			'lua',
			'markdown',
			'markdown_inline',
			'regex',
			'python',
			'rust',
			'toml',
			'vim',
			'vimdoc',
			'yaml',
		  },
		  incremental_selection = {
			enable = true,
			keymaps = {
			  init_selection = '<C-space>',
			  node_incremental = '<C-space>',
			  scope_incremental = '<nop>',
			  node_decremental = '<bs>',
			},
		  },
		},
		config = function(_, opts)
		  require('nvim-treesitter.configs').setup(opts)
		end,
	  }	  
}
