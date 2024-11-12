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

-- Auto Save when leaving insert mode
autocmd({ "InsertLeave", "TermOpen" }, {
	buffer = bufnr,
	group = augroup("auto_save", { clear = true }),
	callback = function()
		local curbuf = vim.api.nvim_get_current_buf()
		if not vim.api.nvim_buf_get_option(curbuf, "modified") or vim.fn.getbufvar(curbuf, "&modifiable") == 0 then
			return
		end

		vim.cmd([[silent! update]])
		vim.lsp.buf.format({
			filter = function(_client)
				return _client.name == "null-ls"
			end,
		})
	end,
})
