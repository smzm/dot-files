-- automatically highlighting other uses of the word under the cursor
return {
	"RRethy/vim-illuminate",
	event = "LspAttach",
	opts = {
		filetypes_denylist = {
			"alpha",
			"NvimTree",
			"help",
			"text",
		},
	},
	config = function(_, opts)
		require("illuminate").configure(opts)
		-- hi def IlluminatedWordText gui=underline
		-- Write in lua and disable underline
		vim.api.nvim_set_hl(0, "IlluminatedWordText", { underline = false, bg = "#191920" })
		vim.api.nvim_set_hl(0, "IlluminatedWordRead", { underline = false, bg = "#191920" })
		vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { underline = false, bg = "#191920" })
	end,
}
