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
			local builtin = require("telescope.builtin") -- Ensure this is required

			local trouble = require("trouble")
			local trouble_telescope = require("trouble.sources.telescope")

			local custom_actions = transform_mod({
				open_trouble_qflist = function(prompt_bufnr)
					trouble.toggle("quickfix")
				end,
			})

			telescope.setup({
				defaults = {
					prompt_prefix = "   ",
					path_display = { "smart" },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
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

			-- Your new function and keymap:
			local find_and_search_in_docs_subdir = function()
				-- IMPORTANT: Customize this path to your main documents directory
				-- >>>>>>>>>>>>>>  🧰 YOUR DOCS PATH HERE 🧰 <<<<<<<<<<<<<<<<<<<<<<<<
				local base_docs_path = "~/docs" -- Your specific path
				local base_docs_name = vim.fn.fnamemodify(base_docs_path, ":t") -- Gets the trailing name, e.g., "docs"

				vim.ui.input({
					prompt = "Dir under " .. base_docs_name .. "/ (empty for all " .. base_docs_name .. "): ",
					completion = "none", -- Disable autocompletion
				}, function(dir_name)
					if dir_name == nil then -- User cancelled (e.g., Esc)
						vim.notify("Search cancelled.", vim.log.levels.INFO)
						return
					end

					-- Trim whitespace from beginning and end of input
					dir_name = vim.trim(dir_name)

					-- Check if input ends with '/' (directory with auto README.md)
					if dir_name:match("/$") then
						-- User provided a directory path ending with '/' like "pandas/"
						-- Remove the trailing slash for directory search
						local clean_dir = dir_name:sub(1, -2)
						local readme_path = clean_dir .. "/README.md"

						local potential_readme_paths = vim.fn.globpath(base_docs_path, "**/" .. readme_path, true, true)

						if not potential_readme_paths or #potential_readme_paths == 0 then
							vim.notify(
								"No README.md found in '" .. clean_dir .. "' under " .. base_docs_path,
								vim.log.levels.WARN
							)
							return
						end

						local target_readme_files = {}
						for _, path_str in ipairs(potential_readme_paths) do
							if path_str ~= "" and vim.fn.filereadable(path_str) == 1 then
								table.insert(target_readme_files, path_str)
							end
						end

						if #target_readme_files == 0 then
							vim.notify(
								"No readable README.md found in '" .. clean_dir .. "' under " .. base_docs_path,
								vim.log.levels.WARN
							)
							return
						elseif #target_readme_files == 1 then
							-- Open the single matching README.md
							vim.cmd("edit " .. vim.fn.fnameescape(target_readme_files[1]))
							vim.notify("Opened: " .. target_readme_files[1], vim.log.levels.INFO)
							return
						else
							-- Multiple README.md files found, let user choose
							vim.notify(
								"Multiple README.md files found in '" .. clean_dir .. "'. Choose one:",
								vim.log.levels.INFO
							)
							builtin.find_files({
								prompt_title = "Choose README.md in: " .. clean_dir,
								search_dirs = { base_docs_path },
								default_text = "README.md",
							})
							return
						end
					-- Check if input contains a file path (has '/' and ends with an extension)
					elseif dir_name:match("/") and dir_name:match("%.[%w]+$") then
						-- User provided a file path like "pandas/README.md"
						local potential_file_paths = vim.fn.globpath(base_docs_path, "**/" .. dir_name, true, true)

						if not potential_file_paths or #potential_file_paths == 0 then
							vim.notify(
								"No file '" .. dir_name .. "' found under " .. base_docs_path,
								vim.log.levels.WARN
							)
							return
						end

						local target_files = {}
						for _, path_str in ipairs(potential_file_paths) do
							if path_str ~= "" and vim.fn.filereadable(path_str) == 1 then
								table.insert(target_files, path_str)
							end
						end

						if #target_files == 0 then
							vim.notify(
								"No readable file '" .. dir_name .. "' found under " .. base_docs_path,
								vim.log.levels.WARN
							)
							return
						elseif #target_files == 1 then
							-- Open the single matching file
							vim.cmd("edit " .. vim.fn.fnameescape(target_files[1]))
							vim.notify("Opened: " .. target_files[1], vim.log.levels.INFO)
							return
						else
							-- Multiple files found, let user choose
							vim.notify(
								"Multiple files matching '" .. dir_name .. "' found. Choose one:",
								vim.log.levels.INFO
							)
							builtin.find_files({
								prompt_title = "Choose file: " .. dir_name,
								search_dirs = { base_docs_path },
								default_text = vim.fn.fnamemodify(dir_name, ":t"), -- Just the filename for search
							})
							return
						end
					end

					local search_dirs_for_grep
					local title_component

					if dir_name == "" then
						-- User submitted empty input: search in the entire base_docs_path
						search_dirs_for_grep = { base_docs_path }
						title_component = "all " .. base_docs_name
						vim.notify("Searching in all of " .. base_docs_path, vim.log.levels.INFO)
					else
						-- User provided a directory name: find that specific subdirectory
						local potential_paths_list = vim.fn.globpath(base_docs_path, "**/" .. dir_name, true, true)

						if not potential_paths_list or #potential_paths_list == 0 then
							vim.notify(
								"No item named '" .. dir_name .. "' found under " .. base_docs_path,
								vim.log.levels.WARN
							)
							return
						end

						local target_sub_dirs = {}
						for _, path_str in ipairs(potential_paths_list) do
							if path_str ~= "" and vim.fn.isdirectory(path_str) == 1 then
								table.insert(target_sub_dirs, path_str)
							end
						end

						if #target_sub_dirs == 0 then
							vim.notify(
								"No directory named '" .. dir_name .. "' found under " .. base_docs_path,
								vim.log.levels.WARN
							)
							return
						end

						search_dirs_for_grep = target_sub_dirs
						if #target_sub_dirs == 1 then
							title_component = vim.fn.fnamemodify(target_sub_dirs[1], ":t") -- Actual name of the single dir
						else
							title_component = dir_name -- Use the input name if multiple dirs match
							vim.notify(
								"Multiple directories matching '" .. dir_name .. "' found. Searching in all of them.",
								vim.log.levels.INFO
							)
						end
					end

					-- Launch Telescope live_grep with the determined search directories and title
					builtin.live_grep({
						prompt_title = "Grep in " .. title_component .. " (under " .. base_docs_name .. ")",
						search_dirs = search_dirs_for_grep,
					})
				end)
			end

			keymap.set(
				"n",
				"<leader>fd",
				find_and_search_in_docs_subdir,
				{ desc = "✋ Find text in specific 'DOCS' sub-directory" }
			)
		end, -- This is the end of the config = function()
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
