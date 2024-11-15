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
			{ "<Ctrl>", mode = { "n" } },
		},
		delay = 900,
		spec = {
			{ "<leader>f", group = "File/find" },
			{ "<leader>h", group = "Harpoon", icon = { icon = "H" } },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>s", group = "Split" },
			{ "<leader>e", group = "Nvim-tree" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>u", group = "Snack" },
			{ "<leader>g", group = "Git" },
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
