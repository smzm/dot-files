return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = { char = "│", highlight = { "Indentation" } }, -- ┊ Conceal defined in core/highlight
		scope = { enabled = true, highlight = { "IndentBlanklineContextChar" }, show_start = false },
	},
}
