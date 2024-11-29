local color_palette = {
	rosewater = "#f4dbd6",
	flamingo = "#f0c6c6",
	pink = "#f5bde6",
	mauve = "#c6a0f6",
	red = "#ed8796",
	maroon = "#ee99a0",
	peach = "#f5a97f",
	yellow = "#eed49f",
	green = "#a6da95",
	teal = "#8bd5ca",
	sky = "#91d7e3",
	sapphire = "#7dc4e4",
	blue = "#8aadf4",
	lavender = "#b7bdf8",
	aura_purple_1 = "#a277ff",
	aura_purple_2 = "#3d375e",
	aura_purple_3 = "#29263c",
	aura_green = "#61ffca",
	aura_orange = "#ffca85",
	aura_pink = "#f694ff",
	aura_blue = "#82e2ff",
	aura_red = "#ff6767",
	aura_white = "#edecee",
	aura_gray = "#6d6d6d",
	aura_black = "#15141b",
	text = "#cad3f5",
	subtext1 = "#b8c0e0",
	subtext0 = "#a5adcb",
	overlay2 = "#939ab7",
	overlay1 = "#8087a2",
	overlay0 = "#6e738d",
	surface2 = "#5b6078",
	surface1 = "#494d64",
	surface0 = "#363a4f",
	base = "#24273a",
	mantle = "#1e2030",
	crust = "#181926",
}

-- Plugins
require("full-border"):setup({
	type = ui.Border.ROUNDED,
})

require("yatline"):setup({
	section_separator = { open = "", close = " " },
	inverse_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },

	style_a = {
		fg = color_palette.mantle,
		bg_mode = {
			normal = color_palette.aura_blue,
			select = color_palette.aura_pink,
			un_set = color_palette.aura_red,
		},
	},
	style_b = { bg = color_palette.surface0, fg = color_palette.text },
	style_c = { bg = color_palette.base, fg = color_palette.text },

	permissions_t_fg = color_palette.green,
	permissions_r_fg = color_palette.yellow,
	permissions_w_fg = color_palette.red,
	permissions_x_fg = color_palette.sky,
	permissions_s_fg = color_palette.lavender,

	selected = { icon = "󰻭", fg = color_palette.yellow },
	copied = { icon = "", fg = color_palette.green },
	cut = { icon = "", fg = color_palette.red },

	total = { icon = "", fg = color_palette.yellow },
	succ = { icon = "", fg = color_palette.green },
	fail = { icon = "", fg = color_palette.red },
	found = { icon = "", fg = color_palette.blue },
	processed = { icon = "", fg = color_palette.green },

	tab_width = 20,
	tab_use_inverse = true,

	show_background = false,

	display_header_line = true,
	display_status_line = true,

	header_line = {
		left = {
			section_a = {
				{ type = "line", custom = false, name = "tabs", params = { "left" } },
			},
			section_b = {
				{ type = "coloreds", custom = false, name = "githead" },
			},
			section_c = {},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "tab_path" },
			},
			section_b = {},
			section_c = {},
		},
	},

	status_line = {
		left = {
			section_a = {
				{ type = "string", custom = false, name = "tab_mode" },
			},
			section_b = {
				{ type = "string", custom = false, name = "hovered_size" },
			},
			section_c = {},
		},
		right = {
			section_a = {},
			section_b = {},
			section_c = {
				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
				{ type = "coloreds", custom = false, name = "permissions" },
			},
		},
	},
})

require("yatline-githead"):setup({
	show_branch = true,
	branch_prefix = "",
	branch_symbol = "",
	branch_borders = "",

	commit_symbol = " ",

	show_behind_ahead = true,
	behind_symbol = " ",
	ahead_symbol = " ",

	show_stashes = true,
	stashes_symbol = " ",

	show_state = true,
	show_state_prefix = true,
	state_symbol = "󱅉",

	show_staged = true,
	staged_symbol = " ",

	show_unstaged = true,
	unstaged_symbol = " ",

	show_untracked = true,
	untracked_symbol = " ",

	prefix_color = color_palette.pink,
	branch_color = color_palette.pink,
	commit_color = color_palette.mauve,
	stashes_color = color_palette.teal,
	state_color = color_palette.lavender,
	staged_color = color_palette.green,
	unstaged_color = color_palette.yellow,
	untracked_color = color_palette.pink,
	ahead_color = color_palette.green,
	behind_color = color_palette.yellow,
})

require("zoxide"):setup({
	update_db = true,
})
