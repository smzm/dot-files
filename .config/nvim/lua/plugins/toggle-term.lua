return {
	"akinsho/toggleterm.nvim",
	lazy = false,
	keys = {
		{ "<leader>t1", "<cmd>1ToggleTerm<CR>", desc = "Toggle terminal #1" },
		{ "<leader>t2", "<cmd>2ToggleTerm<CR>", desc = "Toggle terminal #2" },
		{ "<leader>t3", "<cmd>3ToggleTerm<CR>", desc = "Toggle terminal #3" },
		{ "<leader>t4", "<cmd>4ToggleTerm<CR>", desc = "Toggle terminal #4" },
		{
			"<leader>gg",
			function()
				_LAZYGIT_TOGGLE()
			end,
			desc = "Toggle lazygit",
		},
	},
	opts = {
		size = 20,
		open_mapping = [[\\]],
		hide_numbers = true,
		shade_filetypes = {},
		shade_terminals = true,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = false,
		persist_size = true,
		direction = "float",
		close_on_exit = true,
		shell = vim.o.shell,
		float_opts = {
			border = "curved",
			winblend = 0,
			highlights = {
				border = "Normal",
				background = "Normal",
			},
		},
	},
	config = function(_, opts)
		local toggleterm = require("toggleterm")

		toggleterm.setup(opts)

		function _G.set_terminal_keymaps()
			local keymap_opts = { noremap = true }
			vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], keymap_opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], keymap_opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], keymap_opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], keymap_opts)
		end

		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

		local Terminal = require("toggleterm.terminal").Terminal
		local lazygit = Terminal:new({
			cmd = "lazygit",
			hidden = true,
			direction = "float",
			float_opts = {
				border = "none",
				width = 100000,
				height = 100000,
			},
			on_open = function(_)
				vim.cmd("startinsert!")
				-- vim.cmd "set laststatus=0"
			end,
			on_close = function(_)
				-- vim.cmd "set laststatus=3"
			end,
			count = 99,
		})

		function _LAZYGIT_TOGGLE()
			lazygit:toggle()
		end
	end,
}
