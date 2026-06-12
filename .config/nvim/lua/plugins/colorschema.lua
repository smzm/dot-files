-- return {
-- 	dir = "~/.config/nvim/lua/themes/open/", -- local pathk
-- 	lazy = false,
-- 	priority = 1000, -- make sure it's loaded early
-- 	config = function()
-- 		vim.cmd.colorscheme("open")
-- 	end,
-- }
--
-- ======================== Aura Dark Theme ==========================
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
			vim.cmd([[highlight StatusLine  gui=NONE guifg=NONE guibg=NONE]])
			vim.cmd([[highlight StatusLineNC  gui=NONE guifg=NONE guibg=NONE]])
			vim.cmd([[highlight Visual ctermfg=NONE ctermbg=15 gui=NONE guifg=NONE guibg=#3d375e]])
			vim.cmd([[highlight Structure ctermfg=NONE ctermbg=15 gui=NONE guifg=#DEDEDE guibg=NONE]])
			vim.cmd([[highlight Indentation ctermfg=NONE ctermbg=15 gui=NONE guifg=#1F1E27 guibg=NONE]])
			vim.cmd([[highlight IndentBlanklineContextChar ctermfg=NONE ctermbg=15 gui=NONE guifg=#2B2A35 guibg=NONE]])
			vim.cmd([[highlight LspReferenceRead ctermfg=NONE gui=NONE guifg=NONE guibg=NONE]])
			vim.cmd([[highlight LspReferenceText ctermfg=NONE gui=NONE guifg=NONE guibg=#232133]])
			vim.cmd([[highlight LspReferenceWrite ctermfg=NONE gui=NONE guifg=NONE guibg=#3d375e]])
			vim.cmd([[highlight MatchParen gui=NONE guifg=NONE guibg=#3d375e]])
			vim.cmd([[highlight CursorLine gui=NONE guifg=NONE guibg=#1E1D2C]])

			-- Markdown
			vim.cmd([[highlight CodeBlock gui=NONE guibg=#111015]])
			vim.cmd([[highlight CodeBorder gui=NONE guibg=#111015]])
			vim.cmd([[highlight InlineCodeBlock gui=NONE guibg=#111015]])
		end,
	},
}
