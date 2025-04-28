return { -- show tree of symbols in the current file
	"hedyhli/outline.nvim",
	cmd = "Outline",
	keys = {
		{ "\\", ":Outline<cr>", desc = "Toggle outline" },
	},
	opts = {
		outline_items = {
			show_symbol_lineno = true,
			auto_jump = true,
			auto_preview = true,
		},
		outline_window = {
			-- Percentage or integer of columns
			width = 30,
			relative_width = true,
			auto_jump = true,
			jump_highlight_duration = 300,
			center_on_jump = true,
		},
		symbols = {
			icon_fetcher = function(k, buf)
				if k == "String" then
					return ""
				end
				return false
			end,
			icon_source = "lspkind",
		},
		preview_window = {
			open_hover_on_preview = true,
			live = true,
			winhl = "NormalFloat:",
			border = "rounded",
		},
		providers = {
			priority = { "markdown", "lsp" },
			-- Configuration for each provider (3rd party providers are supported)
			lsp = {
				-- Lsp client names to ignore
				blacklist_clients = {},
			},
			markdown = {
				-- List of supported ft's to use the markdown provider
				filetypes = { "markdown", "quarto" },
			},
		},
	},
}
