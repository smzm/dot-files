return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-tree/nvim-web-devicons",
			"folke/todo-comments.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local transform_mod = require("telescope.actions.mt").transform_mod

			local trouble = require("trouble")
			local trouble_telescope = require("trouble.sources.telescope")

			-- or create your custom action
			local custom_actions = transform_mod({
				open_trouble_qflist = function(prompt_bufnr)
					trouble.toggle("quickfix")
				end,
			})

			telescope.setup({
				defaults = {
					prompt_prefix = "   ",
					path_display = { "smart" },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous, -- move to prev result
							["<C-j>"] = actions.move_selection_next, -- move to next result
							["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
							["<C-t>"] = trouble_telescope.open,
						},
						n = { ["q"] = require("telescope.actions").close },
					},
				},
			})

			telescope.load_extension("fzf")

			-- set keymaps
			local keymap = vim.keymap -- for conciseness

			keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
			keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
			keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
			keymap.set(
				"n",
				"<leader>fc",
				"<cmd>Telescope grep_string<cr>",
				{ desc = "Find string under cursor in cwd" }
			)
			keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		end,
	},
	-- ========================= Trouble ==========================
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
		opts = {
			focus = true,
		},
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
				desc = "Open trouble document diagnostics",
			},
			{ "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Open trouble location list" },
			{ "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Open todos in trouble" },
		},
	},
	-- =================== Goto ====================
	{
		"rmagatti/goto-preview",
		config = function()
			require("goto-preview").setup({
				width = 120, -- Width of the floating window
				height = 15, -- Height of the floating window
				border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" }, -- Border characters of the floating window
				default_mappings = true,
				debug = false, -- Print debug information
				opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
				resizing_mappings = false, -- Binds arrow keys to resizing the floating window.
				post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
				references = { -- Configure the telescope UI for slowing the references cycling window.
					telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
				},
				-- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
				focus_on_open = true, -- Focus the floating window when opening it.
				dismiss_on_move = false, -- Dismiss the floating window when moving the cursor.
				force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
				bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
				stack_floating_preview_windows = true, -- Whether to nest floating windows
				preview_window_title = { enable = true, position = "left" }, -- Whether
			})
		end,
	},
	-- =================== Harpoon ====================
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local harpoon = require("harpoon")

			-- REQUIRED
			harpoon:setup()

			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = "Add to harpoon" })

			vim.keymap.set("n", "<leader>hh", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Toogle harpoon menu" })

			vim.keymap.set("n", "<leader>h1", function()
				harpoon:list():select(1)
			end, { desc = "Go to harpoon 1" })
			vim.keymap.set("n", "<leader>h2", function()
				harpoon:list():select(2)
			end, { desc = "Go to harpoon 2" })
			vim.keymap.set("n", "<leader>h3", function()
				harpoon:list():select(3)
			end, { desc = "Go to harpoon 3" })
			vim.keymap.set("n", "<leader>h4", function()
				harpoon:list():select(4)
			end, { desc = "Go to harpoon 4" })

			-- Toggle previous & next buffers stored within Harpoon list
			vim.keymap.set("n", "<C-S-P>", function()
				harpoon:list():prev()
			end)
			vim.keymap.set("n", "<C-S-N>", function()
				harpoon:list():next()
			end)

			-- basic telescope configuration
			local conf = require("telescope.config").values
			local function toggle_telescope(harpoon_files)
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end

				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({
							results = file_paths,
						}),
						previewer = conf.file_previewer({}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end

			vim.keymap.set("n", "<C-e>", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Open harpoon window" })
		end,
	},
}
