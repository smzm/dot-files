return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
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
				event = "InsertEnter",
			},
			{
				"echasnovski/mini.ai",
				event = "BufReadPre",
				opts = {},
			},
			{
				"andymass/vim-matchup",
				init = function()
					vim.g.matchup_matchparen_offscreen = {}
				end,
			},
			{
				-- Wisely add "end" in various filetypes
				"RRethy/nvim-treesitter-endwise",
			},
			{
				"nvim-treesitter/nvim-treesitter-context",
				event = "VeryLazy", -- Load on very lazy events
				config = function()
					-- Custom highlight settings for sticky scroll
					-- vim.api.nvim_set_hl(0, "TreesitterContext", { link = "ReversedH1" })
					-- vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { link = "Keyword" })
					-- vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "Keyword" })
					-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { link = "Keyword" })
					-- vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { link = "Keyword" })

					require("treesitter-context").setup({
						enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
						multiwindow = false, -- Enable multiwindow support.
						max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
						min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
						line_numbers = true,
						multiline_threshold = 20, -- Maximum number of lines to show for a single context
						trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
						mode = "topline", -- Line used to calculate context. Choices: 'cursor', 'topline'
						-- Separator between context and content. Should be a single character string, like '-'.
						-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
						separator = nil,
						zindex = 20, -- The Z-index of the context window
						on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
					})
				end,
			},
		},
		keys = {
			{ "<c-space>", desc = "Increment selection" },
			{ "<bs>", desc = "Schrink selection", mode = "x" },
		},
		opts = {
			highlight = {
				enable = true,
				disable = function(_, buf)
					local max_filesize = 500 * 1024 -- 500 KB
					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},
			indent = { enable = false, disable = { "python" } },
			autotag = { enable = true },
			endwise = { enable = true },
			matchup = {
				enable = true,
				include_match_words = true,
			},
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
				"xml",
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
	{
		-- Neovim plugin for splitting/joining blocks of code
		"Wansmer/treesj",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			max_join_length = 150,
		},
		config = function()
			-- For extending default preset with `recursive = true`
			vim.keymap.set("n", "<leader>ss", function()
				require("treesj").toggle({ split = { recursive = true } })
			end, { desc = "Split/Join toggle line" })
		end,
	},
}
