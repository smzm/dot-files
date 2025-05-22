return {
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> supermaven
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<TAB>",
					clear_suggestion = "<C-]>",
					accept_word = "<A-l>",
				},
				-- ignore_filetypes = { md = true },
				-- color = {
				-- 	suggestion_color = "#ffffff",
				-- 	cterm = 244,
				-- },
			})
		end,
	},
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> avante
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- set this if you want to always pull the latest change
		opts = {
			-- https://github.com/yetone/avante.nvim/wiki/Custom-providers#openai-compatible-providers
			provider = "openrouter",
			vendors = {
				openrouter = {
					__inherited_from = "openai",
					disable_tools = true,
					endpoint = "https://openrouter.ai/api/v1",
					api_key_name = "OPENROUTER_API_KEY",
					model = "qwen/qwen3-235b-a22b:free",
				},
				ollama = {
					__inherited_from = "openai",
					api_key_name = "",
					endpoint = "http://127.0.0.1:11434/v1",
					model = "codegemma",
				},
			},
			mappings = {
				ask = "<localleader>a",
				edit = "<localleader>e",
				refresh = "<localleader>ar", -- optional
			},
			-- hints = { enabled = false },
			behaviour = {
				auto_suggestions = false,
				-- auto_set_keymaps = false,
				auto_focus_sidebar = true,
				-- auto_suggestions_respect_ignore = false,
				-- auto_set_highlight_group = true,
				-- auto_apply_diff_after_generation = false,
				-- jump_result_buffer_on_finish = false,
				-- support_paste_from_clipboard = false,
				-- minimize_diff = true,
				-- enable_token_counting = true,
				-- enable_cursor_planning_mode = false,
				-- enable_claude_text_editor_tool_mode = false,
				-- use_cwd_as_project_root = false,
				-- auto_focus_on_diff_view = false,
			},
		},
		highlights = {
			---@type AvanteConflictHighlights
			diff = {
				current = "DiffText",
				incoming = "DiffAdd",
			},
		},
		config = function(_, opts)
			require("avante").setup(opts)

			-- Custom highlights here
			local hl = vim.api.nvim_set_hl
			hl(0, "AvanteSidebarWinHorizontalSeparator", { link = "Normal" })
			hl(0, "AvanteSidebarWinSeparator", { link = "Conceal" })

			-- ✅  Avante Highlights
			hl(0, "AvanteSidebarNormal", { link = "Normal" })

			hl(0, "AvanteTitle", { link = "H1" })
			hl(0, "AvanteReversedTitle", { link = "ReversedH1" })
			hl(0, "AvanteThirdTitle", { link = "H3" })
			hl(0, "AvanteReversedThirdTitle", { link = "ReversedH3" })
			hl(0, "AvanteSubtitle", { link = "H2" })
			hl(0, "AvanteReversedSubtitle", { link = "ReversedH2" })
			hl(0, "AvanteInlineHint", { link = "ReversedH3" })

			-- ✅ Avante Keybindings
			local map = vim.keymap.set
			local opts = { noremap = true, silent = true, desc = "Avante: " }

			map("n", "<localleader>aa", ":AvanteAsk<CR>", { desc = "Ask AI" })
			map("n", "<localleader>ab", ":AvanteBuild<CR>", { desc = "Build Dependencies" })
			map("n", "<localleader>ac", ":AvanteChat<CR>", { desc = "Start Chat Session" })
			map("n", "<localleader>an", ":AvanteChatNew<CR>", { desc = "New Chat Session" })
			map("n", "<localleader>ah", ":AvanteHistory<CR>", { desc = "Chat History" })
			map("n", "<localleader>al", ":AvanteClear<CR>", { desc = "Clear Chat" })
			map("n", "<localleader>af", ":AvanteFocus<CR>", { desc = "Toggle Focus Sidebar" })
			map("n", "<localleader>ar", ":AvanteRefresh<CR>", { desc = "Refresh Avante UI" })
			map("n", "<localleader>as", ":AvanteStop<CR>", { desc = "Stop AI Request" })
			map("n", "<localleader>av", ":AvanteSwitchProvider<CR>", { desc = "Switch AI Provider" })
			map("n", "<localleader>am", ":AvanteModels<CR>", { desc = "List Available Models" })
			map("n", "<localleader>aw", ":AvanteShowRepoMap<CR>", { desc = "Show Repo Map" })
			map("n", "<localleader><space>", ":AvanteToggle<CR>", { desc = "Toggle Avante Sidebar" })
			map("n", "<localleader>ap", ":AvanteSwitchSelectorProvider<CR>", { desc = "Switch Selector Provider" })
		end,

		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				--
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
			{
				"nvim-neo-tree/neo-tree.nvim",
				config = function()
					require("neo-tree").setup({
						filesystem = {
							commands = {
								avante_add_files = function(state)
									local node = state.tree:get_node()
									local filepath = node:get_id()
									local relative_path = require("avante.utils").relative_path(filepath)

									local sidebar = require("avante").get()

									local open = sidebar:is_open()
									-- ensure avante sidebar is open
									if not open then
										require("avante.api").ask()
										sidebar = require("avante").get()
									end

									sidebar.file_selector:add_selected_file(relative_path)

									-- remove neo tree buffer
									if not open then
										sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
									end
								end,
							},
							window = {
								mappings = {
									["oa"] = "avante_add_files",
								},
							},
						},
					})
				end,
			},
		},
	},

	-- ===================== MCP hub
	-- {
	-- 	"ravitemer/mcphub.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
	-- 	},
	-- 	-- uncomment the following line to load hub lazily
	-- 	--cmd = "MCPHub",  -- lazy load
	-- 	build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
	-- 	-- uncomment this if you don't want mcp-hub to be available globally or can't use -g
	-- 	-- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
	-- 	config = function()
	-- 		require("mcphub").setup()
	-- 	end,
	-- },

	-- ===================== Codeium ai : to run --> :Codeium Auth
	--     {
	-- 	"monkoose/neocodeium",
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		-- Change '<C-g>' here to any keycode you like.
	-- 		vim.keymap.set("i", "<C-e>", function()
	-- 			return vim.fn["codeium#Accept"]()
	-- 		end, { expr = true, silent = true })
	-- 		vim.keymap.set("i", "<c-n>", function()
	-- 			return vim.fn["codeium#CycleCompletions"](1)
	-- 		end, { expr = true, silent = true })
	-- 		vim.keymap.set("i", "<c-p>", function()
	-- 			return vim.fn["codeium#CycleCompletions"](-1)
	-- 		end, { expr = true, silent = true })
	-- 		vim.keymap.set("i", "<c-x>", function()
	-- 			return vim.fn["codeium#Clear"]()
	-- 		end, { expr = true, silent = true })
	-- 	end,
	-- }
}
