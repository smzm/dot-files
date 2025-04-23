local opt = vim.opt
local g = vim.g

-- to displaying diagnostic signs (like errors or warnings)
vim.o.signcolumn = "yes"

-- Disable the status line at bottom
vim.o.laststatus = 0

-- Cursor highlighting
opt.cursorline = true
opt.cursorcolumn = false

-- Pane splitting : add separator line
opt.splitright = true
opt.splitbelow = true

-- Searching
opt.smartcase = true
opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true

-- Auto indent
opt.autoindent = true
opt.shiftround = true
opt.breakindent = true

-- Make terminal support truecolor
opt.termguicolors = true
opt.background = "dark"

-- Make neovim use the system clipboard
opt.clipboard = "unnamedplus"

-- Disable old vim status
opt.showmode = false
opt.showcmd = false

-- Set relative line numbers
opt.number = true
opt.relativenumber = false
opt.numberwidth = 4

-- <Tab> configuration
opt.expandtab = true
opt.smarttab = true
opt.smartindent = true
opt.shiftwidth = 2
opt.tabstop = 2

-- Code folding : all folds to be open by default
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1"

-- Decrease waiting time in key mapped sequences
opt.timeoutlen = 500
opt.updatetime = 200

-- backspace
-- allow backspace on indent, end of line or insert mode start position
opt.backspace = "indent,eol,start"

-- Disable swapfile on persistant undo
opt.swapfile = false

-- Enable persistent undo
opt.undofile = true

-- Configures completion behavior, showing a menu even when there is only one match and not selecting any item automatically.
opt.completeopt = { "menu", "noselect" }

-- Always show tab line at the top
-- opt.showtabline = 2

-- Scrolloff : Maintain 5 line above/below and left/right
opt.scrolloff = 5
opt.sidescrolloff = 5

-- Disable text wrapping
opt.wrap = true

-- Fill chars
opt.fillchars = [[vert:|,horiz:-,eob: ]]

-- Enable lazy redraw for performance
-- opt.lazyredraw = true

-- Disable continuation comments in next line
vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")
