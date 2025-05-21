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
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
