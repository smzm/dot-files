return {
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> supermaven
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<M-l>",
					clear_suggestion = "<C-]>",
					accept_word = "<C-l>",
				},
				-- ignore_filetypes = { md = true },
				-- color = {
				-- 	suggestion_color = "#ffffff",
				-- 	cterm = 244,
				-- },
			})
		end,
	},

	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> opencode
	{
		"NickvanDyke/opencode.nvim",
		-- @buffer 	     Current buffer
		-- @buffers 	 Open buffers
		-- @cursor 	     Cursor position
		-- @selection 	 Selected text
		-- @visible 	 Visible text
		-- @diagnostic 	 Current line diagnostics
		-- @diagnostics  Current buffer diagnostics
		-- @quickfix     Qickfix list
		-- @diff     	 Git diff
		dependencies = { { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } } },
		config = function()
			vim.g.opencode_opts = {
				provider = {
					enabled = "terminal",
					terminal = {
						width = math.floor(vim.o.columns * 0.45),
					},
					snacks = {
						auto_insert = true,
						auto_close = true,
						win = {
							position = "float",
							enter = true,
						},
					},
					-- env = {
					-- 	OPENCODE_THEME = "system",
					-- },
				},
			}
		end,
		keys = {
			{
				"<leader><leader>",
				function()
					require("opencode").toggle()
				end,
				desc = "Toggle embedded opencode",
				mode = { "n", "t" },
			},
			{
				"<localleader><localleader>",
				function()
					require("opencode").ask()
				end,
				desc = "Ask opencode",
				mode = "n",
			},
			{
				"<localleader><localleader>",
				function()
					require("opencode").ask("@selection: ")
				end,
				desc = "Ask opencode about selection",
				mode = "v",
			},
			{
				"<localleader>op",
				function()
					require("opencode").select_prompt()
				end,
				desc = "Select prompt",
				mode = { "n", "v" },
			},
			{
				"<localleader>on",
				function()
					require("opencode").command("session_new")
				end,
				desc = "New session",
			},
			{
				"<localleader>oy",
				function()
					require("opencode").command("messages_copy")
				end,
				desc = "Copy last message",
			},
			{
				"<C-PageDown>",
				function()
					require("opencode").command("messages_half_page_down")
				end,
				desc = "Scroll messages down",
			},
			{
				"<C-PageUp>",
				function()
					require("opencode").command("messages_half_page_up")
				end,
				desc = "Scroll messages up",
			},
		},
	},
}
