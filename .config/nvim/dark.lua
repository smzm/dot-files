local theme = {}

local colors = {
	white = "#ffffff",
	gray_1000 = "#FAFAFA",
	gray_950 = "#EAEAEA",
	gray_900 = "#E1E1E1",
	gray_850 = "#DEDEDE",
	gray_800 = "#D3D3D3",
	gray_750 = "#C9C9C9",
	gray_700 = "#BFBFBF",
	gray_650 = "#A6A6A6",
	gray_600 = "#999999",
	gray_550 = "#8C8C8C",
	gray_500 = "#737373",
	gray_450 = "#666666",
	gray_400 = "#595959",
	gray_350 = "#4D4D4D",
	gray_300 = "#404040",
	gray_250 = "#333333",
	gray_200 = "#262626",
	gray_150 = "#1A1A1A",
	gray_100 = "#0D0D0D",
	gray_050 = "#090909",
	gray_000 = "#040404",
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

	local background = colors.gray_050
	local foreground = colors.gray_950

    vim.api.nvim_set_hl(0, "Indentation", { fg = colors.gray_150 })
	vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = colors.gray_200 })

	-- 👉 Headings
	vim.api.nvim_set_hl(0, "H1", { fg = colors.gray_100, bg = colors.gray_900, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH1", { fg = colors.gray_900, bg = colors.gray_100, bold = true })
	vim.api.nvim_set_hl(0, "H2", { fg = colors.gray_100, bg = colors.gray_700, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH2", { fg = colors.gray_700, bg = colors.gray_100, bold = true })
	vim.api.nvim_set_hl(0, "H3", { fg = colors.gray_100, bg = colors.gray_500, bold = true })
	vim.api.nvim_set_hl(0, "ReversedH3", { fg = colors.gray_500, bg = colors.gray_100, bold = true })

    local highlights = {
    --     Added = { fg = "" , bg = ""}
        -- @diff.plus

        Boolean = { fg = colors.gray_700 },
        -- @boolean

        Character = { fg = colors.gray_700 },
        -- @character
        -- @character.special

        -- Changed = { fg = "" , bg = ""}
        -- @diff.delta

    --     ColorColumn = { fg = "" , bg = ""}

        Comment = { fg = colors.gray_350 },
        -- @comment
        -- @comment.error
        -- @comment.warning
        -- @comment.note
        -- @comment.todo
        -- DiagnosticUnnecessary

    --     ComplMatchIns = { fg = "" , bg = ""}

        Conceal = { fg = background , bg = background},

        Constant = { fg = colors.gray_900 },
        -- @constant
        -- @constant.builtin
        -- Character
        -- Number
        -- Boolean
        -- Float

    --     CurSearch = { fg = "" , bg = ""}
    --     -- IncSearch

        Cursor = { bg = colors.gray_150 },
        -- lCursor
        -- CursorIM

        CursorColumn = { fg = colors.gray_200 },

        CursorLine = { bg = colors.gray_150 },

        CursorLineNr = { bg = colors.gray_150},

        CursorLineFold = { bg = colors.gray_400 }, 

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

        Delimiter = { fg = colors.gray_750 },
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

    --     EndOfBuffer = { fg = "" , bg = ""}

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

        Float = { fg = colors.gray_900},
        -- @number.float
        -- NvimFloat

        FloatBorder = { fg = colors.gray_300, bg = colors.gray_100 },

        FloatFooter = { fg = colors.gray_300, bg = colors.gray_100 },

    --     FloatShadow = { fg = "" , bg = ""}

    --     FloatShadowThrough = { fg = "" , bg = ""}

        FloatTitle = { fg = colors.gray_700, bg = colors.gray_100, bold = true },

    --     FoldColumn = { fg = "" , bg = ""}

        Folded = { fg = colors.gray_500, bg = colors.gray_200 },

        Function = { fg = foreground },
        -- @function
        ["@function.builtin"] = { fg = foreground, bold = true },

        Identifier = { fg = colors.gray_700 },
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

        Keyword = {fg = foreground, bold = true },
        -- @keyword

    --     Label = { fg = "" , bg = ""}
    --     -- @label

        LineNr = { fg = colors.gray_300 },
        -- LineNrAbove
        -- LineNrBelow

    --     LspCodeLens = { fg = "" , bg = ""}
    --     -- LspCodeLensSeparator

    --     LspInlayHint = { fg = "" , bg = ""}

        LspReferenceRead = { fg = colors.gray_700, bg = colors.gray_100 },

    --     LspReferenceTarget = { fg = "" , bg = ""}

        LspReferenceText = { fg = colors.gray_700, bg = colors.gray_100 },
        -- LspReferenceRead
        -- LspReferenceWrite
        -- Visual
        -- VisualNOS
        -- SnippetTabstop

        LspReferenceWrite = { fg = colors.gray_700, bg = background },

    --     LspSignatureActiveParameter = { fg = "" , bg = ""}

    --     Macro = { fg = "" , bg = ""}
    --     -- @attribute
    --     -- @attribute.builtin

        MatchParen = { fg = colors.gray_100, bg = colors.gray_750, bold = true },

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

        Normal = { fg = foreground , bg = background },
        -- Ignore
        -- @diff
        -- NvimSpacing

        NormalFloat = { fg = colors.gray_600, bg = colors.gray_100 },

        NormalNC = { bg = colors.gray_100},

        Number = { fg = colors.gray_900 },
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

        Operator = { fg = colors.gray_700 },
        -- @operator
        -- NvimAssignment
        -- NvimOperator

        Pmenu = { fg = colors.gray_700, bg = colors.gray_100 },
        -- PmenuKind
        -- PmenuExtra
        -- PmenuSbar

    --     PmenuExtraSel = { fg = "" , bg = ""}

    --     PmenuKindSel = { fg = "" , bg = ""}

    --     PmenuMatch = { fg = "" , bg = ""}

    --     PmenuMatchSel = { fg = "" , bg = ""}

        PmenuSel = {  fg = background, bg = colors.gray_200 },
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

        Search = { fg = colors.gray_050, bg = colors.gray_300 },
        -- Substitute

    --     SignColumn = { fg = "" , bg = ""}

    --     SnippetTabstop = { fg = "" , bg = ""}

        Special = { fg = colors.gray_450},
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
        
        
        SpecialChar = { fg = colors.gray_650 },
        -- @string.special
        -- @string.escape
        -- @character.special
        -- NvimStringSpecial
        ["@variable"] = { link = "SpecialChar" },
        ["@variable.builtin"] = { link = "SpecialChar" },
        ["@variable.parameter.builtin"] = { link = "SpecialChar" },

    --     SpecialComment = { fg = "" , bg = ""}

    --     SpecialKey = { fg = "" , bg = ""}

    --     SpellBad = { fg = "" , bg = ""}

    --     SpellCap = { fg = "" , bg = ""}

    --     SpellLocal = { fg = "" , bg = ""}

    --     SpellRare = { fg = "" , bg = ""}

        Statement = { fg = colors.gray_550 },
        -- Conditional
        -- Repeat
        -- Label
        -- Keyword
        -- Exception

    --     StatusLine = { fg = "" , bg = ""}
    --     -- MsgSeparator

    --     StatusLineNC = { fg = "" , bg = ""}
    --     -- TabLine

    --     StatusLineTerm = { fg = "" , bg = ""}

    --     StatusLineTermNC = { fg = "" , bg = ""}

    --     StorageClass = { fg = "" , bg = ""}

        String = { fg = colors.gray_550 },
        -- @string
        -- @string.regexp
        -- @string.special
        -- @string.escape
        -- @string.special.url
        -- NvimString

        Structure = { fg = colors.gray_450 },
        -- @module
        -- @module.builtin

    --     Substitute = { fg = "" , bg = ""}

    --     TabLine = { fg = "" , bg = ""}

    --     TabLineFill = { fg = "" , bg = ""}

    --     TabLineSel = { fg = "" , bg = ""}

        Tag = { fg = colors.gray_550 },
        -- @tag
        -- @tag.builtin

    --     TermCursor = { fg = "" , bg = ""}

        Title = { fg = colors.gray_800, bold = true },
        -- @markup.heading
        -- FloatTitle
        -- FloatFooter

        Todo = { fg = colors.gray_800 , bg = colors.gray_200 },
        -- @comment.todo

        Type = { fg = colors.gray_450 },
        -- @type
        -- @type.builtin
        -- StorageClass
        -- Typedef
        -- NvimNumberPrefix
        -- NvimOptionSigil
        -- NvimEnvironmentSigil

        Typedef = { fg = colors.gray_500 },

        Underlined = { fg = colors.gray_450, underline = true },
        -- @string.special.url
        -- @markup.link

    --     VertSplit = { fg = "" , bg = ""}

        Visual = {fg = background, bg = colors.gray_450 },
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

theme.colors = colors

return theme

