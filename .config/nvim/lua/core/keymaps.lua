local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

-- use jk to exit insert mode
map("i", "jk", "<ESC>", opts)
map("i", "<C-k>", "<Up>", opts)
map("i", "<C-j>", "<Down>", opts)
map("i", "<C-l>", "<Right>", opts)
map("i", "<C-h>", "<Left>", opts)

-- better up/down in wrapped line
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- disable hlsearch
map("n", "<esc><esc>", ":nohlsearch<CR>", { silent = true })

-- delete single character without copying into register
map("n", "x", '"_x', opts)
map("v", "x", '"_x', opts)

-- Move Faster
map("n", "<S-j>", "10j", opts)
map("n", "<S-k>", "10k", opts)

-- (;) as (:)
map("n", ";", ":", opts)

-- increment/decrement numbers
map("n", "+", "<C-a>", { noremap = true, silent = true, desc = "Increment number" })
map("n", "-", "<C-x>", { noremap = true, silent = true, desc = "Decrement number" })

-- delete a word backward
map("n", "dw", "vb_d", opts)

-- select all
map("n", "<C-a>", "gg<S-v>G", opts)

-- new tab
-- map("n", "<leader>te", ":tabedit<CR>", opts)
-- map("n", "<leader>tn", ":tabnext<CR>", opts)
-- map("n", "<leader>tb", ":tabprev<CR>", opts)

-- Set space as my leader key
map("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Add undo break-points
map("i", ",", ",<c-g>u", opts)
map("i", ".", ".<c-g>u", opts)
map("i", ";", ";<c-g>u", opts)

-- splitting windows
vim.api.nvim_set_keymap(
	"n",
	"<leader>s-",
	":split<CR>",
	{ noremap = true, silent = true, desc = "Horizontal tab split" }
) -- Horizontal split
vim.api.nvim_set_keymap(
	"n",
	"<leader>s|",
	":vsplit<CR>",
	{ noremap = true, silent = true, desc = "Vertical tab split" }
) -- Vertical split

-- Better split navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Resize splits with arrow keys
map("n", "<M-l>", ":vertical resize -1<CR>", opts)
map("n", "<M-h>", ":vertical resize +1<CR>", opts)
map("n", "<M-k>", ":resize +1<CR>", opts)
map("n", "<M-j>", ":resize -1<CR>", opts)

-- Buffer navigation
map("n", "[b", ":BufferLineCyclePrev<CR>", opts)
map("n", "]b", ":BufferLineCycleNext<CR>", opts)
map("n", "<C-PageUp>", ":BufferLineCyclePrev<CR>", opts)
map("n", "<C-PageDown>", ":BufferLineCycleNext<CR>", opts)

-- Move lines
map("n", "<S-j>", "<cmd>m .+1<cr>==", opts)
map("n", "<S-k>", "<cmd>m .-2<cr>==", opts)
map("i", "<S-j>", "<esc><cmd>m .+1<cr>==gi", opts)
map("i", "<S-k>", "<esc><cmd>m .-2<cr>==gi", opts)
map("v", "<S-j>", ":m '>+1<cr>gv=gv", opts)
map("v", "<S-k>", ":m '<-2<cr>gv=gv", opts)

-- Visual
-- better paste
map("v", "p", '"_dP', opts)

-- move selected lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move up" })

-- Stay in visual mode for next indentation
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- shortcut in writing
map("i", "][", "{}<left>", opts)
map("i", "09", "()<left>", opts)
map("i", "''", '""<left>', opts)
map("i", ";;", ":", opts)

-- Map backspace to delete word under cursor in normal mode
map("n", "<BS>", "diwh", { noremap = true, silent = true })

-- use leader q to quit buffer
map("n", "<leader>q", ":bd<CR>", { noremap = true, silent = true })

-- by pressing <home> cursor will go to the first character of the line
map("i", "<Home>", "<C-o>^", { noremap = true, silent = true })
