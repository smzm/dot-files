-- return {
-- 	dir = "~/.config/nvim/lua/themes/monoshine/", -- local pathk
-- 	lazy = false,
-- 	priority = 1000, -- make sure it's loaded early
-- 	config = function()
-- 		vim.cmd.colorscheme("monoshine")
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
			-- vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
			-- vim.cmd([[colorscheme aura-dark]])
			-- -- Hilights for the cursor and visual selection
			-- vim.cmd([[highlight Normal gui=NONE guibg=NONE]])
			-- vim.cmd([[highlight StatusLine  gui=NONE guifg=NONE guibg=NONE]])
			-- vim.cmd([[highlight StatusLineNC  gui=NONE guifg=NONE guibg=NONE]])
			-- vim.cmd([[highlight Visual ctermfg=NONE ctermbg=15 gui=NONE guifg=NONE guibg=#3d375e]])
			-- vim.cmd([[highlight Structure ctermfg=NONE ctermbg=15 gui=NONE guifg=#DEDEDE guibg=NONE]])
			-- vim.cmd([[highlight Indentation ctermfg=NONE ctermbg=15 gui=NONE guifg=#1F1E27 guibg=NONE]])
			-- vim.cmd([[highlight IndentBlanklineContextChar ctermfg=NONE ctermbg=15 gui=NONE guifg=#2B2A35 guibg=NONE]])
			-- vim.cmd([[highlight NormalFloat gui=NONE guibg=#0E0F14]])
			-- vim.cmd([[highlight FloatBorder gui=NONE guibg=#0E0F14 guifg=#595A61]])
			-- vim.cmd([[highlight LspReferenceRead ctermfg=NONE gui=NONE guifg=NONE guibg=NONE]])
			-- vim.cmd([[highlight LspReferenceText ctermfg=NONE gui=NONE guifg=NONE guibg=#232133]])
			-- vim.cmd([[highlight LspReferenceWrite ctermfg=NONE gui=NONE guifg=NONE guibg=#3d375e]])
			-- vim.cmd([[highlight MatchParen gui=NONE guifg=NONE guibg=#3d375e]])
			-- vim.cmd([[highlight CursorLine gui=NONE guifg=NONE guibg=#1E1D2C]])
			-- vim.cmd([[highlight WinSeparator ctermfg=NONE gui=NONE guifg=#a277ff]])
			-- vim.cmd([[highlight HighlightedBG ctermfg=NONE gui=NONE guibg=#111216]])
			--
			-- -- Markdown
			-- vim.cmd([[highlight CodeBlock gui=NONE guibg=#111015]])
			-- vim.cmd([[highlight CodeBorder gui=NONE guibg=#111015]])
			-- vim.cmd([[highlight InlineCodeBlock gui=NONE guibg=#111015]])
		end,
	},
	{
		"tiagovla/tokyodark.nvim",
		opts = {
			-- custom options here
			transparent_background = true, -- set background to transparent
			gamma = 1.00, -- adjust the brightness of the theme
			styles = {
				comments = { italic = true }, -- style for comments
				keywords = { italic = false }, -- style for keywords
				identifiers = { italic = true }, -- style for identifiers
				functions = {}, -- style for functions
				variables = {}, -- style for variables
			},
			custom_highlights = {} or function(highlights, palette)
				return {}
			end, -- extend highlights
			custom_palette = {} or function(palette)
				return {}
			end, -- extend palette
			terminal_colors = true, -- enable terminal colors
		},
		config = function(_, opts)
			-- require("tokyodark").setup(opts) -- calling setup is optional
			-- vim.cmd([[colorscheme tokyodark]])
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato",
			transparent_background = true,
			float = {
				transparent = true, -- enable transparent floating windows
				solid = false, -- use solid styling for floating windows, see |winborder|
			},
			term_colors = true,
			dim_inactive = {
				enabled = false, -- dims the background color of inactive window
			},
			styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
				comments = { "italic" }, -- Change the style of comments
				conditionals = { "italic" },
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
				operators = {},
				-- miscs = {}, -- Uncomment to turn off hard-coded styles
			},
			lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
				virtual_text = {
					errors = { "italic" },
					hints = { "italic" },
					warnings = { "italic" },
					information = { "italic" },
					ok = { "italic" },
				},
				underlines = {
					errors = { "underline" },
					hints = {},
					warnings = { "underline" },
					information = {},
					ok = {},
				},
				inlay_hints = {
					background = true,
				},
				auto_integrations = true,
			},
		},

		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin-macchiato")

			vim.cmd([[highlight Indentation ctermfg=NONE ctermbg=15 gui=NONE guifg=#262533 guibg=NONE]])
			vim.cmd([[highlight IndentBlanklineContextChar ctermfg=NONE ctermbg=15 gui=NONE guifg=#2B2A35 guibg=NONE]])
		end,
	},
}
