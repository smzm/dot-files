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

	{ -- directly open ipynb files as Markdown docuements
		-- and convert back behind the scenes
		"GCBallesteros/jupytext.nvim",
		opts = {
			custom_language_formatting = {
				python = {
					extension = "md",
					style = "markdown",
					force_ft = "markdown",
				},
			},
		},
	},

	{ -- preview equations
		"jbyuki/nabla.nvim",
		keys = {
			{ "<leader>qm", ':lua require"nabla".toggle_virt()<cr>', desc = "toggle [m]ath equations" },
		},
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
				"<localleader>mb",
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

	{ -- paste an image from the clipboard or drag-and-drop
		"HakonHarnes/img-clip.nvim",
		event = "BufEnter",
		ft = { "markdown", "quarto", "latex" },
		opts = {
			default = {
				dir_path = "img",
				use_absolute_path = false,
				relative_to_current_file = true,
				-- Save the images in a directory named after the current file and end in 'img',
				dir_path = function()
					return vim.fn.expand("%:t:r") .. "-img"
				end,

				prompt_for_file_name = true,
				extension = "avif", -- webp, png, jpg
				process_cmd = "convert - -quality 75 avif:-", ---@type string
			},
			filetypes = {
				markdown = {
					url_encode_path = true, -- encode spaces and special characters in file path
					-- I want to use blink.cmp to easily find images with the LSP, so adding ./ lamw25wmal
					template = "![$CURSOR](./$FILE_PATH)",
				},
			},
		},
		keys = {
			-- suggested keymap
			{ "<leader>ii", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
		},
		config = function()
			require("image").setup({
				vim.keymap.set({ "n", "i" }, "<M-a>", function()
					local pasted_image = require("img-clip").paste_image()
					if pasted_image then
						-- "Update" saves only if the buffer has been modified since the last save
						vim.cmd("silent! update")
						-- Get the current line
						local line = vim.api.nvim_get_current_line()
						-- Move cursor to end of line
						vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #line })
						-- I reload the file, otherwise I cannot view the image after pasted
						vim.cmd("edit!")
					end
				end, { desc = "[P]Paste image from system clipboard" }),
			})

			-------------------------------------------------------------------------------
			--                       Assets directory
			-------------------------------------------------------------------------------
			local IMAGE_STORAGE_PATH = "img"

			local function find_assets_dir()
				local dir = vim.fn.expand("%:p:h")
				while dir ~= "/" do
					local full_path = dir .. "/assets/" .. IMAGE_STORAGE_PATH
					if vim.fn.isdirectory(full_path) == 1 then
						return full_path
					end
					dir = vim.fn.fnamemodify(dir, ":h")
				end
				return nil
			end

			local function handle_image_paste(img_dir)
				local function paste_image(dir_path, file_name, ext, cmd)
					return require("img-clip").paste_image({
						dir_path = dir_path,
						use_absolute_path = false,
						relative_to_current_file = false,
						file_name = file_name,
						extension = ext or "avif",
						process_cmd = cmd or "convert - -quality 75 avif:-",
					})
				end

				local temp_buf = vim.api.nvim_create_buf(false, true) -- Create an unlisted, scratch buffer
				vim.api.nvim_set_current_buf(temp_buf) -- Switch to the temporary buffer
				local temp_image_path = vim.fn.tempname() .. ".avif"
				local image_pasted =
					paste_image(vim.fn.fnamemodify(temp_image_path, ":h"), vim.fn.fnamemodify(temp_image_path, ":t:r"))
				vim.api.nvim_buf_delete(temp_buf, { force = true }) -- Delete the buffer
				vim.fn.delete(temp_image_path) -- Delete the temporary file
				vim.defer_fn(function()
					local options = image_pasted and { "no", "yes", "format", "search" } or { "search" }
					local prompt = image_pasted and "Is this a thumbnail image? "
						or "No image in clipboard. Select search to continue."
					-- -- I was getting a character in the textbox, don't want to debug right now
					-- vim.cmd("stopinsert")
					vim.ui.select(options, { prompt = prompt }, function(is_thumbnail)
						if is_thumbnail == "search" then
							local assets_dir = find_assets_dir()
							-- Get the parent directory of the current file
							local current_dir = vim.fn.expand("%:p:h")
							-- remove warning: Cannot assign `string|nil` to parameter `string`
							if not assets_dir then
								print("Assets directory not found, cannot proceed with search.")
								return
							end
							-- Get the parent directory of assets_dir (removing /img/imgs)
							local base_assets_dir = vim.fn.fnamemodify(assets_dir, ":h:h:h")
							-- Count how many levels we need to go up
							local levels = 0
							local temp_dir = current_dir
							while temp_dir ~= base_assets_dir and temp_dir ~= "/" do
								levels = levels + 1
								temp_dir = vim.fn.fnamemodify(temp_dir, ":h")
							end
							-- Build the relative path
							local relative_path = levels == 0 and "./assets/" .. IMAGE_STORAGE_PATH
								or string.rep("../", levels) .. "assets/" .. IMAGE_STORAGE_PATH
							vim.api.nvim_put({ "![Image](" .. relative_path .. '){: width="500" }' }, "c", true, true)
							-- Capital "O" to move to the line above
							vim.cmd("normal! O")
							-- This "o" is to leave a blank line above
							vim.cmd("normal! o")
							vim.api.nvim_put({ "<!-- prettier-ignore -->" }, "c", true, true)
							vim.cmd("normal! jo")
							vim.api.nvim_put({ "_textimage_", "" }, "c", true, true)
							-- find image path and add a / at the end of it
							vim.cmd("normal! kkf)i/")
							-- Move one to the right and enter insert mode
							vim.cmd("normal! la")
							-- -- This puts me in insert mode where the cursor is
							-- vim.api.nvim_feedkeys("i", "n", true)
							require("auto-save").on()
							return
						end
						if not is_thumbnail then
							print("Image pasting canceled.")
							require("auto-save").on()
							return
						end
						if is_thumbnail == "format" then
							local extension_options = { "avif", "webp", "png", "jpg" }
							vim.ui.select(extension_options, {
								prompt = "Select image format:",
								default = "avif",
							}, function(selected_ext)
								if not selected_ext then
									return
								end
								-- Define proceed_with_paste with proper parameter names
								local function proceed_with_paste(process_command)
									local prefix = vim.fn.strftime("%y%m%d-")
									local function prompt_for_name()
										vim.ui.input(
											{ prompt = "Enter image name (no spaces). Added prefix: " .. prefix },
											function(input_name)
												if not input_name or input_name:match("%s") then
													print("Invalid image name or canceled. Image not pasted.")
													require("auto-save").on()
													return
												end
												local full_image_name = prefix .. input_name
												local file_path = img_dir
													.. "/"
													.. full_image_name
													.. "."
													.. selected_ext
												if vim.fn.filereadable(file_path) == 1 then
													print("Image name already exists. Please enter a new name.")
													prompt_for_name()
												else
													if
														paste_image(
															img_dir,
															full_image_name,
															selected_ext,
															process_command
														)
													then
														vim.api.nvim_put({ '{: width="500" }' }, "c", true, true)
														vim.cmd("normal! O")
														vim.cmd("stopinsert")
														vim.cmd("normal! o")
														vim.api.nvim_put(
															{ "<!-- prettier-ignore -->" },
															"c",
															true,
															true
														)
														vim.cmd("normal! j$o")
														vim.cmd("stopinsert")
														vim.api.nvim_put({ "__" }, "c", true, true)
														vim.cmd("normal! h")
														vim.cmd("silent! update")
														vim.cmd("edit!")
														require("auto-save").on()
													else
														print("No image pasted. File not updated.")
														require("auto-save").on()
													end
												end
											end
										)
									end
									prompt_for_name()
								end
								-- Resolution prompt handling
								vim.ui.select({ "Yes", "No" }, {
									prompt = "Change image resolution?",
									default = "No",
								}, function(resize_choice)
									local process_cmd
									if resize_choice == "Yes" then
										vim.ui.input({
											prompt = "Enter max height (default 1080): ",
											default = "1080",
										}, function(height_input)
											local height = tonumber(height_input) or 1080
											process_cmd = string.format(
												"convert - -resize x%d -quality 100 %s:-",
												height,
												selected_ext
											)
											proceed_with_paste(process_cmd)
										end)
									else
										process_cmd = "convert - -quality 75 " .. selected_ext .. ":-"
										proceed_with_paste(process_cmd)
									end
								end)
							end)
							return
						end
						local prefix = vim.fn.strftime("%y%m%d-") .. (is_thumbnail == "yes" and "thux-" or "")
						local function prompt_for_name()
							vim.ui.input(
								{ prompt = "Enter image name (no spaces). Added prefix: " .. prefix },
								function(input_name)
									if not input_name or input_name:match("%s") then
										print("Invalid image name or canceled. Image not pasted.")
										require("auto-save").on()
										return
									end
									local full_image_name = prefix .. input_name
									local file_path = img_dir .. "/" .. full_image_name .. ".avif"
									if vim.fn.filereadable(file_path) == 1 then
										print("Image name already exists. Please enter a new name.")
										prompt_for_name()
									else
										if paste_image(img_dir, full_image_name) then
											vim.api.nvim_put({ '{: width="500" }' }, "c", true, true)
											-- Create new line above and force normal mode
											vim.cmd("normal! O")
											vim.cmd("stopinsert") -- Explicitly exit insert mode
											-- Create blank line above and force normal mode
											vim.cmd("normal! o")
											vim.cmd("stopinsert")
											vim.api.nvim_put({ "<!-- prettier-ignore -->" }, "c", true, true)
											-- Move down and create new line (without staying in insert mode)
											vim.cmd("normal! j$o")
											vim.cmd("stopinsert")
											vim.api.nvim_put({ "__" }, "c", true, true)
											vim.cmd("normal! h") -- Position cursor between underscores
											vim.cmd("silent! update")
											vim.cmd("edit!")
											require("auto-save").on()
										else
											print("No image pasted. File not updated.")
											require("auto-save").on()
										end
									end
								end
							)
						end
						prompt_for_name()
					end)
				end, 100)
			end

			local function process_image()
				-- Any of these 2 work to toggle auto-save
				-- vim.cmd("ASToggle")
				require("auto-save").off()
				local img_dir = find_assets_dir()
				if not img_dir then
					vim.ui.select({ "yes", "no" }, {
						prompt = IMAGE_STORAGE_PATH .. " directory not found. Create it?",
						default = "yes",
					}, function(choice)
						if choice == "yes" then
							img_dir = vim.fn.getcwd() .. "/assets/" .. IMAGE_STORAGE_PATH
							vim.fn.mkdir(img_dir, "p")
							-- Start the image paste process after creating directory
							vim.defer_fn(function()
								handle_image_paste(img_dir)
							end, 100)
						else
							print("Operation cancelled - directory not created")
							require("auto-save").on()
							return
						end
					end)
					return
				end
				handle_image_paste(img_dir)
			end

			-- INFO: Keymap to paste images in the 'assets' directory
			-- This pastes images for my blogpost, I need to keep them in a different directory
			-- so I pass those options to img-clip
			vim.keymap.set({ "n", "i" }, "<leader>iv", process_image, { desc = "[P]Paste image in 'assets' directory" })

			-- Rename image under cursor lamw25wmal
			-- If the image is referenced multiple times in the file, it will also rename
			-- all the other occurrences in the file
			vim.keymap.set("n", "<leader>iR", function()
				local function get_image_path()
					-- Get the current line
					local line = vim.api.nvim_get_current_line()
					-- Pattern to match image path in Markdown
					local image_pattern = "%[.-%]%((.-)%)"
					-- Extract relative image path
					local _, _, image_path = string.find(line, image_pattern)
					return image_path
				end
				-- Get the image path
				local image_path = get_image_path()
				if not image_path then
					vim.api.nvim_echo({ { "No image found under the cursor", "WarningMsg" } }, false, {})
					return
				end
				-- Check if it's a URL
				if string.sub(image_path, 1, 4) == "http" then
					vim.api.nvim_echo({ { "URL images cannot be renamed.", "WarningMsg" } }, false, {})
					return
				end
				-- Get absolute paths
				local current_file_path = vim.fn.expand("%:p:h")
				local absolute_image_path = current_file_path .. "/" .. image_path
				-- Check if file exists
				if vim.fn.filereadable(absolute_image_path) == 0 then
					vim.api.nvim_echo(
						{ { "Image file does not exist:\n", "ErrorMsg" }, { absolute_image_path, "ErrorMsg" } },
						false,
						{}
					)
					return
				end
				-- Get directory and extension of current image
				local dir = vim.fn.fnamemodify(absolute_image_path, ":h")
				local ext = vim.fn.fnamemodify(absolute_image_path, ":e")
				local current_name = vim.fn.fnamemodify(absolute_image_path, ":t:r")
				-- Prompt for new name
				vim.ui.input(
					{ prompt = "Enter new name (without extension): ", default = current_name },
					function(new_name)
						if not new_name or new_name == "" then
							vim.api.nvim_echo({ { "Rename cancelled", "WarningMsg" } }, false, {})
							return
						end
						-- Construct new path
						local new_absolute_path = dir .. "/" .. new_name .. "." .. ext
						-- Check if new filename already exists
						if vim.fn.filereadable(new_absolute_path) == 1 then
							vim.api.nvim_echo(
								{ { "File already exists: " .. new_absolute_path, "ErrorMsg" } },
								false,
								{}
							)
							return
						end
						-- Rename the file
						local success, err = os.rename(absolute_image_path, new_absolute_path)
						if success then
							-- Get the old and new filenames (without path)
							local old_filename = vim.fn.fnamemodify(absolute_image_path, ":t")
							local new_filename = vim.fn.fnamemodify(new_absolute_path, ":t")
							-- -- Debug prints
							-- print("Old filename:", old_filename)
							-- print("New filename:", new_filename)
							-- Get buffer content
							local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
							-- print("Number of lines in buffer:", #lines)
							-- Replace the text in each line that contains the old filename
							for i = 0, #lines - 1 do
								local line = lines[i + 1]
								-- First find the image markdown pattern with explicit end
								local img_start, img_end = line:find("!%[.-%]%(.-%)")
								if img_start and img_end then
									-- Get just the exact markdown part without any extras
									local markdown_part = line:match("!%[.-%]%(.-%)")
									-- Replace old filename with new filename
									local escaped_old = old_filename:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")
									local escaped_new = new_filename:gsub("[%%]", "%%%%")
									-- Replace in the exact markdown part
									local new_markdown = markdown_part:gsub(escaped_old, escaped_new)
									-- Replace that exact portion in the line
									vim.api.nvim_buf_set_text(
										0,
										i,
										img_start - 1,
										i,
										img_start + #markdown_part - 1, -- Use exact length of markdown part
										{ new_markdown }
									)
								end
							end
							-- "Update" saves only if the buffer has been modified since the last save
							vim.cmd("update")
							vim.api.nvim_echo({
								{ "Image renamed successfully", "Normal" },
							}, false, {})
						else
							vim.api.nvim_echo({
								{ "Failed to rename image:\n", "ErrorMsg" },
								{ tostring(err), "ErrorMsg" },
							}, false, {})
						end
					end
				)
			end, { desc = "[P]Rename image under cursor" })
		end,
	},
}
