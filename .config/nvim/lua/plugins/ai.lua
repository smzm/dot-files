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

	-- -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> code companion
	{
		"olimorris/codecompanion.nvim",
		opts = {},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/mcphub.nvim",
		},
		config = function()
			local default_model = "google/gemini-2.0-flash-001"
			local available_models = {
				"qwen/qwen3-coder:free",
				"google/gemini-2.0-flash-001",
				"google/gemini-2.5-pro-preview-03-25",
				"anthropic/claude-3.7-sonnet",
				"anthropic/claude-3.5-sonnet",
				"openai/gpt-4o-mini",
			}
			local current_model = default_model

			local function select_model()
				vim.ui.select(available_models, {
					prompt = "Select  Model:",
				}, function(choice)
					if choice then
						current_model = choice
						vim.notify("Selected model: " .. current_model)
					end
				end)
			end

			require("codecompanion").setup({
				adapters = {
					openrouter = function()
						return require("codecompanion.adapters").extend("openai_compatible", {
							env = {
								url = "https://openrouter.ai/api",
								api_key = "OPENROUTER_API_KEY",
								chat_url = "/v1/chat/completions",
							},
							schema = {
								model = {
									default = current_model,
								},
							},
						})
					end,
				},
				strategies = {
					-- By default, adapters will look in your environment for a *_API_KEY where * is the name of the adapter
					chat = {
						tools = {
							opts = {
								-- When a tool executes  it can be useful to automatically send its output back to the LLM
								auto_submit_errors = true, -- Send any errors to the LLM automatically?
								auto_submit_success = true, -- Send any successful output to the LLM automatically?
							},
						},
						adapter = {
							name = "gemini",
							model = "gemini-2.5-flash-preview-04-17",
						},
					},
					inline = {
						adapter = "gemini",
						layout = "vertical", -- vertical|horizontal|buffer
						keymaps = {
							accept_change = {
								modes = { n = "ga" },
								description = "Accept the suggested change",
							},
							rejectjchange = {
								modes = { n = "gr" },
								description = "Reject the suggested change",
							},
						},
					},
					cmd = {
						adapter = "gemini",
					},
				},
				extensions = {
					mcphub = {
						callback = "mcphub.extensions.codecompanion",
						opts = {
							make_vars = true,
							make_slash_commands = true,
							show_result_in_chat = true,
						},
					},
				},
			})

			vim.keymap.set(
				{ "n", "v" },
				"<localleader><leader>",
				"<cmd>CodeCompanion<cr>",
				{ noremap = true, silent = true }
			)

			vim.keymap.set(
				{ "n", "v" },
				"<localleader>c",
				"<cmd>CodeCompanionActions<cr>",
				{ noremap = true, silent = true }
			)

			vim.keymap.set(
				{ "n" },
				"<LocalLeader>a",
				"<cmd>CodeCompanionChat Toggle<cr>",
				{ noremap = true, silent = true }
			)

			vim.keymap.set("v", "<localleader>a", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

			vim.keymap.set("n", "<localleader>m", select_model, { desc = "Select Gemini Model" })

			-- Expand 'cc' into 'CodeCompanion' in the command line
			vim.cmd([[cab cc CodeCompanion]])
		end,
	},

	-- -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> avante
	-- {
	-- 	"yetone/avante.nvim",
	-- 	event = "VeryLazy",
	-- 	lazy = false,
	-- 	version = false, -- set this if you want to always pull the latest change
	-- 	opts = {
	-- 		-- https://github.com/yetone/avante.nvim/wiki/Custom-providers#openai-compatible-providers
	-- 		provider = "gemini",
	-- 		providers = {
	-- 			openrouter = {
	-- 				__inherited_from = "openai",
	-- 				disable_tools = true,
	-- 				endpoint = "https://openrouter.ai/api/v1",
	-- 				api_key_name = "OPENROUTER_API_KEY",
	-- 				model = "deepseek/deepseek-r1-0528-qwen3-8b:free",
	-- 			},
	-- 		},
	-- 		mappings = {
	-- 			ask = "<localleader>a",
	-- 			edit = "<localleader>e",
	-- 			refresh = "<localleader>ar", -- optional
	-- 		},
	-- 		-- hints = { enabled = false },
	-- 		behaviour = {
	-- 			auto_suggestions = false,
	-- 			-- auto_set_keymaps = false,
	-- 			auto_focus_sidebar = true,
	-- 			-- auto_suggestions_respect_ignore = false,
	-- 			-- auto_set_highlight_group = true,
	-- 			-- auto_apply_diff_after_generation = false,
	-- 			-- jump_result_buffer_on_finish = false,
	-- 			-- support_paste_from_clipboard = false,
	-- 			-- minimize_diff = true,
	-- 			-- enable_token_counting = true,
	-- 			-- enable_cursor_planning_mode = false,
	-- 			-- enable_claude_text_editor_tool_mode = false,
	-- 			-- use_cwd_as_project_root = false,
	-- 			-- auto_focus_on_diff_view = false,
	-- 		},
	-- 	},
	-- 	highlights = {
	-- 		---@type AvanteConflictHighlights
	-- 		diff = {
	-- 			current = "DiffText",
	-- 			incoming = "DiffAdd",
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("avante").setup(opts)
	--
	-- 		-- Custom highlights here
	-- 		local hl = vim.api.nvim_set_hl
	-- 		hl(0, "AvanteSidebarWinHorizontalSeparator", { link = "Normal" })
	-- 		hl(0, "AvanteSidebarWinSeparator", { link = "Conceal" })
	--
	-- 		-- ✅  Avante Highlights
	-- 		hl(0, "AvanteSidebarNormal", { link = "Normal" })
	--
	-- 		hl(0, "AvanteTitle", { link = "H1" })
	-- 		hl(0, "AvanteReversedTitle", { link = "ReversedH1" })
	-- 		hl(0, "AvanteThirdTitle", { link = "H3" })
	-- 		hl(0, "AvanteReversedThirdTitle", { link = "ReversedH3" })
	-- 		hl(0, "AvanteSubtitle", { link = "H2" })
	-- 		hl(0, "AvanteReversedSubtitle", { link = "ReversedH2" })
	-- 		hl(0, "AvanteInlineHint", { link = "ReversedH3" })
	--
	-- 		-- ✅ Avante Keybindings
	-- 		local map = vim.keymap.set
	-- 		local opts = { noremap = true, silent = true, desc = "Avante: " }
	--
	-- 		map("n", "<localleader>aa", ":AvanteAsk<CR>", { desc = "Ask AI" })
	-- 		map("n", "<localleader>ab", ":AvanteBuild<CR>", { desc = "Build Dependencies" })
	-- 		map("n", "<localleader>ac", ":AvanteChat<CR>", { desc = "Start Chat Session" })
	-- 		map("n", "<localleader>an", ":AvanteChatNew<CR>", { desc = "New Chat Session" })
	-- 		map("n", "<localleader>ah", ":AvanteHistory<CR>", { desc = "Chat History" })
	-- 		map("n", "<localleader>al", ":AvanteClear<CR>", { desc = "Clear Chat" })
	-- 		map("n", "<localleader>af", ":AvanteFocus<CR>", { desc = "Toggle Focus Sidebar" })
	-- 		map("n", "<localleader>ar", ":AvanteRefresh<CR>", { desc = "Refresh Avante UI" })
	-- 		map("n", "<localleader>as", ":AvanteStop<CR>", { desc = "Stop AI Request" })
	-- 		map("n", "<localleader>av", ":AvanteSwitchProvider<CR>", { desc = "Switch AI Provider" })
	-- 		map("n", "<localleader>am", ":AvanteModels<CR>", { desc = "List Available Models" })
	-- 		map("n", "<localleader>aw", ":AvanteShowRepoMap<CR>", { desc = "Show Repo Map" })
	-- 		map("n", "<localleader><space>", ":AvanteToggle<CR>", { desc = "Toggle Avante Sidebar" })
	-- 		map("n", "<localleader>ap", ":AvanteSwitchSelectorProvider<CR>", { desc = "Switch Selector Provider" })
	-- 	end,
	--
	-- 	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	-- 	build = "make",
	-- 	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	-- 	dependencies = {
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 		"stevearc/dressing.nvim",
	-- 		"nvim-lua/plenary.nvim",
	-- 		"MunifTanjim/nui.nvim",
	-- 		--- The below dependencies are optional,
	-- 		"echasnovski/mini.pick", -- for file_selector provider mini.pick
	-- 		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
	-- 		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
	-- 		"ibhagwan/fzf-lua", -- for file_selector provider fzf
	-- 		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
	-- 		"zbirenbaum/copilot.lua", -- for providers='copilot'
	-- 		{
	-- 			-- support for image pasting
	-- 			"HakonHarnes/img-clip.nvim",
	-- 			event = "VeryLazy",
	-- 			opts = {
	-- 				-- recommended settings
	-- 				default = {
	-- 					embed_image_as_base64 = false,
	-- 					prompt_for_file_name = false,
	-- 					drag_and_drop = {
	-- 						insert_mode = true,
	-- 					},
	-- 					-- required for Windows users
	-- 					use_absolute_path = true,
	-- 				},
	-- 			},
	-- 		},
	-- 		{
	-- 			-- Make sure to set this up properly if you have lazy=true
	-- 			--
	-- 			"MeanderingProgrammer/render-markdown.nvim",
	-- 			opts = {
	-- 				file_types = { "markdown", "Avante" },
	-- 			},
	-- 			ft = { "markdown", "Avante" },
	-- 		},
	-- 		{
	-- 			"nvim-neo-tree/neo-tree.nvim",
	-- 			config = function()
	-- 				require("neo-tree").setup({
	-- 					filesystem = {
	-- 						commands = {
	-- 							avante_add_files = function(state)
	-- 								local node = state.tree:get_node()
	-- 								local filepath = node:get_id()
	-- 								local relative_path = require("avante.utils").relative_path(filepath)
	--
	-- 								local sidebar = require("avante").get()
	--
	-- 								local open = sidebar:is_open()
	-- 								-- ensure avante sidebar is open
	-- 								if not open then
	-- 									require("avante.api").ask()
	-- 									sidebar = require("avante").get()
	-- 								end
	--
	-- 								sidebar.file_selector:add_selected_file(relative_path)
	--
	-- 								-- remove neo tree buffer
	-- 								if not open then
	-- 									sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
	-- 								end
	-- 							end,
	-- 						},
	-- 						window = {
	-- 							mappings = {
	-- 								["oa"] = "avante_add_files",
	-- 							},
	-- 						},
	-- 					},
	-- 				})
	-- 			end,
	-- 		},
	-- 	},
	-- },
}
