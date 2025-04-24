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
			local monoshine = require("themes.monoshine.lua.monoshine")
			local colors = monoshine.colors

			vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#252525", fg = colors.fg })
			vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#454545", fg = colors.lightGray })
			vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = colors.midGrayDarker })
			vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#030303" })
			vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = colors.dimGrayDarker })

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

-- RenderMarkdownTableFill
-- RenderMarkdownTableRow
-- RenderMarkdownBullet
-- RenderMarkdownTableHead
-- RenderMarkdownCode
-- RenderMarkdownCodeInline
-- RenderMarkdownCodeFallback
-- RenderMarkdownChecked
-- RenderMarkdownUnchecked
-- RenderMarkdownH6Bg
-- RenderMarkdownLink
-- RenderMarkdownH3Bg
-- RenderMarkdownH2Bg
-- RenderMarkdownH1Bg
-- RenderMarkdownTodo
-- RenderMarkdownH6
-- RenderMarkdownDash
-- RenderMarkdownH4Bg
-- RenderMarkdownHint
-- RenderMarkdownWarn
-- RenderMarkdownInfo
-- RenderMarkdownH1
-- RenderMarkdownH2
-- RenderMarkdownH3
-- RenderMarkdownH4
-- RenderMarkdownH5
-- RenderMarkdownMath
-- RenderMarkdownWikiLink
-- RenderMarkdownCodeBorder
-- RenderMarkdownInlineHighlight
-- RenderMarkdownQuote
-- RenderMarkdownIndent
-- RenderMarkdownHtmlComment
-- RenderMarkdownSign
-- RenderMarkdownH5Bg
-- RenderMarkdownSuccess
-- RenderMarkdownError
