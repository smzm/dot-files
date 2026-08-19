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
		{
			"folke/todo-comments.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"ibhagwan/fzf-lua",
			},

			opts = {
				signs = true,
				sign_priority = 8,

				keywords = {
					FIX = {
						icon = " ",
						color = "error",
						alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
					},

					TODO = {
						icon = " ",
						color = "todo",
					},

					WORKING = {
						icon = " ",
						color = "working",
					},

					DONE = {
						icon = " ",
						color = "done",
					},

					HACK = {
						icon = " ",
						color = "warning",
					},

					WARN = {
						icon = " ",
						color = "warning",
						alt = { "WARNING", "XXX" },
					},

					PERF = {
						icon = " ",
						alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
					},

					NOTE = {
						icon = " ",
						color = "hint",
						alt = { "INFO" },
					},

					TEST = {
						icon = "⏲ ",
						color = "test",
						alt = { "TESTING", "PASSED", "FAILED" },
					},
				},

				gui_style = {
					fg = "NONE",
					bg = "BOLD",
				},

				merge_keywords = true,

				highlight = {
					multiline = true,
					multiline_pattern = "^.",
					multiline_context = 10,

					before = "",
					keyword = "wide",
					after = "fg",

					pattern = [[.*<(KEYWORDS)\s*:]],
					comments_only = true,
					max_line_len = 400,
					exclude = {},
				},

				colors = {
					error = {
						"DiagnosticError",
						"ErrorMsg",
						"#ff6767",
					},

					warning = {
						"DiagnosticWarn",
						"WarningMsg",
						"#ffca85",
					},

					info = {
						"DiagnosticInfo",
						"#82e2ff",
					},

					hint = {
						"DiagnosticHint",
						"#61ffca",
					},

					todo = {
						"#8338ec",
					},

					working = {
						"#ff331f",
					},

					done = {
						"#70e000",
					},

					default = {
						"Identifier",
						"#a277ff",
					},

					test = {
						"#f694ff",
					},
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

					pattern = [[\b(KEYWORDS):]],
				},
			},

			config = function(_, opts)
				local todo_comments = require("todo-comments")

				todo_comments.setup(opts)

				local keymap = vim.keymap

				-- Search all task/status comments
				keymap.set(
					"n",
					"<leader>cx",
					"<cmd>TodoTelescope keywords=TODO,WORKING,DONE,FIX,WARNING,HACK,TEST<CR>",
					{
						desc = "Search TODO/WORKING/DONE/FIX/WARN/HACK/TEST",
					}
				)

				-- Search INFO comments in current directory
				keymap.set("n", "<leader>ci", function()
					vim.cmd("TodoTelescope keywords=INFO cwd=" .. vim.fn.expand("%:p:h"))
				end, {
					desc = "Show INFO comments in current file",
				})

				-- Search NOTE comments in current directory
				keymap.set("n", "<leader>cn", function()
					vim.cmd("TodoTelescope keywords=NOTE cwd=" .. vim.fn.expand("%:p:h"))
				end, {
					desc = "Show NOTE comments in current file",
				})

				-- Search INFO + NOTE comments in current directory
				keymap.set("n", "<leader>cc", function()
					vim.cmd("TodoTelescope keywords=INFO,NOTE cwd=" .. vim.fn.expand("%:p:h"))
				end, {
					desc = "Show INFO/NOTE comments in current file",
				})

				-- Jump to next todo comment
				keymap.set("n", "]]", function()
					todo_comments.jump_next()
				end, {
					desc = "Next todo comment",
				})

				-- Jump to previous todo comment
				keymap.set("n", "[[", function()
					todo_comments.jump_prev()
				end, {
					desc = "Previous todo comment",
				})
			end,
		},

		-- TODO:
		-- WORKING:
		-- DONE:
		-- INFO:
		-- NOTE:
		-- FIX:
		-- WARNING:
		-- HACK:
		-- PERF:
		-- TEST:
	},
}
