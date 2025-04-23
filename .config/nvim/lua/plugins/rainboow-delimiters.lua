--  Rainbow delimiters for Neovim with Tree-sitter
return {
	"hiphish/rainbow-delimiters.nvim",
	config = function()
		local rainbow_delimiters = require("rainbow-delimiters")

		-- Set up the global configuration for rainbow delimiters
		vim.g.rainbow_delimiters = {
			strategy = {
				[""] = rainbow_delimiters.strategy["global"], -- Global strategy for all file types
				vim = rainbow_delimiters.strategy["local"], -- Local strategy for Vim script
			},
			query = {
				[""] = "rainbow-delimiters", -- Default query
				lua = "rainbow-blocks", -- Custom query for Lua
			},
			highlight = {
				"RainbowDelimiterCyan",
				"RainbowDelimiterBlue",
				"RainbowDelimiterYellow",
				"RainbowDelimiterRed",
				"RainbowDelimiterViolet",
				"RainbowDelimiterGreen",
				"RainbowDelimiterGray",
			},
		}

		-- Define custom colors for each delimiter level
		vim.cmd([[
                highlight RainbowDelimiterGray guifg=#363636
                highlight RainbowDelimiterCyan guifg=#616161
                highlight RainbowDelimiterRed guifg=#878787
                highlight RainbowDelimiterYellow guifg=#C9C9C9
                highlight RainbowDelimiterBlue guifg=#D9D9D9
                highlight RainbowDelimiterGreen guifg=#E8E8E8
                highlight RainbowDelimiterViolet guifg=#E2E2E2
            ]])
	end,
}
