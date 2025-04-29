return {
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> supermaven
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<Tab>",
					clear_suggestion = "<C-]>",
					accept_word = "<A-l>",
				},
				condition = function()
					local ft = vim.bo.filetype
					local filename = vim.fn.expand("%:t")
					return ft == "markdown" or filename == ".env"
				end,
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
			behaviour = {
				auto_suggestions = false,
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

			local monoshine = require("themes.monoshine.lua.monoshine")
			local colors = monoshine.colors

			-- Custom highlights here
			local hl = vim.api.nvim_set_hl
			hl(0, "AvanteSidebarWinHorizontalSeparator", { fg = colors.midGrayDarker, bg = colors.bg })
			-- hl(0, "AvanteSidebarWinSeparator", { fg = colors.midGrayDarker, bg = colors.bg })

			-- ✅  Avante Highlights
			hl(0, "AvantePromptBorder", { fg = "#444444", bg = "#1a1a1a" })
			hl(0, "AvantePopup", { fg = "#cccccc", bg = "#101010" })
			hl(0, "AvanteTitle", { fg = colors.bg, bg = colors.fg })
			hl(0, "AvanteReversedTitle", { fg = colors.fg, bg = colors.bg })
			hl(0, "AvanteThirdTitle", { fg = colors.bg, bg = colors.gray })
			hl(0, "AvanteReversedThirdTitle", { fg = colors.gray, bg = colors.bg })
			hl(0, "AvanteSubtitle", { fg = colors.bg, bg = colors.midGrayDarker })
			hl(0, "AvanteReversedSubtitle", { fg = colors.midGrayDarker, bg = colors.bg })

			-- ✅ Avante Keybindings
			local map = vim.keymap.set
			local opts = { noremap = true, silent = true, desc = "Avante: " }

			map("n", "<localleader>a", ":AvanteAsk<Space>", { desc = "Ask AI" })
			map("n", "<localleader>b", ":AvanteBuild<CR>", { desc = "Build Dependencies" })
			map("n", "<localleader>c", ":AvanteChat<CR>", { desc = "Start Chat Session" })
			map("n", "<localleader>n", ":AvanteChatNew<CR>", { desc = "New Chat Session" })
			map("n", "<localleader>h", ":AvanteHistory<CR>", { desc = "Chat History" })
			map("n", "<localleader>l", ":AvanteClear<CR>", { desc = "Clear Chat" })
			map("v", "<localleader>e", ":AvanteEdit<CR>", { desc = "Edit Selected Code" }) -- visual mode
			map("n", "<localleader>f", ":AvanteFocus<CR>", { desc = "Toggle Focus Sidebar" })
			map("n", "<localleader>r", ":AvanteRefresh<CR>", { desc = "Refresh Avante UI" })
			map("n", "<localleader>s", ":AvanteStop<CR>", { desc = "Stop AI Request" })
			map("n", "<localleader>v", ":AvanteSwitchProvider<CR>", { desc = "Switch AI Provider" })
			map("n", "<localleader>m", ":AvanteModels<CR>", { desc = "List Available Models" })
			map("n", "<localleader>w", ":AvanteShowRepoMap<CR>", { desc = "Show Repo Map" })
			map("n", "<localleader>\\", ":AvanteToggle<CR>", { desc = "Toggle Sidebar" })
			map("n", "<localleader>p", ":AvanteSwitchSelectorProvider<CR>", { desc = "Switch Selector Provider" })
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
