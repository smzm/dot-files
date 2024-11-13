return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local harpoon = require("harpoon")

		-- REQUIRED
		harpoon:setup()

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Add to harpoon" })

		vim.keymap.set("n", "<leader><space>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Toogle harpoon menu" })

		vim.keymap.set("n", "<leader>h1", function()
			harpoon:list():select(1)
		end, { desc = "Go to harpoon 1" })
		vim.keymap.set("n", "<leader>h2", function()
			harpoon:list():select(2)
		end, { desc = "Go to harpoon 2" })
		vim.keymap.set("n", "<leader>h3", function()
			harpoon:list():select(3)
		end, { desc = "Go to harpoon 3" })
		vim.keymap.set("n", "<leader>h4", function()
			harpoon:list():select(4)
		end, { desc = "Go to harpoon 4" })

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<C-S-P>", function()
			harpoon:list():prev()
		end)
		vim.keymap.set("n", "<C-S-N>", function()
			harpoon:list():next()
		end)
	end,
}
