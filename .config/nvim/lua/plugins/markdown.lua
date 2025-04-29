-- dir = "~/.config/nvim/lua/themes/neoshine", -- local path
return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Open Markdown Preview" },
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		opts = {},
		config = function()
			local monoshine = require("themes.monoshine.lua.monoshine")
			local colors = monoshine.colors

			vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#252525", fg = colors.fg })
			vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#454545", fg = colors.lightGray })
			vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = colors.midGrayDarker })
			vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#030303" })
			vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = colors.dimGrayDarker })

			require("render-markdown").setup({
				render_modes = true,
				heading = {
					border = false,
					background = {
						"RenderMarkdownH1Bg",
					},
					foreground = {
						"RenderMarkdownH1",
					},
				},
			})
		end,
	},
	{ -- format things as tables
		"godlygeek/tabular",
	},
	-- { -- show images in nvim!
	-- 	"3rd/image.nvim",
	-- 	enabled = true,
	-- 	dev = false,
	-- 	-- fix to commit to keep using the rockspeck for image magick
	-- 	ft = { "markdown", "quarto", "vimwiki" },
	-- 	cond = function()
	-- 		-- Disable on Windows system
	-- 		return vim.fn.has("win32") ~= 1
	-- 	end,
	-- 	dependencies = {
	-- 		"leafo/magick", -- that's a lua rock
	-- 	},
	-- 	config = function()
	-- 		-- Requirements
	-- 		-- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
	-- 		-- check for dependencies with `:checkhealth kickstart`
	-- 		-- needs:
	-- 		-- sudo apt install imagemagick
	-- 		-- sudo apt install libmagickwand-dev
	-- 		-- sudo apt install liblua5.1-0-dev
	-- 		-- sudo apt install lua5.1
	-- 		-- sudo apt install luajit
	--
	-- 		local image = require("image")
	-- 		image.setup({
	-- 			backend = "kitty",
	-- 			integrations = {
	-- 				markdown = {
	-- 					enabled = true,
	-- 					only_render_image_at_cursor = true,
	-- 					only_render_image_at_cursor_mode = "popup",
	-- 					filetypes = { "markdown", "vimwiki", "quarto" },
	-- 				},
	-- 			},
	-- 			editor_only_render_when_focused = false,
	-- 			window_overlap_clear_enabled = true,
	-- 			tmux_show_only_in_active_window = true,
	-- 			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "scrollview", "scrollview_sign" },
	-- 			max_width = 100,
	-- 			max_height = 14,
	-- 			max_height_window_percentage = math.huge,
	-- 			max_width_window_percentage = math.huge,
	-- 			kitty_method = "normal",
	-- 		})
	--
	-- 		local function clear_all_images()
	-- 			local bufnr = vim.api.nvim_get_current_buf()
	-- 			local images = image.get_images({ buffer = bufnr })
	-- 			for _, img in ipairs(images) do
	-- 				img:clear()
	-- 			end
	-- 		end
	--
	-- 		local function get_image_at_cursor(buf)
	-- 			local images = image.get_images({ buffer = buf })
	-- 			local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	-- 			for _, img in ipairs(images) do
	-- 				if img.geometry ~= nil and img.geometry.y == row then
	-- 					local og_max_height = img.global_state.options.max_height_window_percentage
	-- 					img.global_state.options.max_height_window_percentage = nil
	-- 					return img, og_max_height
	-- 				end
	-- 			end
	-- 			return nil
	-- 		end
	--
	-- 		local create_preview_window = function(img, og_max_height)
	-- 			local buf = vim.api.nvim_create_buf(false, true)
	-- 			local win_width = vim.api.nvim_get_option_value("columns", {})
	-- 			local win_height = vim.api.nvim_get_option_value("lines", {})
	-- 			local win = vim.api.nvim_open_win(buf, true, {
	-- 				relative = "editor",
	-- 				style = "minimal",
	-- 				width = win_width,
	-- 				height = win_height,
	-- 				row = 0,
	-- 				col = 0,
	-- 				zindex = 1000,
	-- 			})
	-- 			vim.keymap.set("n", "q", function()
	-- 				vim.api.nvim_win_close(win, true)
	-- 				img.global_state.options.max_height_window_percentage = og_max_height
	-- 			end, { buffer = buf })
	-- 			return { buf = buf, win = win }
	-- 		end
	--
	-- 		local handle_zoom = function(bufnr)
	-- 			local img, og_max_height = get_image_at_cursor(bufnr)
	-- 			if img == nil then
	-- 				return
	-- 			end
	--
	-- 			local preview = create_preview_window(img, og_max_height)
	-- 			image.hijack_buffer(img.path, preview.win, preview.buf)
	-- 		end
	--
	-- 		vim.keymap.set("n", "<leader>io", function()
	-- 			local bufnr = vim.api.nvim_get_current_buf()
	-- 			handle_zoom(bufnr)
	-- 		end, { buffer = true, desc = "image [o]pen" })
	--
	-- 		vim.keymap.set("n", "<leader>ic", clear_all_images, { desc = "image [c]lear" })
	-- 	end,
	-- },
}
