-- Neovim plugin to improve the default vim.ui interfaces
return {
	{

		"stevearc/dressing.nvim",
		event = "VeryLazy",
		config = function()
			require("dressing").setup({
				input = {
					override = function(conf)
						conf.col = -1
						conf.row = 0
						return conf
					end,
				},
			})
		end,
	},
	{
		"smjonas/inc-rename.nvim",
		config = function()
			vim.keymap.set("n", "<leader>rn", function()
				return ":IncRename " .. vim.fn.expand("<cword>")
			end, { expr = true, desc = "Rename word under cursor" })
			require("inc_rename").setup({
				input_bunfer_type = "dressing",
			})
		end,
	},
}
