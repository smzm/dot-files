return {
	"Isrothy/neominimap.nvim",
	enabled = true,
	dependencies = {
		"lewis6991/gitsigns.nvim",
	},
	lazy = false,
	-- Optional
	init = function()
		-- The following options are recommended when layout == "float"
		vim.opt.wrap = false
		vim.opt.sidescrolloff = 36 -- Set a large value
		vim.opt.updatetime = 300

		vim.on_key(function(char)
			if vim.fn.mode() == "n" then
				local is_search_nav_key =
					vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
				if is_search_nav_key then
					vim.g.neominimap_is_in_search = true
					require("neominimap").winRefresh({}, {})
				else
					vim.g.neominimap_is_in_search = false
					require("neominimap").winRefresh({}, {})
				end
			end
		end, vim.api.nvim_create_namespace("auto_search_nav"))

		--- Put your configuration here
		---@type Neominimap.UserConfig
		vim.g.neominimap = {
			x_multiplier = 1, ---@type integer
			y_multiplier = 1,
			auto_enable = true,
			layout = "float",
			handlers = {
				word_handler,
			},
			float = {
				minimap_width = 30, ---@type integer

				--- If set to nil, there is no maximum height restriction
				--- @type integer
				max_minimap_height = nil,

				margin = {
					right = 0, ---@type integer
					top = 0, ---@type integer
					bottom = 0, ---@type integer
				},
			},
			click = {
				enabled = true,
			},
			--  Only Show Minimap During Search
			win_filter = function(bufnr)
				return vim.g.neominimap_is_in_search
			end,
		}
	end,
	config = function()
		-- background can be 'NONE' or nil
		vim.api.nvim_set_hl(0, "NeominimapBackground", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NeominimapBorder", { link = "Conceal" })
		vim.api.nvim_set_hl(0, "NeominimapCursorLine", { link = "FloatBorder" })
		vim.api.nvim_set_hl(0, "NeominimapCursorLineSign", { link = "FloatBorder" })
		vim.api.nvim_set_hl(0, "NeominimapCursorLineNr", { link = "FloatBorder" })
		vim.api.nvim_set_hl(0, "NeominimapCursorLineFold", { link = "FloatBorder" })
	end,
}
