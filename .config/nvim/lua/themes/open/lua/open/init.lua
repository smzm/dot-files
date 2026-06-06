local theme = {}

local colors = {
	white = "#ffffff",
	gray_000 = "#FAFAFA",
	gray_050 = "#EAEAEA",
	gray_100 = "#E1E1E1",
	gray_150 = "#DEDEDE",
	gray_200 = "#D3D3D3",
	gray_250 = "#C9C9C9",
	gray_300 = "#BFBFBF",
	gray_350 = "#A6A6A6",
	gray_400 = "#999999",
	gray_450 = "#8C8C8C",
	gray_500 = "#737373",
	gray_550 = "#666666",
	gray_600 = "#595959",
	gray_650 = "#4D4D4D",
	gray_700 = "#404040",
	gray_750 = "#333333",
	gray_800 = "#262626",
	gray_850 = "#1A1A1A",
	gray_900 = "#151515",
	gray_950 = "#111111",
	gray_1000 = "#090909",
	gray_1050 = "#070707",
	black = "#000000",
	orange = "#FF9E6C",
	light_green = "#99ffe4",
	green = "#66D492",
	red = "#FF0000",
	pink = "#FFA3CE",
	lavender = "#BE95FA",
	blue = "#48AAFF",
}

function theme.setup()
	-- Reset existing highlight groups
	vim.cmd("highlight clear")
	vim.o.background = "dark" -- Set the theme background
	vim.o.termguicolors = true -- Enable true colors
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end

	-- Set different background colors based on light/dark mode
	local background
	local foreground
	local gray_shades_01, gray_shades_02, gray_shades_03, gray_shades_04, gray_shades_05
	local gray_shades_06, gray_shades_07, gray_shades_08, gray_shades_09, gray_shades_10
	local gray_shades_11, gray_shades_12, gray_shades_13, gray_shades_14, gray_shades_15
	local gray_shades_16, gray_shades_17, gray_shades_18, gray_shades_19, gray_shades_20
	local black = colors.black
	local red = colors.red
	local pink = colors.pink
	local orange = colors.orange
	local light_green = colors.light_green
	local green = colors.green
	local lavender = colors.lavender
	local blue = colors.blue

	background = colors.gray_900 -- Darkest background
	gray_shades_01 = colors.gray_1000
	gray_shades_02 = colors.gray_950
	gray_shades_03 = colors.gray_900
	gray_shades_04 = colors.gray_850
	gray_shades_05 = colors.gray_800
	gray_shades_06 = colors.gray_750
	gray_shades_07 = colors.gray_700
	gray_shades_08 = colors.gray_650
	gray_shades_09 = colors.gray_600
	gray_shades_10 = colors.gray_550
	gray_shades_11 = colors.gray_500
	gray_shades_12 = colors.gray_450
	gray_shades_13 = colors.gray_400
	gray_shades_14 = colors.gray_350
	gray_shades_15 = colors.gray_300
	gray_shades_16 = colors.gray_250
	gray_shades_17 = colors.gray_200
	gray_shades_18 = colors.gray_150
	gray_shades_19 = colors.gray_100
	gray_shades_20 = colors.gray_050 -- Lightest shade
	foreground = colors.gray_400

	vim.api.nvim_set_hl(0, "Indentation", { fg = gray_shades_04 })
	vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = gray_shades_05 })
	vim.api.nvim_set_hl(0, "NvimParenthesis_1", { fg = blue })
	vim.api.nvim_set_hl(0, "NvimParenthesis_2", { fg = gray_shades_19 })
	vim.api.nvim_set_hl(0, "NvimParenthesis_3", { fg = gray_shades_17 })
	vim.api.nvim_set_hl(0, "NvimParenthesis_4", { fg = gray_shades_15 })
	vim.api.nvim_set_hl(0, "NvimParenthesis_5", { fg = gray_shades_13 })
	vim.api.nvim_set_hl(0, "NvimParenthesis_6", { fg = gray_shades_11 })
	vim.api.nvim_set_hl(0, "NvimParenthesis_7", { fg = gray_shades_09 })

	-- -- 👉 Headings
	-- vim.api.nvim_set_hl(0, "H1", { fg = gray_shades_01, bg = gray_shades_18, bold = true })
	-- vim.api.nvim_set_hl(0, "ReversedH1", { fg = gray_shades_17, bg = gray_shades_01, bold = true })
	-- vim.api.nvim_set_hl(0, "H2", { fg = gray_shades_01, bg = gray_shades_13, bold = true })
	-- vim.api.nvim_set_hl(0, "ReversedH2", { fg = gray_shades_12, bg = gray_shades_01, bold = true })
	-- vim.api.nvim_set_hl(0, "H3", { fg = gray_shades_02, bg = gray_shades_07, bold = true })
	-- vim.api.nvim_set_hl(0, "H4", { fg = gray_shades_10, bg = gray_shades_03, bold = true })
	-- vim.api.nvim_set_hl(0, "ReversedH3", { fg = gray_shades_07, bg = gray_shades_01, bold = true })
	-- vim.api.nvim_set_hl(0, "CodeBlock", { bg = gray_shades_01 })
	-- vim.api.nvim_set_hl(0, "CodeBorder", { fg = gray_shades_06, bg = gray_shades_01 })
	-- vim.api.nvim_set_hl(0, "InlineCodeBlock", { fg = gray_shades_11, bg = gray_shades_04 })

	local highlights = {
		-- Added = { fg = "" , bg = ""}
		-- @diff.plus

		Boolean = { fg = blue },
		-- @boolean

		Character = { fg = red },
		-- @character
		-- @character.special
		-- Changed = { fg = "" , bg = ""}
		-- @diff.delta
		-- ColorColumn = { fg = "" , bg = ""}

		Comment = { fg = gray_shades_08, italic = true },
		-- @comment
		-- @comment.error
		-- @comment.warning
		-- @comment.note
		-- @comment.todo
		-- ComplMatchIns = { fg = "" , bg = ""}

		DiagnosticUnnecessary = { fg = gray_shades_08 },

		Conceal = { fg = background, bg = background },

		Constant = { fg = lavender },
		-- @constant
		-- @constant.builtin
		-- Character
		-- Number
		-- Boolean
		-- Float

		CurSearch = { fg = background, bg = gray_shades_18 },
		-- 6ncSearch

		Cursor = { bg = gray_shades_02 },
		-- lCursor
		-- CursorIM

		CursorColumn = { fg = gray_shades_02 },

		CursorLine = { bg = gray_shades_02 },

		CursorLineNr = { bg = gray_shades_02 },

		CursorLineFold = { bg = gray_shades_02 },
		--  CursorLineSign = { fg = "" , bg = ""}
		--  DiffAdd = { fg = "" , bg = ""}
		--  DiffChange = { fg = "" , bg = ""}
		--  DiffDelete = { fg = "" , bg = ""}
		--  DiffText = { fg = "" , bg = ""}
		--  DiagnosticDeprecated = { fg = "" , bg = ""}
		--  @lsp.mod.deprecated
		--  DiagnosticError = { fg = "" , bg = ""}
		--  DiagnosticFloatingError
		--  DiagnosticVirtualTextError
		--  DiagnosticVirtualLinesError
		--  DiagnosticSignError
		--  @comment.error
		--  DiagnosticHint = { fg = "" , bg = ""}
		--  DiagnosticFloatingHint
		DiagnosticVirtualTextHint = { fg = gray_shades_10 },
		DiagnosticVirtualLinesHint = { fg = gray_shades_10 },
		--  DiagnosticSignHint
		--  DiagnosticInfo = { fg = "" , bg = ""}
		--  DiagnosticFloatingInfo
		--  DiagnosticVirtualTextInfo
		--  DiagnosticVirtualLinesInfo
		--  DiagnosticSignInfo
		--  @comment.note
		--  DiagnosticOk = { fg = "" , bg = ""}
		--  DiagnosticFloatingOk
		--  DiagnosticVirtualTextOk
		--  DiagnosticVirtualLinesOk
		--  DiagnosticSignOk
		DiagnosticUnderlineError = { undercurl = true, sp = light_red },
		DiagnosticUnderlineHint = { underline = true, sp = gray_shades_06 },
		-- DiagnosticUnderlineInfo = { fg = "" , bg = ""}
		-- DiagnosticUnderlineOk = { fg = "" , bg = ""}
		--  DiagnosticWarn = { fg = "" , bg = ""}
		--  DiagnosticFloatingWarn
		DiagnosticUnderlineWarn = { undercurl = false, sp = gray_shades_05 },
		-- DiagnosticVirtualTextWarn = { fg = gray_shades_06 },
		DiagnosticVirtualLinesWarn = { fg = gray_shades_08 },
		DiagnosticSignWarn = { fg = gray_shades_08 },
		--  @comment.warning
		--  Directory = { fg = "" , bg = ""}

		Delimiter = { fg = gray_shades_15 },
		-- @punctuation
		NvimParenthesis = { fg = blue },
		-- NvimLambda
		-- NvimNestingParenthesis
		-- NvimCallingParenthesis
		-- NvimSubscript
		-- NvimSubscriptBracket
		-- NvimSubscriptColon
		-- NvimCurly
		-- NvimContainer
		-- NvimDict
		-- NvimList
		-- NvimColon
		-- NvimComma
		-- NvimArrow

		EndOfBuffer = { link = "Conceal" }, -- ~ sign in the gutter

		-- Error = { fg = "" , bg = ""}
		-- NvimInvalid
		-- NvimInvalidAssignment
		-- NvimInvalidPlainAssignment
		-- NvimInvalidAugmentedAssignment
		-- NvimInvalidAssignmentWithAddition
		-- NvimInvalidAssignmentWithSubtraction
		-- NvimInvalidAssignmentWithConcatenation
		-- NvimInvalidOperator
		-- NvimInvalidUnaryOperator
		-- NvimInvalidUnaryPlus
		-- NvimInvalidUnaryMinus
		-- NvimInvalidNot
		-- NvimInvalidBinaryOperator
		-- NvimInvalidComparison
		-- NvimInvalidComparisonModifier
		-- NvimInvalidBinaryPlus
		-- NvimInvalidBinaryMinus
		-- NvimInvalidConcat
		-- NvimInvalidConcatOrSubscript
		-- NvimInvalidOr
		-- NvimInvalidAnd
		-- NvimInvalidMultiplication
		-- NvimInvalidDivision
		-- NvimInvalidMod
		-- NvimInvalidTernary
		-- NvimInvalidTernaryColon
		-- NvimInvalidDelimiter
		-- NvimInvalidParenthesis
		-- NvimInvalidLambda
		-- NvimInvalidNestingParenthesis
		-- NvimInvalidCallingParenthesis
		-- NvimInvalidSubscript
		-- NvimInvalidSubscriptBracket
		-- NvimInvalidSubscriptColon
		-- NvimInvalidCurly
		-- NvimInvalidContainer
		-- NvimInvalidDict
		-- NvimInvalidList
		-- NvimInvalidValue
		-- NvimInvalidIdentifier
		-- NvimInvalidIdentifierScope
		-- NvimInvalidIdentifierScopeDelimiter
		-- NvimInvalidIdentifierName
		-- NvimInvalidIdentifierKey
		-- NvimInvalidColon
		-- NvimInvalidComma
		-- NvimInvalidArrow
		-- NvimInvalidRegister
		-- NvimInvalidNumber
		-- NvimInvalidFloat
		-- NvimInvalidNumberPrefix
		-- NvimInvalidOptionSigil
		-- NvimInvalidOptionName
		-- NvimInvalidOptionScope
		-- NvimInvalidOptionScopeDelimiter
		-- NvimInvalidEnvironmentSigil
		-- NvimInvalidEnvironmentName
		-- NvimInvalidString
		-- NvimInvalidStringBody
		-- NvimInvalidStringQuote
		-- NvimInvalidStringSpecial
		-- NvimInvalidSingleQuote
		-- NvimInvalidSingleQuotedBody
		-- NvimInvalidSingleQuotedQuote
		-- NvimInvalidDoubleQuote
		-- NvimInvalidDoubleQuotedBody
		-- NvimInvalidDoubleQuotedEscape
		-- NvimInvalidDoubleQuotedUnknownEscape
		-- NvimInvalidFigureBrace
		-- NvimInvalidSpacing
		-- NvimInternalError
		-- ErrorMsg = { fg = "" , bg = ""}

		Float = { fg = gray_shades_08 },
		-- @number.float
		-- NvimFloat

		FloatBorder = { fg = gray_shades_06 },

		FloatFooter = { fg = gray_shades_12, bg = gray_shades_02 },

		-- FloatShadow = { fg = "" , bg = ""}
		-- FloatShadowThrough = { fg = "" , bg = ""}

		FloatTitle = { fg = gray_shades_14, bold = true },

		-- FoldColumn = { fg = "" , bg = ""}

		Folded = { fg = gray_shades_12, bg = gray_shades_02 },

		Function = { fg = lavender },
		["@function.method"] = { fg = gray_shades_16 },
		["@function.builtin"] = { fg = gray_shades_16 },
		["@lsp.type.macro"] = { fg = gray_shades_16 },
		["@lsp.type.struct"] = { fg = gray_shades_16 },
		["@lsp.type.enum"] = { fg = gray_shades_16 },
		["@lsp.type.interface"] = { fg = lavender },

		Identifier = { fg = gray_shades_14 },
		-- @property
		-- NvimIdentifier
		-- NvimIdentifierScope
		-- NvimIdentifierScopeDelimiter
		-- NvimIdentifierName
		-- NvimIdentifierKey
		-- NvimOptionName
		-- NvimOptionScope
		-- NvimOptionScopeDelimiter
		-- NvimEnvironmentName
		-- Ignore = { fg = "" , bg = ""}

		Keyword = { fg = pink },
		-- @keyword
		Label = { fg = gray_shades_13 },
		-- @label

		LineNr = { fg = gray_shades_06 },
		-- LineNrAbove
		-- LineNrBelow
		-- LspCodeLens = { fg = "" , bg = ""}
		-- LspCodeLensSeparator
		LspInlayHint = { fg = gray_shades_07, bg = gray_shades_03 },

		LspReferenceRead = { fg = "NONE", bg = "NONE" },
		-- LspReferenceTarget = { fg = "" , bg = ""}

		LspReferenceText = { fg = "NONE", bg = "NONE" },
		-- Visual
		-- VisualNOS
		-- SnippetTabstop

		LspReferenceWrite = { fg = gray_shades_14, bg = "NONE", bold = true },
		-- LspSignatureActiveParameter = { fg = "" , bg = ""}
		-- @attribute
		-- @attribute.builtin

		MatchParen = { fg = gray_shades_01, bg = gray_shades_09, bold = true },

		-- ModeMsg = { fg = "" , bg = ""}
		-- MoreMsg = { fg = "" , bg = ""}
		-- MsgArea = { fg = "" , bg = ""}
		-- MsgSeparator = { fg = "" , bg = ""}

		NonText = { fg = gray_shades_06, bg = gray_shades_02 },
		-- SpecialKey
		-- EndOfBuffer
		-- LspCodeLens
		-- LspInlayHint
		-- Whitespace
		IblWhitespace = { bg = "NONE", fg = "NONE", nocombine = true },

		Normal = { fg = foreground, bg = background },
		-- Ignore
		-- @diff
		-- NvimSpacing

		NormalFloat = { bg = gray_shades_02 },

		NormalNC = { bg = background },

		Number = { fg = orange },
		-- @number
		-- @number.float
		-- NvimNumber
		-- NvimAssignment = { fg = "" , bg = ""}
		-- NvimPlainAssignment
		-- NvimAugmentedAssignment
		-- NvimAssignmentWithAddition
		-- NvimAssignmentWithSubtraction
		-- NvimAssignmentWithConcatenation
		-- NvimDoubleQuotedUnknownEscape = { fg = "" , bg = ""}
		-- NvimEnvironmentSigil = { fg = "" , bg = ""}
		-- NvimFigureBrace = { fg = "" , bg = ""}
		-- NvimInternalError = { fg = "" , bg = ""}
		-- NvimSingleQuotedUnknownEscape
		-- NvimInvalidSingleQuotedUnknownEscape
		-- NvimNumberPrefix = { fg = "" , bg = ""}
		-- NvimOperator = { fg = "" , bg = ""}
		-- NvimUnaryOperator
		-- NvimUnaryPlus
		-- NvimUnaryMinus
		-- NvimNot
		-- NvimBinaryOperator
		-- NvimComparison
		-- NvimComparisonModifier
		-- NvimBinaryPlus
		-- NvimBinaryMinus
		-- NvimConcat
		-- NvimConcatOrSubscript
		-- NvimOr
		-- NvimAnd
		-- NvimMultiplication
		-- NvimDivision
		-- NvimMod
		-- NvimTernary
		-- NvimTernaryColon
		-- NvimOptionSigil = { fg = "" , bg = ""}
		-- NvimRegister = { fg = "" , bg = ""}
		-- NvimSingleQuotedQuote = { fg = "" , bg = ""}
		-- NvimString = { fg = "" , bg = ""}
		-- NvimStringBody
		-- NvimStringQuote
		-- NvimSingleQuote
		-- NvimSingleQuotedBody
		-- NvimDoubleQuote
		-- NvimDoubleQuotedBody
		-- NvimStringSpecial = { fg = "" , bg = ""}
		-- NvimDoubleQuotedEscape

		Operator = { fg = pink },
		-- @operator
		-- NvimAssignment
		-- NvimOperator

		Pmenu = { fg = gray_shades_08, bg = gray_shades_02 },
		-- PmenuKind
		-- PmenuSbar
		-- PmenuExtraSel = { fg = "" , bg = ""}
		-- PmenuKindSel = { fg = "" , bg = ""}
		-- PmenuMatch = { fg = "" , bg = ""}
		-- PmenuMatchSel = { fg = "" , bg = ""}
		PmenuExtra = { fg = gray_shades_08 },
		PmenuThumb = { fg = gray_shades_10, bg = gray_shades_04 },

		PmenuSel = { fg = gray_shades_14, bg = gray_shades_06 },
		-- PmenuKindSel
		-- PmenuExtraSel
		-- WildMenu
		-- PreCondit = { fg = "" , bg = ""}
		-- PreProc = { fg = "" , bg = ""}
		-- Include
		-- Define
		-- Macro
		-- PreCondit
		-- Question = { fg = "" , bg = ""}
		-- QuickFixLine = { fg = "" , bg = ""}
		-- RedrawDebugClear = { fg = "" , bg = ""}
		-- RedrawDebugComposed = { fg = "" , bg = ""}
		-- RedrawDebugNormal = { fg = "" , bg = ""}
		-- RedrawDebugRecompose = { fg = "" , bg = ""}
		-- Removed = { fg = "" , bg = ""}
		-- @diff.minus
		-- Repeat = { fg = "" , bg = ""}

		Search = { fg = gray_shades_16, bg = gray_shades_06 },
		-- Substitute
		-- SignColumn = { fg = "" , bg = ""}
		-- SnippetTabstop = { fg = "" , bg = ""}

		Special = { fg = blue },
		-- @module.builtin
		-- @string.regexp
		-- @string.special
		-- @string.escape
		-- constant.builtin
		-- @type.builtin
		-- @attribute.builtin
		-- @constructor
		-- @punctuation.special
		-- @markup
		-- SpecialChar
		-- SpecialComment
		-- Debug
		-- NvimRegister
		-- NvimStringSpecial

		SpecialChar = { fg = pink },
		-- @string.special
		-- @string.escape
		-- @character.special
		-- NvimStringSpecial
		["@variable"] = { fg = lavender },
		["@variable.builtin"] = { link = "SpecialChar" },
		["@variable.parameter"] = { fg = lavender },
		-- SpecialComment = { fg = "" , bg = ""}
		-- SpecialKey = { fg = "" , bg = ""}
		-- SpellBad = { fg = "" , bg = ""}
		-- SpellCap = { fg = "" , bg = ""}
		-- SpellLocal = { fg = "" , bg = ""}
		-- SpellRare = { fg = "" , bg = ""}

		Statement = { fg = gray_shades_12 },
		-- Conditional
		-- Repeat
		-- Label
		-- Keyword
		-- Exception

		StatusLine = { fg = foreground, bg = background },
		-- MsgSeparator
		-- StatusLineNC = { fg = "" , bg = ""}
		-- TabLine
		-- StatusLineTerm = { fg = "" , bg = ""}
		-- StatusLineTermNC = { fg = "" , bg = ""}
		-- StorageClass = { fg = "" , bg = ""}

		String = { fg = green },
		-- @string
		-- @string.regexp
		-- @string.special
		-- @string.escape
		-- @string.special.url
		-- NvimString

		Structure = { fg = gray_shades_17 },
		-- @module
		-- @module.builtin
		-- Substitute = { fg = "" , bg = ""}
		-- TabLine = { fg = "" , bg = ""}
		-- TabLineFill = { fg = "" , bg = ""}
		-- TabLineSel = { fg = "" , bg = ""}

		Tag = { fg = red },
		["@tag"] = { fg = gray_shades_14 },
		["@tag.builtin"] = { fg = red },
		-- TermCursor = { fg = "" , bg = ""}

		Title = { fg = gray_shades_14, bold = true },
		-- @markup.heading
		-- FloatTitle
		-- FloatFooter

		Todo = { fg = gray_shades_16, bg = gray_shades_02 },
		-- @comment.todo

		Type = { fg = gray_shades_13, bold = false },
		-- @type
		-- @type.builtin
		-- StorageClass
		-- Typedef
		-- NvimNumberPrefix
		-- NvimOptionSigil
		-- NvimEnvironmentSigil

		Typedef = { fg = gray_shades_08 },

		Underlined = { fg = gray_shades_10, underline = true },
		-- @string.special.url
		-- @markup.link
		-- VertSplit = { fg = "" , bg = ""}

		Visual = { fg = foreground, bg = gray_shades_06 },
		-- LspReferenceText
		-- LspSignatureActiveParameter
		-- SnippetTabstop
		-- VisualNOS
		-- VisualNC = { fg = "" , bg = ""}
		-- VisualNOS = { fg = "" , bg = ""}
		-- WarningMsg = { fg = "" , bg = ""}
		-- WildMenu = { fg = "" , bg = ""}
		-- WinBar = { fg = "" , bg = ""}
		-- WinBarNC = { fg = "" , bg = ""}
		-- VertSplit
		-- @diff = { fg = "" , bg = ""}
		-- @lsp = { fg = "" , bg = ""}
		WinSeparator = { fg = gray_shades_06, bg = "NONE" },

		["@markup"] = { fg = foreground },
		["@markup.strong"] = { fg = foreground, bold = true },
		["@markup.italic"] = { fg = foreground, italic = true },
		["@markup.underline"] = { fg = foreground, underline = true },
		["@markup.strikethrough"] = { fg = gray_shades_08, strikethrough = true },
		["@markup.heading"] = { fg = foreground, bold = true },
		["@markup.link"] = { fg = gray_shades_09 },
		["@markup.quote"] = { fg = gray_shades_09, bg = gray_shades_03 },

		-- @markup.heading.1.delimiter.vimdoc = { fg = "" , bg = ""}
		-- @markup.heading.2.delimiter.vimdoc = { fg = "" , bg = ""}

		SnacksStatusColumnMark = { fg = gray_shades_20 },
	}

	-- Set highlights using API
	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

return theme
