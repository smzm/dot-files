return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local todo_comments = require("todo-comments")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "]t", function()
			todo_comments.jump_next()
		end, { desc = "Next todo comment" })

		keymap.set("n", "[t", function()
			todo_comments.jump_prev()
		end, { desc = "Previous todo comment" })

		todo_comments.setup({
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "", "WarningMsg", "#FBBF24" },
				info = { "", "#2563EB" },
				hint = { "", "#10B981" },
				default = { "", "#7C3AED" },
				test = { "", "#FF00FF" },
			},
		})
	end,
}
-- TODO :
-- NOTE :
-- INFO:
-- FIX :
-- WARNING:
-- PERF:
-- HACK:
-- TEST:
