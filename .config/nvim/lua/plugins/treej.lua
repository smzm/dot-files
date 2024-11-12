-- Neovim plugin for splitting/joining blocks of code
return {
	"Wansmer/treesj",
	keys = {
		"<leader>m",
		"<leader>j",
		"<leader>s",
	},
	dependencies = "nvim-treesitter/nvim-treesitter",
	opts = { max_join_length = 150 },
}
