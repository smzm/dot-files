return {

	-- Create log statements on the fly
	{
		"chrisgrieser/nvim-chainsaw",
		opts = {
			logStatements = {
				messageLog = {
					go = 'fmt.Println("%s")',
				},
				variableLog = {
					go = 'fmt.Println("%s %s:", %s)',
					nvim_lua = 'vim.notify("%s %s", vim.inspect(%s))',
				},
			},
		},
		-- stylua: ignore
		keys = {
			{ '<Leader>xv', function() require('chainsaw').variableLog() end, desc = 'Log variable' },
			{ '<Leader>xm', function() require('chainsaw').messageLog() end, desc = 'Log message' },
		},
	},
}
