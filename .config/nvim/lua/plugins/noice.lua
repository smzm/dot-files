return {
	"folke/noice.nvim",
	config = function()
		require("noice").setup({
			-- defaults for hover and signature help
			lsp = {
				signature = {
					enabled = false, -- Enable signature help
					-- auto_open = true, -- Prevent automatic opening
					-- view = "mini", -- Use a minimal view for signature help
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
							{ find = "%d fewer lines" },
							{ find = "%d more lines" },
						},
					},
					opts = { skip = true },
				},
			},
		})
	end,
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
}
-- To swith between noice popup and neovim use : <C-w>w
