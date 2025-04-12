-- dir = "~/.config/nvim/lua/themes/neoshine", -- local path
return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Open Markdown Preview" },
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		opts = {},
		config = function()
			local neoshine = require("themes.neoshine.lua.neoshine")
			local colors = neoshine.colors

			vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#0f0f0f" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = colors.dimGray })
			vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = "#aeafaf" })

			require("render-markdown").setup({
				render_modes = true,
				heading = {
					border = false,
					background = {
						"RenderMarkdownH1Bg",
					},
					foreground = {
						"RenderMarkdownH1",
					},
				},
			})
		end,
	},
}
