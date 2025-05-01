local theme = {}

local light_colors = {
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
	gray_950 = "#0D0D0D",
	gray_1000 = "#090909",
	black = "#000000",
	red = "#FF0000",
	blue = "#0000FF",
}

function theme.setup()
	-- Reset existing highlight groups
	vim.cmd("highlight clear")
	vim.o.background = "dark" -- Set the theme background
	vim.o.termguicolors = true -- Enable true colors
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end

	local colors = vim.o.background == "dark" and dark_colors or light_colors

	-- Set different background colors based on light/dark mode
	local background
	local bg_shades_01, bg_shades_02, bg_shades_03, bg_shades_04, bg_shades_05
	local bg_shades_06, bg_shades_07, bg_shades_08, bg_shades_09, bg_shades_10
	local bg_shades_11, bg_shades_12, bg_shades_13, bg_shades_14, bg_shades_15
	local bg_shades_16, bg_shades_17, bg_shades_18, bg_shades_19, bg_shades_20

	if vim.o.background == "dark" then
		background = colors.gray_1000 -- Darkest background
		bg_shades_01 = colors.gray_950
		bg_shades_02 = colors.gray_900
		bg_shades_03 = colors.gray_850
		bg_shades_04 = colors.gray_800
		bg_shades_05 = colors.gray_750
		bg_shades_06 = colors.gray_700
		bg_shades_07 = colors.gray_650
		bg_shades_08 = colors.gray_600
		bg_shades_09 = colors.gray_550
		bg_shades_10 = colors.gray_500
		bg_shades_11 = colors.gray_450
		bg_shades_12 = colors.gray_400
		bg_shades_13 = colors.gray_350
		bg_shades_14 = colors.gray_300
		bg_shades_15 = colors.gray_250
		bg_shades_16 = colors.gray_200
		bg_shades_17 = colors.gray_150
		bg_shades_18 = colors.gray_100
		bg_shades_19 = colors.gray_050
		bg_shades_20 = colors.gray_000 -- Lightest shade
	else
		background = colors.gray_050 -- Light background
		bg_shades_01 = colors.gray_100
		bg_shades_02 = colors.gray_150
		bg_shades_03 = colors.gray_200
		bg_shades_04 = colors.gray_250
		bg_shades_05 = colors.gray_300
		bg_shades_06 = colors.gray_350
		bg_shades_07 = colors.gray_400
		bg_shades_08 = colors.gray_450
		bg_shades_09 = colors.gray_500
		bg_shades_10 = colors.gray_550
		bg_shades_11 = colors.gray_600
		bg_shades_12 = colors.gray_650
		bg_shades_13 = colors.gray_700
		bg_shades_14 = colors.gray_750
		bg_shades_15 = colors.gray_800
		bg_shades_16 = colors.gray_850
		bg_shades_17 = colors.gray_900
		bg_shades_18 = colors.gray_950
		bg_shades_19 = colors.gray_1000
		bg_shades_20 = colors.black -- Darkest shade
	end

	local foreground = theme.gray_800

	vim.api.nvim_set_hl(0, "Indentation", { fg = bg_shades_01 })
	vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = bg_shades_02 })

	-- 👉 Headings
	vim.api.nvim_set_hl(0, "H1", { fg = bg_shades_01, bg = bg_shades_17, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH1", { fg = bg_shades_17, bg = bg_shades_01, bold = true })
	vim.api.nvim_set_hl(0, "H2", { fg = bg_shades_01, bg = bg_shades_12, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH2", { fg = bg_shades_12, bg = bg_shades_01, bold = true })
	vim.api.nvim_set_hl(0, "H3", { fg = bg_shades_01, bg = bg_shades_07, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH3", { fg = bg_shades_07, bg = bg_shades_01, bold = true })

	local highlights = {
		--     Added = { fg = "" , bg = ""}
		-- @diff.plus

		Boolean = { fg = foreground },
		-- @boolean

		Character = { fg = bg_shades_10 },
		-- @character
		-- @character.special

		-- Changed = { fg = "" , bg = ""}
		-- @diff.delta

		--     ColorColumn = { fg = "" , bg = ""}

		Comment = { fg = bg_shades_05, italic = true },
		-- @comment
		-- @comment.error
		-- @comment.warning
		-- @comment.note
		-- @comment.todo
		-- DiagnosticUnnecessary

		--     ComplMatchIns = { fg = "" , bg = ""}

		Conceal = { fg = background, bg = background },

		Constant = { fg = bg_shades_07 },
		-- @constant
		-- @constant.builtin
		-- Character
		-- Number
		-- Boolean
		-- Float

		CurSearch = { fg = background, bg = bg_shades_18 },
		-- IncSearch

		Cursor = { bg = bg_shades_02 },
		-- lCursor
		-- CursorIM

		CursorColumn = { fg = bg_shades_02 },

		CursorLine = { bg = bg_shades_01 },

		CursorLineNr = { bg = bg_shades_01 },

		CursorLineFold = { bg = bg_shades_02 },

		--     CursorLineSign = { fg = "" , bg = ""}

		--     DiffAdd = { fg = "" , bg = ""}

		--     DiffChange = { fg = "" , bg = ""}

		--     DiffDelete = { fg = "" , bg = ""}

		--     DiffText = { fg = "" , bg = ""}

		--     DiagnosticDeprecated = { fg = "" , bg = ""}
		--     -- @lsp.mod.deprecated

		--     DiagnosticError = { fg = "" , bg = ""}
		--     -- DiagnosticFloatingError
		--     -- DiagnosticVirtualTextError
		--     -- DiagnosticVirtualLinesError
		--     -- DiagnosticSignError
		--     -- @comment.error

		--     DiagnosticHint = { fg = "" , bg = ""}
		--     -- DiagnosticFloatingHint
		--     -- DiagnosticVirtualTextHint
		--     -- DiagnosticVirtualLinesHint
		--     -- DiagnosticSignHint

		--     DiagnosticInfo = { fg = "" , bg = ""}
		--     -- DiagnosticFloatingInfo
		--     -- DiagnosticVirtualTextInfo
		--     -- DiagnosticVirtualLinesInfo
		--     -- DiagnosticSignInfo
		--     -- @comment.note

		--     DiagnosticOk = { fg = "" , bg = ""}
		--     -- DiagnosticFloatingOk
		--     -- DiagnosticVirtualTextOk
		--     -- DiagnosticVirtualLinesOk
		--     -- DiagnosticSignOk

		--     DiagnosticUnderlineError = { fg = "" , bg = ""}

		--     DiagnosticUnderlineHint = { fg = "" , bg = ""}

		--     DiagnosticUnderlineInfo = { fg = "" , bg = ""}

		--     DiagnosticUnderlineOk = { fg = "" , bg = ""}

		--     DiagnosticUnderlineWarn = { fg = "" , bg = ""}

		--     DiagnosticWarn = { fg = "" , bg = ""}
		--     -- DiagnosticFloatingWarn
		--     -- DiagnosticVirtualTextWarn
		--     -- DiagnosticVirtualLinesWarn
		--     -- DiagnosticSignWarn
		--     -- @comment.warning

		--     Directory = { fg = "" , bg = ""}

		Delimiter = { fg = bg_shades_09 },
		-- @punctuation
		-- NvimParenthesis
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

		--     Error = { fg = "" , bg = ""}
		--     -- NvimInvalid
		--     -- NvimInvalidAssignment
		--     -- NvimInvalidPlainAssignment
		--     -- NvimInvalidAugmentedAssignment
		--     -- NvimInvalidAssignmentWithAddition
		--     -- NvimInvalidAssignmentWithSubtraction
		--     -- NvimInvalidAssignmentWithConcatenation
		--     -- NvimInvalidOperator
		--     -- NvimInvalidUnaryOperator
		--     -- NvimInvalidUnaryPlus
		--     -- NvimInvalidUnaryMinus
		--     -- NvimInvalidNot
		--     -- NvimInvalidBinaryOperator
		--     -- NvimInvalidComparison
		--     -- NvimInvalidComparisonModifier
		--     -- NvimInvalidBinaryPlus
		--     -- NvimInvalidBinaryMinus
		--     -- NvimInvalidConcat
		--     -- NvimInvalidConcatOrSubscript
		--     -- NvimInvalidOr
		--     -- NvimInvalidAnd
		--     -- NvimInvalidMultiplication
		--     -- NvimInvalidDivision
		--     -- NvimInvalidMod
		--     -- NvimInvalidTernary
		--     -- NvimInvalidTernaryColon
		--     -- NvimInvalidDelimiter
		--     -- NvimInvalidParenthesis
		--     -- NvimInvalidLambda
		--     -- NvimInvalidNestingParenthesis
		--     -- NvimInvalidCallingParenthesis
		--     -- NvimInvalidSubscript
		--     -- NvimInvalidSubscriptBracket
		--     -- NvimInvalidSubscriptColon
		--     -- NvimInvalidCurly
		--     -- NvimInvalidContainer
		--     -- NvimInvalidDict
		--     -- NvimInvalidList
		--     -- NvimInvalidValue
		--     -- NvimInvalidIdentifier
		--     -- NvimInvalidIdentifierScope
		--     -- NvimInvalidIdentifierScopeDelimiter
		--     -- NvimInvalidIdentifierName
		--     -- NvimInvalidIdentifierKey
		--     -- NvimInvalidColon
		--     -- NvimInvalidComma
		--     -- NvimInvalidArrow
		--     -- NvimInvalidRegister
		--     -- NvimInvalidNumber
		--     -- NvimInvalidFloat
		--     -- NvimInvalidNumberPrefix
		--     -- NvimInvalidOptionSigil
		--     -- NvimInvalidOptionName
		--     -- NvimInvalidOptionScope
		--     -- NvimInvalidOptionScopeDelimiter
		--     -- NvimInvalidEnvironmentSigil
		--     -- NvimInvalidEnvironmentName
		--     -- NvimInvalidString
		--     -- NvimInvalidStringBody
		--     -- NvimInvalidStringQuote
		--     -- NvimInvalidStringSpecial
		--     -- NvimInvalidSingleQuote
		--     -- NvimInvalidSingleQuotedBody
		--     -- NvimInvalidSingleQuotedQuote
		--     -- NvimInvalidDoubleQuote
		--     -- NvimInvalidDoubleQuotedBody
		--     -- NvimInvalidDoubleQuotedEscape
		--     -- NvimInvalidDoubleQuotedUnknownEscape
		--     -- NvimInvalidFigureBrace
		--     -- NvimInvalidSpacing
		--     -- NvimInternalError

		--     ErrorMsg = { fg = "" , bg = ""}

		Float = { fg = bg_shades_08 },
		-- @number.float
		-- NvimFloat

		FloatBorder = { fg = bg_shades_10, bg = bg_shades_02 },

		FloatFooter = { fg = bg_shades_12, bg = bg_shades_02 },

		--     FloatShadow = { fg = "" , bg = ""}

		--     FloatShadowThrough = { fg = "" , bg = ""}

		FloatTitle = { fg = bg_shades_14, bold = true },

		--     FoldColumn = { fg = "" , bg = ""}

		Folded = { fg = bg_shades_12, bg = bg_shades_02 },

		Function = { fg = foreground },
		-- @function
		["@function.builtin"] = { fg = foreground, bold = true },

		Identifier = { fg = bg_shades_12, bold = true },
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

		--     Ignore = { fg = "" , bg = ""}

		Keyword = { fg = foreground, bold = true },
		-- @keyword

		--     Label = { fg = "" , bg = ""}
		--     -- @label

		LineNr = { fg = bg_shades_03 },
		-- LineNrAbove
		-- LineNrBelow

		--     LspCodeLens = { fg = "" , bg = ""}
		--     -- LspCodeLensSeparator

		--     LspInlayHint = { fg = "" , bg = ""}

		LspReferenceRead = { fg = bg_shades_14, bg = bg_shades_01 },

		--     LspReferenceTarget = { fg = "" , bg = ""}

		LspReferenceText = { fg = bg_shades_14, bg = bg_shades_01 },
		-- LspReferenceRead
		-- LspReferenceWrite
		-- Visual
		-- VisualNOS
		-- SnippetTabstop

		LspReferenceWrite = { fg = bg_shades_14, bg = background },

		--     LspSignatureActiveParameter = { fg = "" , bg = ""}

		--     Macro = { fg = "" , bg = ""}
		--     -- @attribute
		--     -- @attribute.builtin

		MatchParen = { fg = bg_shades_01, bg = bg_shades_07, bold = true },

		--     ModeMsg = { fg = "" , bg = ""}

		--     MoreMsg = { fg = "" , bg = ""}

		--     MsgArea = { fg = "" , bg = ""}

		--     MsgSeparator = { fg = "" , bg = ""}

		NonText = { fg = foreground },
		-- SpecialKey
		-- EndOfBuffer
		-- Whitespace
		-- LspCodeLens
		-- LspInlayHint

		Normal = { fg = foreground, bg = background },
		-- Ignore
		-- @diff
		-- NvimSpacing

		NormalFloat = { fg = bg_shades_12, bg = bg_shades_02 },

		NormalNC = { bg = background },

		Number = { fg = foreground },
		-- @number
		-- @number.float
		-- NvimNumber

		--     NvimAssignment = { fg = "" , bg = ""}
		--     -- NvimPlainAssignment
		--     -- NvimAugmentedAssignment
		--     -- NvimAssignmentWithAddition
		--     -- NvimAssignmentWithSubtraction
		--     -- NvimAssignmentWithConcatenation

		--     NvimDoubleQuotedUnknownEscape = { fg = "" , bg = ""}

		--     NvimEnvironmentSigil = { fg = "" , bg = ""}

		--     NvimFigureBrace = { fg = "" , bg = ""}

		--     NvimInternalError = { fg = "" , bg = ""}
		--     -- NvimSingleQuotedUnknownEscape
		--     -- NvimInvalidSingleQuotedUnknownEscape

		--     NvimNumberPrefix = { fg = "" , bg = ""}

		--     NvimOperator = { fg = "" , bg = ""}
		--     -- NvimUnaryOperator
		--     -- NvimUnaryPlus
		--     -- NvimUnaryMinus
		--     -- NvimNot
		--     -- NvimBinaryOperator
		--     -- NvimComparison
		--     -- NvimComparisonModifier
		--     -- NvimBinaryPlus
		--     -- NvimBinaryMinus
		--     -- NvimConcat
		--     -- NvimConcatOrSubscript
		--     -- NvimOr
		--     -- NvimAnd
		--     -- NvimMultiplication
		--     -- NvimDivision
		--     -- NvimMod
		--     -- NvimTernary
		--     -- NvimTernaryColon

		--     NvimOptionSigil = { fg = "" , bg = ""}

		--     NvimRegister = { fg = "" , bg = ""}

		--     NvimSingleQuotedQuote = { fg = "" , bg = ""}

		--     NvimString = { fg = "" , bg = ""}
		--     -- NvimStringBody
		--     -- NvimStringQuote
		--     -- NvimSingleQuote
		--     -- NvimSingleQuotedBody
		--     -- NvimDoubleQuote
		--     -- NvimDoubleQuotedBody

		--     NvimStringSpecial = { fg = "" , bg = ""}
		--     -- NvimDoubleQuotedEscape

		Operator = { fg = bg_shades_16 },
		-- @operator
		-- NvimAssignment
		-- NvimOperator

		Pmenu = { fg = bg_shades_14, bg = bg_shades_01 },
		-- PmenuKind
		-- PmenuExtra
		-- PmenuSbar

		--     PmenuExtraSel = { fg = "" , bg = ""}

		--     PmenuKindSel = { fg = "" , bg = ""}

		--     PmenuMatch = { fg = "" , bg = ""}

		--     PmenuMatchSel = { fg = "" , bg = ""}

		PmenuSel = { fg = background, bg = bg_shades_10 },
		-- PmenuKindSel
		-- PmenuExtraSel
		-- WildMenu

		--     PmenuThumb = { fg = "" , bg = ""}

		--     PreCondit = { fg = "" , bg = ""}

		--     PreProc = { fg = "" , bg = ""}
		--     -- Include
		--     -- Define
		--     -- Macro
		--     -- PreCondit

		--     Question = { fg = "" , bg = ""}

		--     QuickFixLine = { fg = "" , bg = ""}

		--     RedrawDebugClear = { fg = "" , bg = ""}

		--     RedrawDebugComposed = { fg = "" , bg = ""}

		--     RedrawDebugNormal = { fg = "" , bg = ""}

		--     RedrawDebugRecompose = { fg = "" , bg = ""}

		--     Removed = { fg = "" , bg = ""}
		--     -- @diff.minus

		--     Repeat = { fg = "" , bg = ""}

		Search = { fg = bg_shades_16, bg = bg_shades_06 },
		-- Substitute

		--     SignColumn = { fg = "" , bg = ""}

		--     SnippetTabstop = { fg = "" , bg = ""}

		Special = { fg = bg_shades_08 },
		-- @module.builtin
		-- @string.regexp
		-- @string.special
		-- @string.escape
		-- constant.builtin
		-- @type.builtin
		-- @attribute.builtin
		-- @function.builtin
		-- @constructor
		-- @punctuation.special
		-- @markup
		-- @tag.builtin
		-- SpecialChar
		-- SpecialComment
		-- Debug
		-- Tag
		-- NvimRegister
		-- NvimStringSpecial

		SpecialChar = { fg = bg_shades_11 },
		-- @string.special
		-- @string.escape
		-- @character.special
		-- NvimStringSpecial
		["@variable"] = { link = "SpecialChar" },
		["@.builtin"] = { link = "SpecialChar" },
		["@variable.parameter.builtin"] = { link = "SpecialChar" },

		--     SpecialComment = { fg = "" , bg = ""}

		--     SpecialKey = { fg = "" , bg = ""}

		--     SpellBad = { fg = "" , bg = ""}

		--     SpellCap = { fg = "" , bg = ""}

		--     SpellLocal = { fg = "" , bg = ""}

		--     SpellRare = { fg = "" , bg = ""}

		Statement = { fg = bg_shades_10 },
		-- Conditional
		-- Repeat
		-- Label
		-- Keyword
		-- Exception

		StatusLine = { fg = foreground, bg = background },
		-- MsgSeparator

		--     StatusLineNC = { fg = "" , bg = ""}
		--     -- TabLine

		--     StatusLineTerm = { fg = "" , bg = ""}

		--     StatusLineTermNC = { fg = "" , bg = ""}

		--     StorageClass = { fg = "" , bg = ""}

		String = { fg = bg_shades_09 },
		-- @string
		-- @string.regexp
		-- @string.special
		-- @string.escape
		-- @string.special.url
		-- NvimString

		Structure = { fg = bg_shades_11 },
		-- @module
		-- @module.builtin

		--     Substitute = { fg = "" , bg = ""}

		--     TabLine = { fg = "" , bg = ""}

		--     TabLineFill = { fg = "" , bg = ""}

		--     TabLineSel = { fg = "" , bg = ""}

		Tag = { fg = bg_shades_16 },
		-- @tag
		-- @tag.builtin

		--     TermCursor = { fg = "" , bg = ""}

		Title = { fg = bg_shades_16, bold = true },
		-- @markup.heading
		-- FloatTitle
		-- FloatFooter

		Todo = { fg = bg_shades_16, bg = bg_shades_02 },
		-- @comment.todo

		Type = { fg = bg_shades_08 },
		-- @type
		-- @type.builtin
		-- StorageClass
		-- Typedef
		-- NvimNumberPrefix
		-- NvimOptionSigil
		-- NvimEnvironmentSigil

		Typedef = { fg = bg_shades_10 },

		Underlined = { fg = bg_shades_10, underline = true },
		-- @string.special.url
		-- @markup.link

		--     VertSplit = { fg = "" , bg = ""}

		Visual = { fg = foreground, bg = bg_shades_04 },
		-- LspReferenceText
		-- LspSignatureActiveParameter
		-- SnippetTabstop
		-- VisualNOS

		--     VisualNC = { fg = "" , bg = ""}

		--     VisualNOS = { fg = "" , bg = ""}

		--     WarningMsg = { fg = "" , bg = ""}

		--     Whitespace = { fg = "" , bg = ""}

		--     WildMenu = { fg = "" , bg = ""}

		--     WinBar = { fg = "" , bg = ""}

		--     WinBarNC = { fg = "" , bg = ""}

		--     WinSeparator = { fg = "" , bg = ""}
		--     -- VertSplit

		--     @diff = { fg = "" , bg = ""}

		--     @lsp = { fg = "" , bg = ""}

		["@markup"] = { fg = foreground },
		["@markup.strong"] = { fg = foreground, bold = true },
		["@markup.italic"] = { fg = foreground, italic = true },
		["@markup.underline"] = { fg = foreground, underline = true },
		["@markup.strikethrough"] = { fg = foreground, strikethrough = true },
		["@markup.heading"] = { fg = foreground, bold = true },
		["@markup.link"] = { fg = foreground, underline = true },

		--     @markup.heading.1.delimiter.vimdoc = { fg = "" , bg = ""}

		--     @markup.heading.2.delimiter.vimdoc = { fg = "" , bg = ""}
	}

	-- Set highlights using API
	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

return theme
