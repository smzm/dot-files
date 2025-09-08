return {
	{

		"numToStr/Comment.nvim",
		event = {
			"BufReadPost",
			"BufNewFile",
		},
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
		opts = {
			signs = true, -- show icons in the signs column
			sign_priority = 8, -- sign priority
			-- keywords recognized as todo comments
			keywords = {
				FIX = {
					icon = " ", -- icon used for the sign, and in search results
					color = "error", -- can be a hex color, or a named color (see below)
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
					-- signs = false, -- configure signs for some keywords individually
				},
				TODO = { icon = " ", color = "todo" },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				INFO = { icon = " ", color = "info" },
				NOTE = { icon = " ", color = "note" },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			gui_style = {
				fg = "NONE", -- The gui style to use for the fg highlight group.
				bg = "BOLD", -- The gui style to use for the bg highlight group.
			},
			merge_keywords = false, -- when true, custom keywords will be merged with the defaults
			-- highlighting of the line containing the todo comment
			-- * before: highlights before the keyword (typically comment characters)
			-- * keyword: highlights of the keyword
			-- * after: highlights after the keyword (todo text)
			highlight = {
				multiline = true, -- enable multine todo comments
				multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
				multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
				before = "", -- "fg" or "bg" or empty
				keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
				after = "fg", -- "fg" or "bg" or empty
				pattern = [[.*<(KEYWORDS)\s*]], -- pattern or table of patterns, used for highlighting (vim regex)
				comments_only = true, -- uses treesitter to match keywords in comments only
				max_line_len = 400, -- ignore lines longer than this
				exclude = {}, -- list of file types to exclude highlighting
			},
			-- list of named colors where we try to extract the guifg from the
			-- list of highlight groups or use the hex color if hl not found as a fallback
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "#FBBF24" },
				todo = { "#2563EB" },
				info = { "#D7D7D7" },
				note = { "#4e4e4e" },
				hint = { "#10B981" },
				default = { "#7C3AED" },
				test = { "#FF00FF" },
			},
			search = {
				command = "rg",
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
				},
				-- regex that will be used to match keywords.
				-- don't replace the (KEYWORDS) placeholder
				pattern = [[\b(KEYWORDS)]], -- ripgrep regex
				-- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
			},
		},
		config = function(_, opts)
			local todo_comments = require("todo-comments")
			todo_comments.setup(opts)

			local keymap = vim.keymap

			keymap.set(
				"n",
				"<leader>cx",
				"<cmd>TodoTelescope keywords=TODO,FIX,WARNING,HACK,TEST<CR>",
				{ desc = "Search TODO/FIX/WARN/HACK/TEST" }
			)

			keymap.set("n", "<leader>ci", function()
				vim.cmd("TodoTelescope keywords=INFO cwd=" .. vim.fn.expand("%:p:h"))
			end, { desc = "Show INFO comments in current file" })

			keymap.set("n", "<leader>cn", function()
				vim.cmd("TodoTelescope keywords=NOTE cwd=" .. vim.fn.expand("%:p:h"))
			end, { desc = "Show NOTE comments in current file" })

			keymap.set("n", "<leader>cc", function()
				vim.cmd("TodoTelescope keywords=INFO,NOTE cwd=" .. vim.fn.expand("%:p:h"))
			end, { desc = "Show INFO NOTE comments in current file" })

			keymap.set("n", "]]", function()
				todo_comments.jump_next()
			end, { desc = "Next todo comment" })

			keymap.set("n", "[[", function()
				todo_comments.jump_prev()
			end, { desc = "Previous todo comment" })
		end,
	},
	-- TODO:
	-- INFO:
	-- NOTE:
	-- FIX:
	-- WARNING:
	-- HACK:
	-- PERF:
	-- TEST:
}
