-- Define local variables
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight text on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	group = "YankHighlight",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = "300" })
	end,
})

-- show cursor line only in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	callback = function()
		if vim.w.auto_cursorline then
			vim.wo.cursorline = true
			vim.w.auto_cursorline = nil
		end
	end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
	callback = function()
		if vim.wo.cursorline then
			vim.w.auto_cursorline = true
			vim.wo.cursorline = false
		end
	end,
})

-- Automatically rebalance windows on vim resize
autocmd("VimResized", {
	pattern = "",
	command = "wincmd =",
})

-- Close man and help with just with <q>
autocmd("FileType", {
	pattern = {
		"help",
		"man",
		"lspinfo",
		"checkhealth",
		"qf",
		"notify",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"PlenaryTestPopup",
		"Telescope",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Auto create dir when saving a file where some intermediate directory does not exist
autocmd("BufWritePre", {
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.loop.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Check for spelling in text filetypes (gitcommit, markdown)
autocmd("FileType", {
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc", { clear = true }),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- When you open a Python file inside a project folder with .venv, it will use that interpreter.
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.py",
	callback = function()
		local venv_path = vim.fn.getcwd() .. "/.venv/bin/python"
		if vim.fn.filereadable(venv_path) == 1 then
			vim.g.molten_python_executable = venv_path
		end
	end,
})

-- Enable line wrapping for Markdown files and disable for CSV/TSV files
local augroup = vim.api.nvim_create_augroup("FileTypeSettings", { clear = true })

-- CSV/TSV settings
vim.api.nvim_create_autocmd({ "FileType", "BufRead", "BufNewFile" }, {
	group = augroup,
	pattern = { "csv", "*.tsv", "*.csv" },
	callback = function()
		vim.opt_local.wrap = false
		vim.opt_local.linebreak = false
	end,
})

-- Markdown settings
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true -- Break at word boundaries
	end,
})
