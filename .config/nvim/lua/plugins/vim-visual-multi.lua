-- Multiple cursors plugin for vim/neovim
return {
	"mg979/vim-visual-multi",
	branch = "master", -- optional but safe
	init = function()
		vim.g.VM_mouse_mappings = 1
		vim.g.VM_maps = {
			["Find Under"] = "<C-d>", -- like VSCode's Ctrl+D
			["Find Subword Under"] = "<C-d>",
			-- Add cursors vertically with Ctrl+Up / Ctrl+Down
			["Select Cursor Down"] = "<C-Down>",
			["Select Cursor Up"] = "<C-Up>",
			["Select All"] = "",
			["Start Regex Search"] = "",
			["Add Cursor At Pos"] = "",
			["Reselect Last"] = "",
		}
	end,
}
