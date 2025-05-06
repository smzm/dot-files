return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		highlight = {
			-- show a backdrop with hl FlashBackdrop
			backdrop = true,
			-- Highlight the search matches
			matches = true,
			-- extmark priority
			priority = 5000,
			groups = {
				match = "SpecialKey",
				current = "SpecialKey",
				backdrop = "FlashBackdrop",
				label = "IncSearch",
			},
		},
	},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  },
}
