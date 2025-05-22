return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		opts = {},
		config = function()
			vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { link = "H1" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { link = "H2" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { link = "H3" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { link = "H4" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { link = "Normal" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { link = "Normal" })
			vim.api.nvim_set_hl(0, "RenderMarkdownLink", { link = "@markup.link" })
			vim.api.nvim_set_hl(0, "RenderMarkdownCode", { link = "CodeBlock" })
			vim.api.nvim_set_hl(0, "RenderMarkdownCodeBorder", { link = "CodeBorder" })
			vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { link = "InlineCodeBlock" })
			vim.api.nvim_set_hl(0, "RenderMarkdownIndent", { link = "Normal" })
			vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { link = "Label" })
			-- ... (other highlight links remain commented or active as you had them) ...

			require("render-markdown").setup({
				code = {
					sign = false,
					width = "full",
					border = "thin",
					left_pad = 5,
				},
				completions = { blink = { enabled = true } },
				render_modes = true,

				heading = {
					width = { "full", "full", "full" },
					min_width = 50,
					border = false,
					sign = true,
					background = {
						"RenderMarkdownH1Bg",
					},
					foreground = {
						"RenderMarkdownH1",
					},
				},
				checkbox = {
					checked = { scope_highlight = "@markup.strikethrough", icon = "✔ " },
					custom = {
						important = {
							raw = "[~]",
							rendered = "󰓎 ",
							highlight = "DiagnosticWarn",
						},
					},
				},
				callout = {
					note = {
						raw = "[!NOTE]",
						rendered = "󰋽 Note",
						highlight = "RenderMarkdownInfo",
						category = "github",
					},
					important = {
						raw = "[!IMPORTANT]",
						rendered = "󰅾 Important",
						highlight = "RenderMarkdownHint",
						category = "github",
					},
					warning = {
						raw = "[!WARNING]",
						rendered = "󰀪 Warning",
						highlight = "RenderMarkdownWarn",
						category = "github",
					},
					caution = {
						raw = "[!CAUTION]",
						rendered = "󰳦 Caution",
						highlight = "RenderMarkdownError",
						category = "github",
					},
					info = {
						raw = "[!INFO]",
						rendered = "󰋽 Info",
						highlight = "RenderMarkdownInfo",
						category = "obsidian",
					},
					todo = {
						raw = "[!TODO]",
						rendered = "󰗡 Todo",
						highlight = "RenderMarkdownInfo",
						category = "obsidian",
					},
					error = {
						raw = "[!ERROR]",
						rendered = "󱐌 Error",
						highlight = "RenderMarkdownError",
						category = "obsidian",
					},
					example = {
						raw = "[!EXAMPLE]",
						rendered = "󰉹 Example",
						highlight = "RenderMarkdownHint",
						category = "obsidian",
					},
					cite = {
						raw = "[!CITE]",
						rendered = "󱆨 Cite",
						highlight = "RenderMarkdownQuote",
						category = "obsidian",
					},
					index = {
						raw = "[!INDEX]",
						rendered = "📇 Index",
						highlight = "RenderMarkdownQuote",
						category = "obsidian",
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

	{ -- preview equations
		"jbyuki/nabla.nvim",
		config = function()
			require("nabla").enable_virt()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "latex" },
				auto_install = true,
				sync_install = false,
			})
		end,
		keys = {
			{ "<leader>qm", ':lua require"nabla".toggle_virt()<cr>', desc = "toggle [m]ath equations" },
		},
	},

	-- TO CREATE ENV : https://github.com/benlubas/molten-nvim/blob/main/docs/Virtual-Environments.md
	-- run "mkdir -p ~/.local/share/jupyter/runtime" at beginning to create the runtime directory
	{
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
			vim.g.molten_auto_image_popup = true
			vim.g.molten_image_location = "float" -- or "virt", "both"
			vim.g.molten_output_show_exec_time = true
			vim.g.molten_auto_open_output = false
			vim.g.molten_auto_open_html_in_browser = false
			vim.g.molten_output_show_more = true
			vim.g.molten_output_virt_lines = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_tick_rate = 200

			-- Configurable delays for running all blocks
			vim.g.molten_run_all_initial_delay_ms = 3000 -- Delay after the first block (allows for kernel selection)
			vim.g.molten_run_all_subsequent_delay_ms = 500 -- Delay between subsequent blocks
		end,
		config = function()
			local init = function()
				vim.cmd([[MoltenInit]])
			end
			local deinit = function()
				vim.cmd([[MoltenDeinit]])
			end

			vim.keymap.set("n", "<localleader>mi", init, { silent = true, desc = "Initialize molten" })
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
				":MoltenReevaluateAll<CR>", -- This is Molten's own re-evaluate all, might behave differently
				{ silent = true, desc = "Re-evaluate all (Molten built-in)" }
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

			-- Helper function to check if a line is a Python block start
			local function is_python_block_start(line_text)
				return line_text:match("^```python") or line_text:match("^```{python}")
			end

			-- Helper function to check if a line is a code block end
			local function is_code_block_end(line_text)
				return line_text:match("^```$")
			end

			-- Function to highlight text between start_line and end_line and run it with Molten (for <localleader>mx)
			local function highlight_and_run_single_block(start_line, end_line)
				if start_line > end_line then
					vim.notify("Molten: No code to run in the block.", vim.log.levels.INFO)
					return
				end
				local last_buffer_line = vim.fn.line("$")
				if start_line < 1 or end_line > last_buffer_line or start_line > last_buffer_line or end_line < 1 then
					vim.notify("Molten: Invalid line numbers for code block.", vim.log.levels.ERROR)
					return
				end

				vim.api.nvim_input("<Esc>")
				vim.cmd(string.format("normal! %dGV%dG", start_line, end_line))

				vim.defer_fn(function()
					vim.cmd("MoltenEvaluateVisual")
					vim.defer_fn(function()
						if vim.fn.mode(true):find("[vV\026]") then
							vim.api.nvim_input("<Esc>")
						end
					end, 10)
				end, 5)
			end

			vim.keymap.set("n", "<localleader>\\", function()
				-- ... (block finding logic from your previous working version) ...
				local cursor_line = vim.fn.line(".")
				local cursor_line_text = vim.fn.getline(cursor_line)
				local current_buf_total_lines = vim.fn.line("$")
				local code_block_start_line, code_block_end_line

				if is_python_block_start(cursor_line_text) then
					code_block_start_line = cursor_line
					local search_line = cursor_line + 1
					while search_line <= current_buf_total_lines do
						if is_code_block_end(vim.fn.getline(search_line)) then
							code_block_end_line = search_line
							break
						end
						search_line = search_line + 1
					end
				elseif is_code_block_end(cursor_line_text) then
					code_block_end_line = cursor_line
					local search_line = cursor_line - 1
					while search_line >= 1 do
						if is_python_block_start(vim.fn.getline(search_line)) then
							code_block_start_line = search_line
							break
						end
						search_line = search_line - 1
					end
				else
					local search_up_line = cursor_line
					while search_up_line >= 1 do
						local line_text_up = vim.fn.getline(search_up_line)
						if is_python_block_start(line_text_up) then
							code_block_start_line = search_up_line
							break
						elseif is_code_block_end(line_text_up) and search_up_line < cursor_line then
							code_block_start_line = nil
							break
						end
						search_up_line = search_up_line - 1
					end
					if code_block_start_line then
						local search_down_line = math.max(cursor_line, code_block_start_line + 1)
						while search_down_line <= current_buf_total_lines do
							local line_text_down = vim.fn.getline(search_down_line)
							if is_code_block_end(line_text_down) then
								code_block_end_line = search_down_line
								break
							elseif
								is_python_block_start(line_text_down) and search_down_line > code_block_start_line
							then
								code_block_end_line = nil
								break
							end
							search_down_line = search_down_line + 1
						end
					end
				end

				if code_block_start_line and code_block_end_line and code_block_start_line < code_block_end_line then
					highlight_and_run_single_block(code_block_start_line + 1, code_block_end_line - 1)
				else
					vim.notify("Molten: Not inside a valid Python code block or block not found.", vim.log.levels.INFO)
				end
			end, { silent = true, desc = "Molten: Run current block" })

			---------------------------------------------------------------------
			-- NEW: Run all Python code blocks sequentially
			---------------------------------------------------------------------
			local collected_blocks_to_run = {}
			local current_block_run_idx = 0

			local function collect_python_code_blocks()
				local blocks = {}
				local current_line = 1
				local total_lines = vim.fn.line("$")

				while current_line <= total_lines do
					local line_text = vim.fn.getline(current_line)
					if is_python_block_start(line_text) then
						local block_start_fence = current_line
						local content_start_line = current_line + 1
						local content_end_line = -1

						-- Search for the end of the block
						local search_end_line = content_start_line
						while search_end_line <= total_lines do
							if is_code_block_end(vim.fn.getline(search_end_line)) then
								content_end_line = search_end_line - 1
								current_line = search_end_line -- Continue search from after this block
								break
							end
							search_end_line = search_end_line + 1
						end

						if content_end_line ~= -1 and content_start_line <= content_end_line then
							table.insert(blocks, {
								start_line = content_start_line,
								end_line = content_end_line,
								fence_start = block_start_fence,
							})
						elseif content_end_line == -1 then -- No closing fence found
							current_line = total_lines + 1 -- Stop searching
						end
					end
					current_line = current_line + 1
				end
				return blocks
			end

			local function run_next_block_in_sequence()
				current_block_run_idx = current_block_run_idx + 1
				if current_block_run_idx > #collected_blocks_to_run then
					vim.notify("Molten: Finished running all Python code blocks.", vim.log.levels.INFO)
					collected_blocks_to_run = {} -- Clear for next run
					current_block_run_idx = 0
					return
				end

				local block = collected_blocks_to_run[current_block_run_idx]
				vim.notify(
					string.format(
						"Molten: Running block %d/%d (lines %d-%d)",
						current_block_run_idx,
						#collected_blocks_to_run,
						block.start_line,
						block.end_line
					),
					vim.log.levels.INFO
				)

				-- Move cursor to the start of the block for visual feedback
				vim.api.nvim_win_set_cursor(0, { block.fence_start, 0 })

				-- Select and run
				vim.api.nvim_input("<Esc>") -- Ensure normal mode
				vim.cmd(string.format("normal! %dGV%dG", block.start_line, block.end_line))

				vim.defer_fn(function()
					vim.cmd("MoltenEvaluateVisual")
					vim.defer_fn(function()
						if vim.fn.mode(true):find("[vV\026]") then
							vim.api.nvim_input("<Esc>")
						end
						-- Schedule the next block execution
						local delay_ms
						if current_block_run_idx == 1 then
							delay_ms = vim.g.molten_run_all_initial_delay_ms
						else
							delay_ms = vim.g.molten_run_all_subsequent_delay_ms
						end
						vim.defer_fn(run_next_block_in_sequence, delay_ms)
					end, 50) -- Small delay for Molten cmd to queue and <Esc>
				end, 10) -- Small delay for visual selection to register
			end

			vim.keymap.set("n", "<localleader>ma", function() -- 'ma' for Molten All
				collected_blocks_to_run = collect_python_code_blocks()
				if #collected_blocks_to_run == 0 then
					vim.notify("Molten: No Python code blocks found to run.", vim.log.levels.INFO)
					return
				end

				current_block_run_idx = 0 -- Reset index
				vim.notify(
					"Molten: Starting to run " .. #collected_blocks_to_run .. " Python code blocks...",
					vim.log.levels.INFO
				)

				-- Start the sequence
				run_next_block_in_sequence()
			end, { silent = true, desc = "Molten: Run all Python blocks" })
		end,
	},

	{ -- show images in nvim!
		"3rd/image.nvim",
		enabled = true,
		build = false,
		ft = { "markdown", "quarto", "vimwiki" },
		config = function()
			local image = require("image")
			image.setup({
				backend = "kitty",
				processor = "magick_cli",
				integrations = {
					markdown = {
						enabled = true,
						only_render_image_at_cursor = false,
						only_render_image_at_cursor_mode = "popup",
						floating_windows = false,
						filetypes = { "markdown", "vimwiki", "quarto" },
					},
					html = {
						enabled = true,
					},
					css = {
						enabled = true,
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
				dir_path = function()
					return vim.fn.expand("%:t:r") .. "-img"
				end,
				prompt_for_file_name = true,
				extension = "avif",
				process_cmd = "convert - -quality 75 avif:-",
			},
			filetypes = {
				markdown = {
					url_encode_path = true,
					template = "![$CURSOR](./$FILE_PATH)",
				},
			},
		},
		keys = {
			{ "<leader>ii", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
		},
		config = function(_, opts) -- Pass opts to config
			-- The original config for img-clip.nvim already required "image",
			-- so we can just use require("img-clip").setup(opts) if that's how it's intended
			-- or keep the custom config logic if needed.
			-- For simplicity, if img-clip has a setup function that takes opts, use it:
			-- require("img-clip").setup(opts) -- This would use the opts defined above.
			-- However, your current config structure defines keymaps and custom logic inside.

			-- Original config setup part for image (seems redundant if image.nvim is already configured)
			-- If 'image' is only needed for the <M-a> keymap, then it's fine.
			-- require("image").setup({ ... }) -- This was here, but image.nvim has its own setup.
			-- It's probably meant to be part of the image.nvim config
			-- or this keymap should be there.
			-- For now, I'll assume this keymap is specific to img-clip context.

			vim.keymap.set({ "n", "i" }, "<M-a>", function()
				local pasted_image = require("img-clip").paste_image()
				if pasted_image then
					vim.cmd("silent! update")
					local line = vim.api.nvim_get_current_line()
					vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #line })
					vim.cmd("edit!")
				end
			end, { desc = "[P]Paste image from system clipboard" })

			-------------------------------------------------------------------------------
			--                       Assets directory
			-------------------------------------------------------------------------------
			local IMAGE_STORAGE_PATH = ""

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
						relative_to_current_file = true,
						file_name = file_name,
						extension = ext or "avif",
						process_cmd = cmd or "convert - -quality 75 avif:-",
					})
				end

				local temp_buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_set_current_buf(temp_buf)
				local temp_image_path = vim.fn.tempname() .. ".avif"
				local image_pasted =
					paste_image(vim.fn.fnamemodify(temp_image_path, ":h"), vim.fn.fnamemodify(temp_image_path, ":t:r"))
				vim.api.nvim_buf_delete(temp_buf, { force = true })
				vim.fn.delete(temp_image_path)
				vim.defer_fn(function()
					local options = image_pasted and { "no", "yes", "format", "search" } or { "search" }
					local prompt = image_pasted and "Is this a thumbnail image? "
						or "No image in clipboard. Select search to continue."
					vim.ui.select(options, { prompt = prompt }, function(is_thumbnail)
						if is_thumbnail == "search" then
							local assets_dir = find_assets_dir()
							local current_dir = vim.fn.expand("%:p:h")
							if not assets_dir then
								print("Assets directory not found, cannot proceed with search.")
								return
							end
							local base_assets_dir = vim.fn.fnamemodify(assets_dir, ":h:h:h")
							local levels = 0
							local temp_dir = current_dir
							while temp_dir ~= base_assets_dir and temp_dir ~= "/" do
								levels = levels + 1
								temp_dir = vim.fn.fnamemodify(temp_dir, ":h")
							end
							local relative_path = levels == 0 and "./assets/" .. IMAGE_STORAGE_PATH
								or string.rep("../", levels) .. "assets/" .. IMAGE_STORAGE_PATH
							vim.api.nvim_put({ "![Image](" .. relative_path .. '){: width="500" }' }, "c", true, true)
							vim.cmd("normal! O")
							vim.cmd("normal! o")
							vim.api.nvim_put({ "<!-- prettier-ignore -->" }, "c", true, true)
							vim.cmd("normal! jo")
							vim.api.nvim_put({ "_textimage_", "" }, "c", true, true)
							vim.cmd("normal! kkf)i/")
							vim.cmd("normal! la")
							if require("auto-save") then
								require("auto-save").on()
							end
							return
						end
						if not is_thumbnail then
							print("Image pasting canceled.")
							if require("auto-save") then
								require("auto-save").on()
							end
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
								local function proceed_with_paste(process_command)
									local prefix = vim.fn.strftime("%y%m%d-")
									local function prompt_for_name()
										vim.ui.input(
											{ prompt = "Enter image name (no spaces). Added prefix: " .. prefix },
											function(input_name)
												if not input_name or input_name:match("%s") then
													print("Invalid image name or canceled. Image not pasted.")
													if require("auto-save") then
														require("auto-save").on()
													end
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
														if require("auto-save") then
															require("auto-save").on()
														end
													else
														print("No image pasted. File not updated.")
														if require("auto-save") then
															require("auto-save").on()
														end
													end
												end
											end
										)
									end
									prompt_for_name()
								end
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
										if require("auto-save") then
											require("auto-save").on()
										end
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
											vim.cmd("normal! O")
											vim.cmd("stopinsert")
											vim.cmd("normal! o")
											vim.cmd("stopinsert")
											vim.api.nvim_put({ "<!-- prettier-ignore -->" }, "c", true, true)
											vim.cmd("normal! j$o")
											vim.cmd("stopinsert")
											vim.api.nvim_put({ "__" }, "c", true, true)
											vim.cmd("normal! h")
											vim.cmd("silent! update")
											vim.cmd("edit!")
											if require("auto-save") then
												require("auto-save").on()
											end
										else
											print("No image pasted. File not updated.")
											if require("auto-save") then
												require("auto-save").on()
											end
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
				if require("auto-save") then
					require("auto-save").off()
				end
				local img_dir = find_assets_dir()
				if not img_dir then
					vim.ui.select({ "yes", "no" }, {
						prompt = IMAGE_STORAGE_PATH .. " directory not found. Create it?",
						default = "yes",
					}, function(choice)
						if choice == "yes" then
							img_dir = vim.fn.getcwd() .. "/assets/" .. IMAGE_STORAGE_PATH
							vim.fn.mkdir(img_dir, "p")
							vim.defer_fn(function()
								handle_image_paste(img_dir)
							end, 100)
						else
							print("Operation cancelled - directory not created")
							if require("auto-save") then
								require("auto-save").on()
							end
							return
						end
					end)
					return
				end
				handle_image_paste(img_dir)
			end

			vim.keymap.set({ "n" }, "<leader>iv", process_image, { desc = "[P]Paste image in 'assets' directory" })

			vim.keymap.set("n", "<leader>iR", function()
				local function get_image_path()
					local line = vim.api.nvim_get_current_line()
					local image_pattern = "%[.-%]%((.-)%)"
					local _, _, image_path = string.find(line, image_pattern)
					return image_path
				end
				local image_path = get_image_path()
				if not image_path then
					vim.api.nvim_echo({ { "No image found under the cursor", "WarningMsg" } }, false, {})
					return
				end
				if string.sub(image_path, 1, 4) == "http" then
					vim.api.nvim_echo({ { "URL images cannot be renamed.", "WarningMsg" } }, false, {})
					return
				end
				local current_file_path = vim.fn.expand("%:p:h")
				local absolute_image_path = current_file_path .. "/" .. image_path
				if vim.fn.filereadable(absolute_image_path) == 0 then
					vim.api.nvim_echo(
						{ { "Image file does not exist:\n", "ErrorMsg" }, { absolute_image_path, "ErrorMsg" } },
						false,
						{}
					)
					return
				end
				local dir = vim.fn.fnamemodify(absolute_image_path, ":h")
				local ext = vim.fn.fnamemodify(absolute_image_path, ":e")
				local current_name = vim.fn.fnamemodify(absolute_image_path, ":t:r")
				vim.ui.input(
					{ prompt = "Enter new name (without extension): ", default = current_name },
					function(new_name)
						if not new_name or new_name == "" then
							vim.api.nvim_echo({ { "Rename cancelled", "WarningMsg" } }, false, {})
							return
						end
						local new_absolute_path = dir .. "/" .. new_name .. "." .. ext
						if vim.fn.filereadable(new_absolute_path) == 1 then
							vim.api.nvim_echo(
								{ { "File already exists: " .. new_absolute_path, "ErrorMsg" } },
								false,
								{}
							)
							return
						end
						local success, err = os.rename(absolute_image_path, new_absolute_path)
						if success then
							local old_filename = vim.fn.fnamemodify(absolute_image_path, ":t")
							local new_filename = vim.fn.fnamemodify(new_absolute_path, ":t")
							local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
							for i = 0, #lines - 1 do
								local line = lines[i + 1]
								local img_start, img_end = line:find("!%[.-%]%(.-%)")
								if img_start and img_end then
									local markdown_part = line:match("!%[.-%]%(.-%)")
									local escaped_old = old_filename:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")
									local escaped_new = new_filename:gsub("[%%]", "%%%%")
									local new_markdown = markdown_part:gsub(escaped_old, escaped_new)
									vim.api.nvim_buf_set_text(
										0,
										i,
										img_start - 1,
										i,
										img_start + #markdown_part - 1,
										{ new_markdown }
									)
								end
							end
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
