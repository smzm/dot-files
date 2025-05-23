return {
	{
		"luckasRanarison/tailwind-tools.nvim",
		name = "tailwind-tools",
		build = ":UpdateRemotePlugins",
		opts = {}, -- your configuration
	},
	{
		"roobert/tailwindcss-colorizer-cmp.nvim",
		-- optionally, override the default options:
		config = function()
			require("tailwindcss-colorizer-cmp").setup({
				color_square_width = 2,
			})
		end,
	},
	-- {
	-- 	"razak17/tailwind-fold.nvim",
	-- 	opts = {},
	-- 	dependencies = { "nvim-treesitter/nvim-treesitter" },
	-- 	ft = { "html", "svelte", "astro", "vue", "typescriptreact", "php", "blade" },
	-- },
}
