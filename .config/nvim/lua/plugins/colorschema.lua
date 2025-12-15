return {
	dir = "~/.config/nvim/lua/themes/monoshine/", -- local pathk
	lazy = false,
	priority = 1000, -- make sure it's loaded early
	config = function()
		vim.cmd.colorscheme("monoshine")
	end,
}

-- ======================== Aura Dark Theme ==========================
-- return {
-- 	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
-- 	{
-- 		"baliestri/aura-theme",
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function(plugin)
-- 			vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
-- 			vim.cmd([[colorscheme aura-dark]])
-- 			-- Hilights for the cursor and visual selection
-- 			vim.cmd([[highlight Visual ctermfg=NONE ctermbg=15 gui=NONE guifg=NONE guibg=#3d375e]])
-- 		end,
-- 	},
-- }
