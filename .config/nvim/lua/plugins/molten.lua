return {
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
		vim.keymap.set("n", "<localleader>mp", ":MoltenImagePopup<CR>", { silent = true, desc = "molten image popup" })
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
		vim.keymap.set("n", "<localleader>mu", ":MoltenReevaluateAll<CR>", { silent = true, desc = "Re-evaluate all" })
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
}
