return {
	"akinsho/bufferline.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	version = "*",
	event = "UIEnter",
	keys = {
		{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
		{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
		{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
		{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
		{ "<S-l>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<S-h>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "<leader><", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
		{ "<leader>>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
	},
	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				diagnostics = "nvim_lsp",
			},
		})

		-- Link highlights to Normal
		vim.api.nvim_set_hl(0, "BufferLineFill", { link = "Normal" })
	end,
}
