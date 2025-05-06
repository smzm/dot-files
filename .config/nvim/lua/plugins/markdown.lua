-- dir = "~/.config/nvim/lua/themes/neoshine", -- local path
return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		opts = {},
		config = function()
			vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { link = "H1" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { link = "H2" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { link = "H3" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { link = "Normal" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { link = "Normal" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { link = "Normal" })
			vim.api.nvim_set_hl(0, "RenderMarkdownLink", { link = "Underlined" })
			vim.api.nvim_set_hl(0, "RenderMarkdownCode", { link = "CodeBlock" })
			vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { link = "CodeBlock" })
			-- RenderMarkdownTodo  -- Linked to @markup.raw
			-- RenderMarkdownChecked  -- Linked to @markup.list.checked
			-- RenderMarkdownTableHead  -- Linked to @markup.heading
			-- RenderMarkdownTableRow  -- Linked to Normal
			-- RenderMarkdownTableFill  -- Linked to Conceal
			-- RenderMarkdownSuccess  -- Linked to DiagnosticOk
			-- RenderMarkdownWarn  -- Linked to DiagnosticWarn
			-- RenderMarkdownInfo  -- Linked to DiagnosticInfo
			-- RenderMarkdownError  -- Linked to DiagnosticError
			-- RenderMarkdownHint  -- Linked to DiagnosticHint
			-- RenderMarkdownSign  -- Linked to SignColumn
			-- RenderMarkdownMath  -- Linked to @markup.math
			-- RenderMarkdownHtmlComment  -- Linked to @comment
			-- RenderMarkdownLink  -- Linked to Underlined
			-- RenderMarkdownWikiLink  -- Linked to RenderMarkdownLink
			-- RenderMarkdownUnchecked  -- Linked to @markup.list.unchecked
			-- RenderMarkdownDash  -- Linked to LineNr
			-- RenderMarkdownInlineHighlight  -- Linked to RenderMarkdownCodeInline
			-- RenderMarkdownQuote  -- Linked to @markup.quote
			-- RenderMarkdownQuote6  -- Linked to RenderMarkdownQuote
			-- RenderMarkdownQuote5  -- Linked to RenderMarkdownQuote
			-- RenderMarkdownQuote4  -- Linked to RenderMarkdownQuote
			-- RenderMarkdownQuote3  -- Linked to RenderMarkdownQuote
			-- RenderMarkdownQuote2  -- Linked to RenderMarkdownQuote
			-- RenderMarkdownQuote1  -- Linked to RenderMarkdownQuote
			-- RenderMarkdownBullet  -- Linked to Normal

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
	{
		"Kicamon/markdown-table-mode.nvim",
		config = function()
			require("markdown-table-mode").setup()
		end,
		-- Run the :Mtm command to toggle markdown table mode.
	},
	{

		-- TO CREATE ENV : python -m ipykernel install --user --name=myenv --display-name "MyEnv"
		"benlubas/molten-nvim",
		dev = false,
		enabled = true,
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		build = ":UpdateRemotePlugins",
		dependencies = {
			"willothy/wezterm.nvim",
			"3rd/image.nvim",
		},
		init = function()
			vim.g.molten_image_provider = "image.nvim"
			-- vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
			vim.g.molten_auto_open_html_in_browser = true
			vim.g.molten_output_show_more = true
			vim.g.molten_output_virt_lines = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_tick_rate = 200
		end,
		config = function()
			local init = function()
				local quarto_cfg = require("quarto.config").config
				quarto_cfg.codeRunner.default_method = "molten"
				vim.cmd([[MoltenInit]])
			end
			local deinit = function()
				local quarto_cfg = require("quarto.config").config
				quarto_cfg.codeRunner.default_method = "slime"
				vim.cmd([[MoltenDeinit]])
			end
			vim.keymap.set("n", "<localleader>mi", init, { silent = true, desc = "Initialize molten" })
			vim.keymap.set("n", "<localleader>md", deinit, { silent = true, desc = "Stop molten" })
			vim.keymap.set("n", "<localleader>md", deinit, { silent = true, desc = "Stop molten" })
			vim.keymap.set(
				"n",
				"<localleader>mp",
				":MoltenImagePopup<CR>",
				{ silent = true, desc = "molten image popup" }
			)
			vim.keymap.set(
				"n",
				"<leader>mb",
				":MoltenOpenInBrowser<CR>",
				{ silent = true, desc = "molten open in browser" }
			)
			vim.keymap.set("n", "<localleader>mh", ":MoltenHideOutput<CR>", { silent = true, desc = "hide output" })
			vim.keymap.set(
				"n",
				"<localleader>mr",
				":MoltenReevaluateCell<CR>",
				{ silent = true, desc = "Re-evaluate cell" }
			)
			vim.keymap.set(
				"n",
				"<localleader>mu",
				":MoltenReevaluateAll<CR>",
				{ silent = true, desc = "Re-evaluate all" }
			)
			vim.keymap.set(
				"n",
				"<localleader>ms",
				":noautocmd MoltenEnterOutput<CR>",
				{ silent = true, desc = "show/enter output" }
			)

			vim.keymap.set(
				"v",
				"<localleader>mm",
				":<C-u>MoltenEvaluateVisual<CR>gv",
				{ desc = "execute visual selection", buffer = true, silent = true }
			)

			-- Add the new keymap for highlighting code block and running MoltenEvaluateVisual
			vim.keymap.set("n", "<localleader><space>", function()
				-- Get the current line
				local cursor_line = vim.fn.line(".")
				local cursor_line_text = vim.fn.getline(cursor_line)

				-- Helper function to check if a line is a Python code block start
				local function is_python_block_start(line_text)
					return line_text:match("^```python") or line_text:match("^```{python}")
				end

				-- Helper function to check if a line is a code block end
				local function is_code_block_end(line_text)
					return line_text:match("^```$")
				end

				-- Case 1: If cursor is on a line that starts with ```python or ```{python}
				if is_python_block_start(cursor_line_text) then
					local end_line = cursor_line + 1
					-- Find the next occurrence of ```
					while end_line <= vim.fn.line("$") do
						if is_code_block_end(vim.fn.getline(end_line)) then
							break
						end
						end_line = end_line + 1
					end
					-- Select the range and execute
					vim.cmd(string.format("normal! %dGV%dG", cursor_line + 1, end_line - 1))
					vim.cmd("MoltenEvaluateVisual")
					vim.api.nvim_input("<Esc>")

				-- Case 2: If cursor is on a line that starts with ```
				elseif is_code_block_end(cursor_line_text) then
					local start_line = cursor_line - 1
					-- Find the previous occurrence of ```python or ```{python}
					while start_line >= 1 do
						if is_python_block_start(vim.fn.getline(start_line)) then
							break
						end
						start_line = start_line - 1
					end
					if start_line >= 1 then -- Found ```python or ```{python}
						-- Select the range and execute
						vim.cmd(string.format("normal! %dGV%dG", start_line + 1, cursor_line - 1))
						vim.cmd("MoltenEvaluateVisual")
						vim.api.nvim_input("<Esc>")
					end

				-- Case 3: Check if inside a code block
				else
					local start_line = cursor_line
					-- Look backwards for ```python or ```{python}
					while start_line >= 1 do
						if is_python_block_start(vim.fn.getline(start_line)) then
							break
						elseif is_code_block_end(vim.fn.getline(start_line)) then
							-- We hit a closing ``` first, so we're not in a code block
							start_line = -1
							break
						end
						start_line = start_line - 1
					end

					if start_line >= 1 then -- Found ```python or ```{python}, so we're in a code block
						local end_line = cursor_line
						-- Look forward for ```
						while end_line <= vim.fn.line("$") do
							if is_code_block_end(vim.fn.getline(end_line)) then
								break
							end
							end_line = end_line + 1
						end
						-- Select the range and execute
						vim.cmd(string.format("normal! %dGV%dG", start_line + 1, end_line - 1))
						vim.cmd("MoltenEvaluateVisual")
						vim.api.nvim_input("<Esc>")
					end
					-- If we're not in a code block, do nothing
				end
			end, { silent = true, desc = "highlight code block and run Molten" })
		end,
	},
	{
		"jmbuhr/otter.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			lsp = {
				diagnostic_update_events = { "BufWritePost", "InsertLeave", "TextChanged" },
			},
		},
		config = function()
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
				pattern = "*.md",
				callback = function()
					require("otter").activate({ "python", "typescript" })
				end,
			})
		end,
	},
	{ -- show images in nvim!
		"3rd/image.nvim",
		enabled = true,
		dev = false,
		-- fix to commit to keep using the rockspeck for image magick
		ft = { "markdown", "quarto", "vimwiki" },
		cond = function()
			-- Disable on Windows system
			return vim.fn.has("win32") ~= 1
		end,
		dependencies = {
			"leafo/magick", -- that's a lua rock
		},
		config = function()
			-- Requirements
			-- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
			-- check for dependencies with `:checkhealth kickstart`
			-- needs:
			-- sudo apt install imagemagick
			-- sudo apt install libmagickwand-dev
			-- sudo apt install liblua5.1-0-dev
			-- sudo apt install lua5.1
			-- sudo apt install luajit

			local image = require("image")
			image.setup({
				backend = "kitty",
				integrations = {
					markdown = {
						enabled = true,
						only_render_image_at_cursor = true,
						only_render_image_at_cursor_mode = "popup",
						filetypes = { "markdown", "vimwiki", "quarto" },
					},
				},
				editor_only_render_when_focused = false,
				window_overlap_clear_enabled = true,
				tmux_show_only_in_active_window = true,
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "scrollview", "scrollview_sign" },
				max_width = 100,
				max_height = 14,
				max_height_window_percentage = math.huge,
				max_width_window_percentage = math.huge,
				kitty_method = "normal",
			})

			local function clear_all_images()
				local bufnr = vim.api.nvim_get_current_buf()
				local images = image.get_images({ buffer = bufnr })
				for _, img in ipairs(images) do
					img:clear()
				end
			end

			local function get_image_at_cursor(buf)
				local images = image.get_images({ buffer = buf })
				local row = vim.api.nvim_win_get_cursor(0)[1] - 1
				for _, img in ipairs(images) do
					if img.geometry ~= nil and img.geometry.y == row then
						local og_max_height = img.global_state.options.max_height_window_percentage
						img.global_state.options.max_height_window_percentage = nil
						return img, og_max_height
					end
				end
				return nil
			end

			local create_preview_window = function(img, og_max_height)
				local buf = vim.api.nvim_create_buf(false, true)
				local win_width = vim.api.nvim_get_option_value("columns", {})
				local win_height = vim.api.nvim_get_option_value("lines", {})
				local win = vim.api.nvim_open_win(buf, true, {
					relative = "editor",
					style = "minimal",
					width = win_width,
					height = win_height,
					row = 0,
					col = 0,
					zindex = 1000,
				})
				vim.keymap.set("n", "q", function()
					vim.api.nvim_win_close(win, true)
					img.global_state.options.max_height_window_percentage = og_max_height
				end, { buffer = buf })
				return { buf = buf, win = win }
			end

			local handle_zoom = function(bufnr)
				local img, og_max_height = get_image_at_cursor(bufnr)
				if img == nil then
					return
				end

				local preview = create_preview_window(img, og_max_height)
				image.hijack_buffer(img.path, preview.win, preview.buf)
			end

			vim.keymap.set("n", "<leader>io", function()
				local bufnr = vim.api.nvim_get_current_buf()
				handle_zoom(bufnr)
			end, { buffer = true, desc = "image [o]pen" })

			vim.keymap.set("n", "<leader>ic", clear_all_images, { desc = "image [c]lear" })
		end,
	},
}
