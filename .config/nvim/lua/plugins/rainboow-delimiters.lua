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
                highlight RainbowDelimiterGray guifg=#69737c
                highlight RainbowDelimiterCyan guifg=#7fc6c5
                highlight RainbowDelimiterRed guifg=#CF9797
                highlight RainbowDelimiterYellow guifg=#CDC184
                highlight RainbowDelimiterBlue guifg=#bbdef0
                highlight RainbowDelimiterGreen guifg=#75C3A4
                highlight RainbowDelimiterViolet guifg=#D160A0
            ]])
	end,
}
