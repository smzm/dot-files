return {
	"folke/noice.nvim",
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	opts = {
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			messages = {
				enabled = true, -- enables the Noice messages UI
				view = "mini", -- default view for messages
				view_error = "mini", -- view for errors
				view_warn = "mini", -- view for warnings
				view_history = "mini", -- view for :messages
				view_search = "mini", -- view for search count messages. Set to `false` to disable
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			notify = {
				enabled = true,
				view = "mini",
			},
			routes = {
				-- See :h ui-messages
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "^%d+ changes?; after #%d+" },
							{ find = "^%d+ changes?; before #%d+" },
							{ find = "^Hunk %d+ of %d+$" },
							{ find = "^%d+ fewer lines;?" },
							{ find = "^%d+ more lines?;?" },
							{ find = "^%d+ line less;?" },
							{ find = "^Already at newest change" },
							{ kind = "wmsg" },
							{ kind = "emsg", find = "E486" },
							{ kind = "quickfix" },
						},
					},
					view = "mini",
				},
			},

			views = {
				-- This sets the position for the search popup that shows up with / or with :
				cmdline_popup = {
					position = {
						row = "40%",
						col = "50%",
					},
				},
				mini = {
					-- timeout = 5000, -- timeout in milliseconds
					timeout = vim.g.neovim_mode == "skitty" and 2000 or 5000,
					align = "center",
					position = {
						-- Centers messages top to bottom
						row = "95%",
						-- Aligns messages to the far right
						col = "100%",
					},
				},
			},
		},
	},
}
-- To swith between noice popup and neovim use : <C-w>w
