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
			{ "<leader>f", group = "File/find", icon = {} },
			{ "<leader>h", group = "Harpoon", icon = {} },
			{ "<leader>b", group = "Buffer", icon = {} },
			{ "<leader>t", group = "Terminal", icon = {} },
			{ "<leader>s", group = "Split", icon = {} },
			{ "<leader>e", group = "Neo-tree", icon = {} },
			{ "<leader>l", group = "LSP", icon = {} },
			{ "<leader>u", group = "Snack", icon = {} },
			{ "<leader>g", group = "Git", icon = {} },
			{ "<leader>q", group = "Quarto", icon = {} },
			{ "<leader>o", group = "Outline", icon = {} },
			{ "<leader>c", group = "Code", icon = {} },
			{ "<leader>i", group = "Image", icon = {} },
			{ "<leader>x", group = "Diagnostics/quickfix", icon = { icon = "󱖫 ", color = "red" } },
			{ "<localleader>m", group = "Molten", icon = {} },
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
