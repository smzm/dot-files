return {
	{ "sindrets/diffview.nvim" },
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
		},
	},
	{
		"akinsho/git-conflict.nvim",
		init = function()
			require("git-conflict").setup({
				default_mappings = false,
				disable_diagnostics = true,
			})
		end,
		keys = {
			{ "<leader>gco", ":GitConflictChooseOurs<cr>" },
			{ "<leader>gct", ":GitConflictChooseTheirs<cr>" },
			{ "<leader>gcb", ":GitConflictChooseBoth<cr>" },
			{ "<leader>gc0", ":GitConflictChooseNone<cr>" },
			{ "]x", ":GitConflictNextConflict<cr>" },
			{ "[x", ":GitConflictPrevConflict<cr>" },
		},
	},
}
