return {
	{

		"rust-lang/rust.vim",
		ft = "rust",
		init = function()
			vim.g.rustfmt_autosave = 1
		end,
	},
	{
		"saecki/crates.nvim",
		ft = { "rust", "toml" },
		config = function(_, opts)
			local crates = require("crates")
			crates.setup(opts)
			crates.show()
		end,
	},
	{
		"simrat39/rust-tools.nvim",
		ft = "rust",
		dependencies = "neovim/nvim-lspconfig",
		config = function()
			local rt = require("rust-tools")
			rt.setup({
				server = {
					on_attach = function(_, bufnr)
						-- Hover actions
						-- vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
						-- Code action groups
						-- vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
					end,
				},
			})
		end,
	},
}
