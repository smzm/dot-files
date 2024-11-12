--  A neovim plugin to keep your cursor at the center of the screen.
return {
	"arnamak/stay-centered.nvim",
	config = function()
		require("stay-centered").setup()
	end,
}
