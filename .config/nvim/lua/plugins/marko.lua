return {
	"developedbyed/marko.nvim",
	config = function()
		require("marko").setup({
			width = 50,
			height = 100,
			border = "rounded",
			title = " Marks ",
			virtual_text = {
				enabled = false, -- Enable virtual text marks
				icon = "●", -- Icon to display
				hl_group = "Comment", -- Highlight group
				position = "overlay", -- Position: "eol" or "overlay"
			},
		})

		vim.keymap.set("n", "<M-`>", function()
			require("marko").show_marks()
		end, { desc = "Show marks popup" })
	end,
}
