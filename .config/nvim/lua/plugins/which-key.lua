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
			{ "<leader>f", group = "file/find" },
			{ "<leader>h", group = "harpoon", icon={icon = "H"} },
			{ "<leader>b", group = "buffer" },
			{ "<leader>t", group = "terminal" },
			{ "<leader>s", group = "split" },
			{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "red" } }
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
