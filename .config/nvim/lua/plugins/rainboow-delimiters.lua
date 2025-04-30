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
		vim.api.nvim_set_hl(0, "RainbowDelimiterGray", { link = "Delimiter" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { link = "Delimiter" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { link = "Delimiter" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { link = "Delimiter" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { link = "Delimiter" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { link = "Delimiter" })
		vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { link = "Delimiter" })
	end,
}
