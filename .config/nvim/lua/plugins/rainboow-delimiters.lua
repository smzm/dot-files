-- --  Rainbow delimiters for Neovim with Tree-sitter
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
				"RainbowDelimiterGray",
				"RainbowDelimiterCyan",
				"RainbowDelimiterRed",
				"RainbowDelimiterYellow",
				"RainbowDelimiterBlue",
				"RainbowDelimiterGreen",
				"RainbowDelimiterViolet",
			},
		}

		-- Define custom colors for each delimiter level
		vim.api.nvim_set_hl(0, "RainbowDelimiterGray", { link = "NvimParenthesis_1" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { link = "NvimParenthesis_2" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { link = "NvimParenthesis_3" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { link = "NvimParenthesis_4" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { link = "NvimParenthesis_5" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { link = "NvimParenthesis_6" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { link = "NvimParenthesis_7" })
	end,
}
