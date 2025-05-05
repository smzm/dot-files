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
		"y3owk1n/time-machine.nvim",
		cmd = {
			"TimeMachineToggle",
			"TimeMachinePurgeBuffer",
			"TimeMachinePurgeAll",
			"TimeMachineLogShow",
			"TimeMachineLogClear",
		},
		---@type TimeMachine.Config
		opts = {},
		keys = {
			{
				"<leader>gt",
				"<cmd>TimeMachineToggle<cr>",
				desc = "[Time Machine] Toggle Tree",
			},
		},
	},
}
