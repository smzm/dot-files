return {
	"hat0uma/csvview.nvim",
	opts = {
		parser = {
			comments = { "#", "//" },
			delimiter = {
				default = ",",
				ft = {
					tsv = "\t",
				},
			},
		},
		view = {
			min_column_width = 7,
			spacing = 2,
			display_mode = "highlight", -- "highlight", "border"
			header_lnum = 1,
			sticky_header = {
				enabled = true,
				separator = "─",
			},
		},
		keymaps = {
			-- Text objects for selecting fields
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },
			-- Excel-like navigation:
			-- Use <Tab> and <S-Tab> to move horizontally between fields.
			-- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
			-- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-tab>", mode = { "n", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
		},
	},
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
}
