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
				view_search = false,
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
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
		},
	},
}
-- To swith between noice popup and neovim use : <C-w>w
