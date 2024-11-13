-- Neovim plugin for splitting/joining blocks of code
return {
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
}
