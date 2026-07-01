return {
	"mikavilpas/yazi.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},

	keys = {
		{ "<Tab>", "<cmd>Yazi<CR>", desc = "Toggle Yazi", mode = "n" },
	},
	opts = {
		open_for_directories = false, -- change to true if you want Yazi for dirs too
		-- other options...
	},
}
