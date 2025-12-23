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
	gray_950 = "#0D0D0D",
	gray_1000 = "#090909",
	gray_1050 = "#070707",
	black = "#000000",
	red = "#FF0000",
	orange = "#ffc799",
	green = "#99ffe4",
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
	local shade_01, shade_02, shade_03, shade_04, shade_05
	local shade_06, shade_07, shade_08, shade_09, shade_10
	local shade_11, shade_12, shade_13, shade_14, shade_15
	local shade_16, shade_17, shade_18, shade_19, shade_20
	local black = colors.black
	local red = colors.red
	local orange = colors.orange
	local green = colors.green

	background = colors.gray_1050 -- Darkest background
	shade_01 = colors.gray_1000
	shade_02 = colors.gray_950
	shade_03 = colors.gray_900
	shade_04 = colors.gray_850
	shade_05 = colors.gray_800
	shade_06 = colors.gray_750
	shade_07 = colors.gray_700
	shade_08 = colors.gray_650
	shade_09 = colors.gray_600
	shade_10 = colors.gray_550
	shade_11 = colors.gray_500
	shade_12 = colors.gray_450
	shade_13 = colors.gray_400
	shade_14 = colors.gray_350
	shade_15 = colors.gray_300
	shade_16 = colors.gray_250
	shade_17 = colors.gray_200
	shade_18 = colors.gray_150
	shade_19 = colors.gray_100
	shade_20 = colors.gray_050 -- Lightest shade
	foreground = colors.gray_400

	vim.api.nvim_set_hl(0, "Indentation", { fg = shade_04 })
	vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = shade_06 })

	-- 👉 Headings
	-- vim.api.nvim_set_hl(0, "H1", { fg = bg_shades_08, bg = black, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH1", { fg = shade_17, bg = shade_01, bold = true })
	vim.api.nvim_set_hl(0, "H2", { fg = shade_01, bg = shade_13, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH2", { fg = shade_12, bg = shade_01, bold = true })
	vim.api.nvim_set_hl(0, "H3", { fg = shade_02, bg = shade_07, bold = true })
	vim.api.nvim_set_hl(0, "H4", { fg = shade_10, bg = shade_03, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH3", { fg = shade_07, bg = shade_01, bold = true })
	vim.api.nvim_set_hl(0, "CodeBlock", { bg = colors.black })
	vim.api.nvim_set_hl(0, "CodeBorder", { fg = shade_06, bg = colors.black })
	vim.api.nvim_set_hl(0, "InlineCodeBlock", { fg = shade_11, bg = shade_04 })

	local highlights = {
		-- Added = { fg = "" , bg = ""}
		-- @diff.plus

		Boolean = { fg = foreground },
		-- @boolean

		Character = { fg = shade_10 },
		-- @character
		-- @character.special
		-- Changed = { fg = "" , bg = ""}
		-- @diff.delta
		-- ColorColumn = { fg = "" , bg = ""}

		Comment = { fg = shade_06, italic = true },
		-- @comment
		-- @comment.error
		-- @comment.warning
		-- @comment.note
		-- @comment.todo
		-- ComplMatchIns = { fg = "" , bg = ""}

		DiagnosticUnnecessary = { fg = shade_08 },

		Conceal = { fg = background, bg = background },

		Constant = { fg = shade_07 },
		-- @constant
		-- @constant.builtin
		-- Character
		-- Number
		-- Boolean
		-- Float

		CurSearch = { fg = background, bg = shade_18 },
		-- 6ncSearch

		Cursor = { bg = shade_02 },
		-- lCursor
		-- CursorIM

		CursorColumn = { fg = shade_02 },

		CursorLine = { bg = shade_02 },

		CursorLineNr = { bg = shade_02 },

		CursorLineFold = { bg = shade_02 },
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
		--  DiagnosticVirtualTextHint
		--  DiagnosticVirtualLinesHint
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
		--  DiagnosticUnderlineError = { fg = "" , bg = ""}
		--  DiagnosticUnderlineHint = { fg = "" , bg = ""}
		--  DiagnosticUnderlineInfo = { fg = "" , bg = ""}
		--  DiagnosticUnderlineOk = { fg = "" , bg = ""}
		--  DiagnosticUnderlineWarn = { fg = "" , bg = ""}
		--  DiagnosticWarn = { fg = "" , bg = ""}
		--  DiagnosticFloatingWarn
		--  DiagnosticVirtualTextWarn
		--  DiagnosticVirtualLinesWarn
		--  DiagnosticSignWarn
		--  @comment.warning
		--  Directory = { fg = "" , bg = ""}

		DiagnosticUnderlineInfo = { fg = nil },
		DiagnosticUnderlineWarn = { fg = nil },
		DiagnosticUnderlineHint = { fg = nil },

		Delimiter = { fg = shade_11 },
		-- @punctuation
		NvimParenthesis = { fg = shade_12 },
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

		Float = { fg = shade_08 },
		-- @number.float
		-- NvimFloat

		FloatBorder = { fg = shade_06 },

		FloatFooter = { fg = shade_12, bg = shade_02 },

		-- FloatShadow = { fg = "" , bg = ""}
		-- FloatShadowThrough = { fg = "" , bg = ""}

		FloatTitle = { fg = shade_14, bold = true },

		-- FoldColumn = { fg = "" , bg = ""}

		Folded = { fg = shade_12, bg = shade_02 },

		Function = { fg = shade_16 },
		["@function.method"] = { fg = shade_14 },
		["@function.builtin"] = { fg = shade_14, bold = true },

		Identifier = { fg = shade_12 },
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

		Keyword = { fg = shade_13, bold = true },
		-- @keyword
		Label = { fg = shade_13 },
		-- @label

		LineNr = { fg = shade_05 },
		-- LineNrAbove
		-- LineNrBelow
		-- LspCodeLens = { fg = "" , bg = ""}
		-- LspCodeLensSeparator
		-- LspInlayHint = { fg = "" , bg = ""}

		LspReferenceRead = { fg = shade_16, bg = "NONE" },
		-- LspReferenceTarget = { fg = "" , bg = ""}

		LspReferenceText = { fg = "NONE", bg = "NONE" },
		-- Visual
		-- VisualNOS
		-- SnippetTabstop

		LspReferenceWrite = { fg = shade_16, bg = "NONE", bold = true },
		-- LspSignatureActiveParameter = { fg = "" , bg = ""}
		-- @attribute
		-- @attribute.builtin

		MatchParen = { fg = shade_01, bg = shade_09, bold = true },

		-- ModeMsg = { fg = "" , bg = ""}
		-- MoreMsg = { fg = "" , bg = ""}
		-- MsgArea = { fg = "" , bg = ""}
		-- MsgSeparator = { fg = "" , bg = ""}

		NonText = { fg = shade_06, bg = shade_02 },
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

		NormalFloat = { bg = shade_02 },

		NormalNC = { bg = background },

		Number = { fg = foreground },
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

		Operator = { fg = shade_14 },
		-- @operator
		-- NvimAssignment
		-- NvimOperator

		Pmenu = { fg = shade_08, bg = shade_02 },
		-- PmenuKind
		-- PmenuSbar
		-- PmenuExtraSel = { fg = "" , bg = ""}
		-- PmenuKindSel = { fg = "" , bg = ""}
		-- PmenuMatch = { fg = "" , bg = ""}
		-- PmenuMatchSel = { fg = "" , bg = ""}
		PmenuExtra = { fg = shade_08 },
		PmenuThumb = { fg = shade_10, bg = shade_04 },

		PmenuSel = { fg = shade_14, bg = shade_06 },
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

		Search = { fg = shade_16, bg = shade_06 },
		-- Substitute
		-- SignColumn = { fg = "" , bg = ""}
		-- SnippetTabstop = { fg = "" , bg = ""}

		Special = { fg = shade_14 },
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

		SpecialChar = { fg = shade_09 },
		-- @string.special
		-- @string.escape
		-- @character.special
		-- NvimStringSpecial
		["@variable"] = { link = "SpecialChar" },
		["@variable.builtin"] = { link = "SpecialChar" },
		["@variable.parameter"] = { fg = shade_10 },
		-- SpecialComment = { fg = "" , bg = ""}
		-- SpecialKey = { fg = "" , bg = ""}
		-- SpellBad = { fg = "" , bg = ""}
		-- SpellCap = { fg = "" , bg = ""}
		-- SpellLocal = { fg = "" , bg = ""}
		-- SpellRare = { fg = "" , bg = ""}

		Statement = { fg = shade_14 },
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

		String = { fg = shade_08 },
		-- @string
		-- @string.regexp
		-- @string.special
		-- @string.escape
		-- @string.special.url
		-- NvimString

		Structure = { fg = shade_08 },
		-- @module
		-- @module.builtin
		-- Substitute = { fg = "" , bg = ""}
		-- TabLine = { fg = "" , bg = ""}
		-- TabLineFill = { fg = "" , bg = ""}
		-- TabLineSel = { fg = "" , bg = ""}

		Tag = { fg = shade_14 },
		-- @tag
		-- @tag.builtin
		TermCursor = { fg = shade_10, bg = shade_01 },

		Title = { fg = shade_14, bold = true },
		-- @markup.heading
		-- FloatTitle
		-- FloatFooter

		Todo = { fg = shade_16, bg = shade_02 },
		-- @comment.todo

		Type = { fg = shade_10, bold = true },
		-- @type
		-- @type.builtin
		-- StorageClass
		-- Typedef
		-- NvimNumberPrefix
		-- NvimOptionSigil
		-- NvimEnvironmentSigil

		Typedef = { fg = shade_08 },

		Underlined = { fg = shade_10, underline = true },
		-- @string.special.url
		-- @markup.link
		-- VertSplit = { fg = "" , bg = ""}

		Visual = { fg = foreground, bg = shade_06 },
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
		WinSeparator = { fg = shade_06, bg = "NONE" },

		["@markup"] = { fg = foreground },
		["@markup.strong"] = { fg = foreground, bold = true },
		["@markup.italic"] = { fg = foreground, italic = true },
		["@markup.underline"] = { fg = foreground, underline = true },
		["@markup.strikethrough"] = { fg = shade_08, strikethrough = true },
		["@markup.heading"] = { fg = foreground, bold = true },
		["@markup.link"] = { fg = shade_09 },
		["@markup.quote"] = { fg = shade_09, bg = shade_03 },

		-- @markup.heading.1.delimiter.vimdoc = { fg = "" , bg = ""}
		-- @markup.heading.2.delimiter.vimdoc = { fg = "" , bg = ""}

		SnacksStatusColumnMark = { fg = shade_20 },

		["@lsp.mod.definition"] = { fg = shade_09 },
		["@lsp.type.variable"] = { fg = shade_11 },
	}

	-- Set highlights using API
	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

return theme
