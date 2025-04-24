local theme = {}

local colors = {
	bg = "#090909",
	fg = "#c9c9c9",
	yellow = "#e6e7a3",
	peach = "#f9b98c",
	low_peach = "#c68181",
	dimGrayDarker = "#121212",
	dimGrayLighter = "#303030",
	darkGray = "#303030",
	midGrayDarker = "#555555",
	midGrayLighter = "#7b7b7b",
	gray = "#9E9E9E",
	lightGray = "#bcbcbc",
	brown = "#51484f",
	red = "#d84f68",
	teal = "#54c0a3",
	green = "#4ebe96",
	blue = "#479ffa",
	magenta = "#ba68c8",
	cyan = "#4dd0e1",
	low_cyan = "#7fc6c5",
	purple = "#9D7FC7",
	low_purple = "#c5b3e4",
	pink = "#F0A6CA",
	black = "#000000",
}

function theme.setup()
	-- Reset existing highlight groups
	vim.cmd("highlight clear")
	vim.o.background = "dark" -- Set the theme background
	vim.o.termguicolors = true -- Enable true colors
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end

	vim.api.nvim_set_hl(0, "Indentation", { fg = colors.dimGrayDarker })
	vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = colors.dimGrayLighter })

	-- Apply highlight groups
	local highlights = {
		Normal = { fg = colors.fg, bg = colors.bg }, -- Default text
		Comment = { fg = colors.midGrayDarker, italic = true }, -- Comments
		String = { fg = colors.midGrayLighter }, -- Strings
		Function = { fg = colors.low_cyan }, -- Function names
		Keyword = { fg = colors.midGrayDarker }, -- Keywords like function keyword, methods
		Identifier = { fg = colors.gray }, -- Variable types like const, <...>
		Type = { fg = colors.midGrayDarker }, -- Type declarations (int, float, etc.)
		LineNr = { fg = colors.dimGrayDarker }, -- Line numbers
		CursorLineNr = { fg = colors.midGrayLighter, bold = true }, -- Current line number
		Visual = { bg = colors.black, fg = colors.fg }, -- Visual selection
		StatusLine = { fg = colors.gray, bg = colors.dimGray }, -- Status line
		Pmenu = { fg = colors.gray, bg = colors.dimGray }, -- Popup menu
		PmenuSel = { fg = colors.bg, bg = colors.midGrayDarker }, -- Selected popup item
		Error = { fg = colors.bg, bg = colors.red, bold = true }, -- Error messages
		Warning = { fg = colors.peach, bold = true }, -- Warning messages
		Operator = { fg = colors.midGrayLighter }, -- For signs like =, +, -, *
		Delimiter = { fg = colors.midGrayDarker }, -- Brackets and braces: (), {}, []
		Constant = { fg = colors.yellow }, -- Constants: true, false, nil
		Number = { fg = colors.peach }, -- Numbers
		Boolean = { fg = colors.pink }, -- Boolean: true, false
		Float = { fg = colors.peach }, -- Floating point numbers
		Character = { fg = colors.green }, -- Single characters: 'a'
		PreProc = { fg = colors.gray }, -- Preprocessor directives (#define)
		Include = { fg = colors.cyan }, -- Include statements (#include)
		Define = { fg = colors.cyan }, -- #define macros
		Macro = { fg = colors.cyan }, -- Macros
		StorageClass = { fg = colors.lightGray }, -- static, extern, etc.
		Structure = { fg = colors.lightGray }, -- struct, union
		Typedef = { fg = colors.lightGray }, -- typedef
		Underlined = { fg = colors.gray, underline = true }, -- Underlined text
		Title = { fg = colors.low_peach, bold = true }, -- Titles
		Todo = { fg = colors.yellow, bold = true }, -- TODO comments
		Tag = { fg = colors.peach },
		WinBar = { fg = colors.fg, bg = colors.bg },
		WinBarNC = { fg = colors.fg, bg = colors.bg },
		debarWinSeparator = { bg = colors.bg },
		NormalFloat = { fg = colors.midGrayLighter, bg = colors.bg },
		Special = { fg = colors.fg }, -- Special symbols or escape sequences
		IncSearch = { fg = colors.bg, bg = colors.lightGray },
		Search = { fg = colors.bg, bg = colors.midGrayLighter },
		CurSearch = { fg = colors.bg, bg = colors.lightGray },
		CursorLine = { bg = colors.dimGrayDarker },
		Indentation = { fg = colors.dimGrayDarker }, -- Indentation
		["@keyword"] = { fg = colors.fg, bold = true },
		["@type"] = { fg = colors.midGrayDarker },
		["@type.qualifier"] = { fg = colors.midGrayDarker },
		["@type.builtin"] = { fg = colors.midGrayDarker },
		["@type.definition"] = { fg = colors.midGrayDarker },
		["@string"] = { fg = colors.midGrayDarker },
		["@property"] = { fg = colors.gray, bold = true },
		["@variable"] = { fg = colors.midGrayLighter },
		["@variable.builtin"] = { fg = colors.midGrayDarker },
		["@variable.parameter"] = { fg = colors.midGrayDarker },
		["@variable.parameter.builtin"] = { fg = colors.midGrayDarker },
		["@boolean"] = { fg = colors.fg },
		["@number"] = { fg = colors.fg },
		["@number.float"] = { fg = colors.fg },
		["@character"] = { fg = colors.fg },
		["@character.special"] = { fg = colors.fg },
		["@label"] = { fg = colors.fg },
		["@attribute"] = { fg = colors.lightGray, bold = true },
		["@attribute.builtin"] = { fg = colors.gray },
		["@function"] = { fg = colors.fg },
		["@function.builtin"] = { fg = colors.fg, bold = true },
		["@constructor"] = { fg = colors.lightGray },
		["@punctuation"] = { fg = colors.lightGray },
		["@punctuation.special"] = { fg = colors.lightGray },
		["@operator"] = { fg = colors.lightGray },
		["@module"] = { fg = colors.midGrayLighter },
		["@module.builtin"] = { fg = colors.midGrayLighter, bold = true },
		["@constant"] = { fg = colors.gray, italic = true },
		["@constant.builtin"] = { fg = colors.midGrayLighter },
		["@comment"] = { fg = colors.darkGray, italic = true },
		["@tag"] = { fg = colors.midGrayLighter },
		["@tag.builtin"] = { fg = colors.lightGray, bold = true },
		["@markup"] = { fg = colors.fg },
		["@markup.strong"] = { fg = colors.fg, bold = true },
		["@markup.italic"] = { fg = colors.fg, italic = true },
		["@markup.underline"] = { fg = colors.fg, underline = true },
		["@markup.strikethrough"] = { fg = colors.fg, strikethrough = true },
		["@markup.heading"] = { fg = colors.fg, bold = true },
		["@markup.link"] = { fg = colors.fg, underline = true },
	}

	-- Set highlights using API
	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

theme.colors = colors

return theme
