return {
	"folke/which-key.nvim",
	dependencies = {
		"echasnovski/mini.icons",
	},
	event = "VeryLazy",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		preset = "modern",
		triggers = {
			{ "<leader>", mode = { "n" } },
			{ "<localleader>", mode = { "n" } },
			{ "<Ctrl>", mode = { "n" } },
		},
		delay = 900,
		spec = {
			{ "<leader>f", group = "File/find" },
			{ "<leader>h", group = "Harpoon" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>s", group = "Split" },
			{ "<leader>e", group = "Neo-tree" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>u", group = "Snack" },
			{ "<leader>g", group = "Git" },
			{ "<leader>a", group = "Avante" },
			{ "<leader>q", group = "Quarto" },
			{ "<leader>x", group = "Diagnostics/quickfix", icon = { icon = "󱖫 ", color = "red" } },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
