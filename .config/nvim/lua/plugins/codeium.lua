-- Codeium ai : to run --> :Codeium Auth
return {
	"Exafunction/codeium.vim",
	event = "InsertEnter",
	config = function()
		-- Change '<C-g>' here to any keycode you like.
		vim.keymap.set("i", "<C-e>", function()
			return vim.fn["codeium#Accept"]()
		end, { expr = true, silent = true })
		vim.keymap.set("i", "<c-n>", function()
			return vim.fn["codeium#CycleCompletions"](1)
		end, { expr = true, silent = true })
		vim.keymap.set("i", "<c-p>", function()
			return vim.fn["codeium#CycleCompletions"](-1)
		end, { expr = true, silent = true })
		vim.keymap.set("i", "<c-x>", function()
			return vim.fn["codeium#Clear"]()
		end, { expr = true, silent = true })
	end,
}
