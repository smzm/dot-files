return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false, -- Load immediately
		config = function()
			require("nvim-treesitter").setup({
				-- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
				install_dir = vim.fn.stdpath("data") .. "/site",
			})
			require("nvim-treesitter").install({
				"rust",
				"javascript",
				"typescript",
				"python",
				"bash",
				"css",
				"html",
				"dockerfile",
				"json",
				"latex",
				"lua",
				"markdown",
				"markdown_inline",
				"nginx",
				"regex",
				"tsv",
				"csv",
				"yaml",
			})

			-- Enable syntax highlighting for common filetypes
			local highlight_filetypes = {
				"lua",
				"vim",
				"javascript",
				"typescript",
				"python",
				"rust",
				"html",
				"css",
				"json",
				"yaml",
				"markdown",
				"bash",
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = highlight_filetypes,
				callback = function()
					vim.treesitter.start()
				end,
			})
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
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"echasnovski/mini.diff",
		config = function()
			local diff = require("mini.diff")
			diff.setup({
				-- Disabled by default
				source = diff.gen_source.none(),
			})
		end,
	},
	{
		"echasnovski/mini.ai",
		event = "BufReadPre",
		config = function()
			local diff = require("mini.diff")
			diff.setup({
				-- Disabled by default
				source = diff.gen_source.none(),
			})
		end,
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
				multiwindow = true, -- Enable multiwindow support.
				max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
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
	{
		-- Folding
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			vim.o.foldcolumn = "1" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			})
		end,
	},
}
