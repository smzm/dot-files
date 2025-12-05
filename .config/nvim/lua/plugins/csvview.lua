return {
	"hat0uma/csvview.nvim",
	opts = {
		parser = {
			comments = { "#", "//" },
			delimiter = {
				ft = {
					csv = ",", -- Always use comma for .csv files
					tsv = "\t", -- Always use tab for .tsv files
				},
				fallbacks = { -- Try these delimiters in order for other files
					",", -- Comma (most common)
					"\t", -- Tab
					";", -- Semicolon
					"|", -- Pipe
					":", -- Colon
					" ", -- Space
				},
			},
		},
		view = {
			min_column_width = 7,
			spacing = 2,
			display_mode = "highlight",
			header_lnum = 1,
			sticky_header = {
				enabled = true,
				separator = "─",
			},
		},
		keymaps = {
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },

			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-tab>", mode = { "n", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
		},
	},

	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	ft = { "csv", "tsv" }, -- Load plugin for csv/tsv filetypes
	init = function()
		local augroup = vim.api.nvim_create_augroup("csvview_autoenable", { clear = true })
		vim.api.nvim_create_autocmd({ "FileType" }, {
			pattern = { "csv", "tsv" },
			group = augroup,
			callback = function()
				vim.cmd("CsvViewEnable")
			end,
		})
	end,
}
