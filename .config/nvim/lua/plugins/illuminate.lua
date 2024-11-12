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
	end,
}
