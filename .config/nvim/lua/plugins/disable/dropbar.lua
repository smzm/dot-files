return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPost", "BufNewFile" },
	-- optional, but required for fuzzy finder support
	dependencies = {
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
	},
	config = function()
		local map = vim.api.nvim_set_keymap
		local opts = { noremap = true, silent = true }

		-- Toggle Dropbar
		map("n", "<leader>dt", ":lua require('dropbar').toggle()<CR>", opts)

		-- Navigate Dropbar items
		map("n", "<leader>dn", ":lua require('dropbar').next_item()<CR>", opts)
		map("n", "<leader>dp", ":lua require('dropbar').prev_item()<CR>", opts)
	end,
}
