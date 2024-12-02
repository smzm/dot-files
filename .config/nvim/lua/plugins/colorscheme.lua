return {
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{
		"baliestri/aura-theme",
		lazy = false,
		priority = 1000,
		config = function(plugin)
			vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
			vim.cmd([[colorscheme aura-dark]])
			-- Hilights for the cursor and visual selection
			vim.cmd([[highlight Visual ctermfg=NONE ctermbg=15 gui=NONE guifg=NONE guibg=#3d375e]])
		end,
	},
}
