-- A small Neovim plugin for previewing definitions using floating windows.
return {
	"rmagatti/goto-preview",
	config = function()
		require("goto-preview").setup({
			default_mappings = true,
		})
	end,
}
