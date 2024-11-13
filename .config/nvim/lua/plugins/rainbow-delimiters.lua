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
				"RainbowDelimiterViolet",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterRed",
				"RainbowDelimiterGreen",
				"RainbowDelimiterCyan",
				"RainbowDelimiterYellow", -- Define highlight groups
			},
		}

		-- Define custom colors for each delimiter level
		vim.cmd([[
                highlight RainbowDelimiterRed guifg=#E06C75
                highlight RainbowDelimiterYellow guifg=#E5C07B
                highlight RainbowDelimiterBlue guifg=#61AFEF
                highlight RainbowDelimiterOrange guifg=#ffca85
                highlight RainbowDelimiterGreen guifg=#98C379
                highlight RainbowDelimiterViolet guifg=#f694ff
                highlight RainbowDelimiterCyan guifg=#56B6C2
            ]])
	end,
}
