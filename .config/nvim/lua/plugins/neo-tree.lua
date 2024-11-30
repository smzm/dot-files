-- Plugin: Neo-tree

local winwidth = 30

local function toggle_width()
	local max = winwidth * 2
	local cur_width = vim.fn.winwidth(0)
	local half = math.floor((winwidth + (max - winwidth) / 2) + 0.4)
	local new_width = winwidth
	if cur_width == winwidth then
		new_width = half
	elseif cur_width == half then
		new_width = max
	else
		new_width = winwidth
	end
	vim.cmd(new_width .. " wincmd |")
end

local function get_current_directory(state)
	local node = state.tree:get_node()
	if node.type ~= "directory" or not node:is_expanded() then
		node = state.tree:get_node(node:get_parent_id())
	end
	return node.path
end

return {

	-----------------------------------------------------------------------------
	-- File explorer written in Lua
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"MunifTanjim/nui.nvim",
		{
			"s1n7ax/nvim-window-picker",
			lazy = true,
			opts = {
				filter_rules = {
					-- filter using buffer options
					bo = {
						-- if the file type is one of following, the window will be ignored
						filetype = {
							"neo-tree",
							"neo-tree-popup",
							"notify",
							"packer",
							"qf",
							"diff",
							"fugitive",
							"fugitiveblame",
						},

						-- if the buffer type is one of following, the window will be ignored
						buftype = { "nofile", "help", "terminal" },
					},
				},
			},
		},
	},
	cmd = "Neotree",
	-- stylua: ignore
	keys = {
		{
			'<leader>ee',
			function()
                vim.cmd("Neotree left toggle reveal")
			end,
			desc = 'Explorer NeoTree (cwd)',
		},
        {
				"<ef>",
				function()
					vim.cmd("Neotree float toggle reveal")
				end,
				desc = "Explorer",
			},
		{
			'<LocalLeader>a',
			function()
				require('neo-tree.command').execute({
					reveal = true,
					dir = LazyVim.root()
				})
			end,
			desc = 'Explorer NeoTree Reveal',
		},
		{
			'<leader>eg',
			function()
				require('neo-tree.command').execute({ source = 'git_status', toggle = true })
			end,
			desc = 'Git Explorer',
		},
		{
			'<leader>eb',
			function()
				require('neo-tree.command').execute({ source = 'buffers', toggle = true })
			end,
			desc = 'Buffer Explorer',
		},
	},
	deactivate = function()
		vim.cmd([[Neotree close]])
	end,
	init = function()
		-- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
		-- because `cwd` is not set up properly.
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
			desc = "Start Neo-tree with directory",
			once = true,
			callback = function()
				if package.loaded["neo-tree"] then
					return
				else
					---@diagnostic disable-next-line: param-type-mismatch
					local stats = vim.uv.fs_stat(vim.fn.argv(0))
					if stats and stats.type == "directory" then
						require("neo-tree")
					end
				end
			end,
		})
	end,
	-- See: https://github.com/nvim-neo-tree/neo-tree.nvim
	opts = {
		close_if_last_window = true,
		sources = { "filesystem", "buffers", "git_status" },
		open_files_do_not_replace_types = {
			"terminal",
			"Trouble",
			"trouble",
			"qf",
			"edgy",
			"Outline",
			"gitsigns-blame",
		},
		popup_border_style = "rounded",
		sort_case_insensitive = true,

		source_selector = {
			winbar = false,
			show_scrolled_off_parent_node = true,
			padding = { left = 1, right = 0 },
			sources = {
				{ source = "filesystem", display_name = "  Files" }, --      
				{ source = "buffers", display_name = "  Buffers" }, --      
				{ source = "git_status", display_name = " 󰊢 Git" }, -- 󰊢      
			},
		},

		event_handlers = {
			-- Close neo-tree when opening a file.
			{
				event = "file_opened",
				handler = function()
					require("neo-tree").close_all()
				end,
			},
		},

		default_component_configs = {
			icon = {
				folder_empty = "",
				folder_empty_open = "",
				default = "",
			},
			modified = {
				symbol = "•",
			},
			name = {
				trailing_slash = true,
				highlight_opened_files = true, -- NeoTreeFileNameOpened
				use_git_status_colors = false,
			},
			git_status = {
				symbols = {
					-- Change type
					added = "A",
					deleted = "D",
					modified = "M",
					renamed = "R",
					-- Status type
					untracked = "U",
					ignored = "I",
					unstaged = "",
					staged = "S",
					conflict = "C",
				},
			},
		},
		window = {
			width = winwidth,
			mappings = {
				["q"] = "close_window",
				["?"] = "noop",
				["<Space>"] = "noop",

				["g?"] = "show_help",
				["<2-LeftMouse>"] = "open",
				["<CR>"] = "open_with_window_picker",
				["l"] = "open",
				["h"] = "close_node",
				["C"] = "close_node",
				["z"] = "close_all_nodes",
				["<C-r>"] = "refresh",

				["s"] = "noop",
				["sv"] = "open_split",
				["sg"] = "open_vsplit",
				["st"] = "open_tabnew",

				["<"] = "prev_source",
				[">"] = "next_source",

				["dd"] = "delete",
				["c"] = { "copy", config = { show_path = "relative" } },
				["m"] = { "move", config = { show_path = "relative" } },
				["a"] = { "add", nowait = true, config = { show_path = "relative" } },
				["N"] = { "add_directory", config = { show_path = "relative" } },
				["r"] = "rename",

				["P"] = "paste_from_clipboard",
				["p"] = {
					"toggle_preview",
					nowait = true,
					config = { use_float = true },
				},

				-- Custom commands
				["w"] = toggle_width,
				["Y"] = {
					function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						vim.fn.setreg("+", path, "c")
					end,
					desc = "Copy Path to Clipboard",
				},
				["O"] = {
					function(state)
						require("lazy.util").open(state.tree:get_node().path, { system = true })
					end,
					desc = "Open with System Application",
				},
			},
		},
		filesystem = {
			window = {
				mappings = {
					["d"] = "noop",
					["/"] = "noop",
					["f"] = "filter_on_submit",
					["F"] = "fuzzy_finder",
					["<C-c>"] = "clear_filter",

					-- Custom commands
					["gf"] = function(state)
						require("telescope.builtin").find_files({
							cwd = get_current_directory(state),
						})
					end,
					["gr"] = function(state)
						require("telescope.builtin").live_grep({
							cwd = get_current_directory(state),
						})
					end,
				},
			},

			-- See `:h neo-tree-cwd`
			-- bind_to_cwd = false,
			-- cwd_target = {
			-- 	sidebar = 'window',
			-- 	current = 'window',
			-- },

			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_by_name = {
					".git",
					".hg",
					".svc",
					".DS_Store",
					"thumbs.db",
					".sass-cache",
					"node_modules",
					".pytest_cache",
					".mypy_cache",
					"__pycache__",
					".stfolder",
					".stversions",
				},
				never_show_by_pattern = {
					"vite.config.js.timestamp-*",
				},
			},
			find_by_full_path_words = true,
			group_empty_dirs = true,
			use_libuv_file_watcher = true,
		},
		buffers = {
			window = {
				mappings = {
					["dd"] = "buffer_delete",
				},
			},
		},
		git_status = {
			window = {
				mappings = {
					["d"] = "noop",
					["dd"] = "delete",
				},
			},
		},
		document_symbols = {
			follow_cursor = true,
			window = {
				mappings = {
					["/"] = "noop",
					["F"] = "filter",
				},
			},
		},
	},
	config = function(_, opts)
		local function on_move(data)
			Snacks.rename.on_rename_file(data.source, data.destination)
		end

		local events = require("neo-tree.events")
		opts.event_handlers = opts.event_handlers or {}
		vim.list_extend(opts.event_handlers, {
			{ event = events.FILE_MOVED, handler = on_move },
			{ event = events.FILE_RENAMED, handler = on_move },
		})
		require("neo-tree").setup(opts)
		vim.api.nvim_create_autocmd("TermClose", {
			pattern = "*lazygit",
			callback = function()
				if package.loaded["neo-tree.sources.git_status"] then
					require("neo-tree.sources.git_status").refresh()
				end
			end,
		})
		vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "#08070a" })
		vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "#08070a" })
		vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { bg = "#08070a", fg = "#08070a" })
	end,
}
