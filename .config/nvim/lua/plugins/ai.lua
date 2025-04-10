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
			})
		end,
	},
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> avante
	-- failed to load avante_repo-map : https://github.com/yetone/avante.nvim/issues/612#issuecomment-2375729928
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- set this if you want to always pull the latest change
		opts = {
			-- https://github.com/yetone/avante.nvim/wiki/Custom-providers#openai-compatible-providers
			provider = "glhf",
			vendors = {
				glhf = {
					__inherited_from = "openai",
					api_key_name = "GLHF_API_KEY",
					endpoint = "https://glhf.chat/api/openai/v1",
					model = "hf:Qwen/Qwen2.5-Coder-32B-Instruct",
				},
				ollama = {
					__inherited_from = "openai",
					api_key_name = "",
					endpoint = "http://127.0.0.1:11434/v1",
					model = "codegemma",
				},
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
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
