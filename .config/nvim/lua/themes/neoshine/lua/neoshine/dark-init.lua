local theme = {}

-- Define colors
local colors = {
	bg = "#0b0b0f",
	fg = "#e6e6e6",
	yellow = "#e6e7a3",
	peach = "#f9b98c",
	low_peach = "#c68181",
	dimGray = "#161616",
	darkGray = "#37373d",
	midGrayDarker = "#565b5f",
	midGrayLighter = "#69737c",
	gray = "#9099a1",
	lightGray = "#bbc0c5",
	brown = "#51484f",
	red = "#d84f68",
	teal = "#54c0a3",
	green = "#4ebe96",
	blue = "#479ffa",
	magenta = "#ba68c8",
	cyan = "#4dd0e1",
	low_cyan = "#7fc6c5",
	purple = "#6e678e",
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

	vim.api.nvim_set_hl(0, "Indentation", { fg = colors.dimGray })

	-- Apply highlight groups
	local highlights = {
		Normal = { fg = colors.fg, bg = colors.bg }, -- Default text
		Comment = { fg = colors.darkGray, italic = true }, -- Comments
		String = { fg = colors.midGrayLighter }, -- Strings
		Function = { fg = colors.low_cyan }, -- Function names
		Keyword = { fg = colors.lightGray }, -- Keywords like function keyword, methods
		Identifier = { fg = colors.gray }, -- Variable types like const, <...>
		Type = { fg = colors.midGrayDarker }, -- Type declarations (int, float, etc.)
		LineNr = { fg = colors.darkGray }, -- Line numbers
		CursorLineNr = { fg = colors.midGrayLighter, bold = true }, -- Current line number
		Visual = { bg = colors.darkGray }, -- Visual selection
		StatusLine = { fg = colors.gray, bg = colors.dimGray }, -- Status line
		Pmenu = { fg = colors.gray, bg = colors.dimGray }, -- Popup menu
		PmenuSel = { fg = colors.bg, bg = colors.darkGray }, -- Selected popup item
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
		Special = { fg = colors.fg }, -- Special symbols or escape sequences
		CursorLine = { bg = colors.dimGray },
		Indentation = { fg = colors.dimGray }, -- Indentation
		["@keyword"] = { fg = colors.lightGray, bold = true },
		["@property"] = { fg = colors.gray },
		["@type"] = { fg = colors.midGrayDarker },
		["@type.qualifier"] = { fg = colors.midGrayDarker, italic = true },
		["@type.builtin"] = { fg = colors.midGrayDarker, italic = true },
		["@type.definition"] = { fg = colors.midGrayDarker, italic = true },
		["@string"] = { fg = colors.midGrayLighter },
		["@variable"] = { fg = colors.lightGray },
		["@variable.builtin"] = { fg = colors.fg },
		["@variable.parameter"] = { fg = colors.gray, italic = true },
		["@variable.parameter.builtin"] = { fg = colors.midGrayLighter },
		["@boolean"] = { fg = colors.pink },
		["@number"] = { fg = colors.low_peach },
		["@number.float"] = { fg = colors.low_peach },
		["@character"] = { fg = colors.low_peach },
		["@character.special"] = { fg = colors.low_peach },
		["@label"] = { fg = colors.fg },
		["@attribute"] = { fg = colors.fg, bold = true },
		["@attribute.builtin"] = { fg = colors.gray },
		["@function"] = { fg = colors.low_cyan },
		["@function.builtin"] = { fg = colors.low_peach },
		["@constructor"] = { fg = colors.low_cyan, bold = true },
		["@punctuation"] = { fg = colors.midGrayDarker },
		["@punctuation.special"] = { fg = colors.lightGray },
		["@operator"] = { fg = colors.midGrayLighter },
		["@module"] = { fg = colors.midGrayDarker },
		["@module.builtin"] = { fg = colors.midGrayDarker, bold = true },
		["@constant"] = { fg = colors.gray, italic = true },
		["@constant.builtin"] = { fg = colors.gray, italic = true },
		["@comment"] = { fg = colors.darkGray, italic = true },
		["@tag"] = { fg = colors.lightGray },
		["@tag.builtin"] = { fg = colors.low_peach, bold = true },
		["@markup"] = { fg = colors.blue },
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
