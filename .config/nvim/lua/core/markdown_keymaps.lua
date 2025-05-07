-------------------------------------------------------------------------------
--                       Markdown keymaps
-------------------------------------------------------------------------------

-- >>>>>>>>>>>>>>>>>>>>>>>> Smart markdown link opener
vim.keymap.set("n", "gl", function()
	local line = vim.fn.getline(".")
	local link = line:match("%[.-%]%((.-)%)")
	if not link then
		return
	end

	local path, anchor = link:match("([^#]*)#?(.*)")

	if path == "" then
		-- Inline anchor: stay in current buffer
		if anchor ~= "" then
			-- Match markdown headers that start with #
			local anchor_pattern = "\\v^#{1,6}\\s.*" .. anchor:gsub("-", ".*")
			vim.fn.search(anchor_pattern, "w")
		end
	else
		-- Handle relative paths
		if path:match("^%.") then
			-- Path starts with ./ or ../ (relative path)
			local current_file = vim.fn.expand("%:p")
			local current_dir = vim.fn.fnamemodify(current_file, ":h")
			local absolute_path = vim.fn.simplify(current_dir .. "/" .. path)
			vim.cmd("edit " .. absolute_path)
		else
			-- Absolute path or path without leading ./
			vim.cmd("edit " .. path)
		end

		-- Jump to anchor if present
		if anchor ~= "" then
			local anchor_pattern = "\\v^#{1,6}\\s.*" .. anchor:gsub("-", ".*")
			vim.fn.search(anchor_pattern, "w")
		end
	end
end, { desc = "Open markdown link and jump to anchor", noremap = true, silent = true })

-- -- >>>>>>>>>>>>>>>>>>>>>>>> Markdown link creator with file generation functionality
-- Markdown link creator with file generation functionality

-- Define the markdown link creator function
local function markdown_link_creator()
	-- Get visual selection
	local function get_visual_selection()
		-- Save current register content
		local reg_save = vim.fn.getreg('"')
		local regtype_save = vim.fn.getregtype('"')

		-- Yank the visual selection into the unnamed register
		vim.cmd("normal! `<v`>y")

		-- Get the content
		local selection = vim.fn.getreg('"')

		-- Restore register content
		vim.fn.setreg('"', reg_save, regtype_save)

		return selection
	end

	-- Get the selected text
	local selected_text = get_visual_selection()
	if not selected_text or selected_text == "" then
		vim.notify("No text selected", vim.log.levels.ERROR)
		return
	end

	-- Get the current file directory
	local current_dir = vim.fn.expand("%:p:h")

	local link_text, file_name, header_text

	-- Check if the text contains a # character (special pattern)
	if string.find(selected_text, "#") then
		-- Split by #
		local parts = vim.split(selected_text, "#", { plain = true })
		if #parts < 2 then
			vim.notify("Invalid format. Expected text#header", vim.log.levels.ERROR)
			return
		end

		-- Extract file name (before #) and header text (after #)
		file_name = parts[1]
		header_text = parts[2]

		-- Strip braces from file_name if present
		file_name = file_name:gsub("{", ""):gsub("}", "")
		-- Strip braces from header_text if present
		header_text = header_text:gsub("{", ""):gsub("}", "")

		-- Trim whitespace
		file_name = file_name:match("^%s*(.-)%s*$")
		header_text = header_text:match("^%s*(.-)%s*$")

		-- Replace spaces with underscores in file_name and make lowercase
		file_name = file_name:gsub("%s+", "_"):lower()

		-- Replace spaces with hyphens in header_text
		header_text = header_text:gsub("%s+", "-")

		-- Store the original header text for display in brackets
		local display_text = header_text:gsub("-", " ")

		-- Create markdown link - preserve spaces in display text, use hyphenated version in URL
		link_text = "[" .. display_text .. "](./" .. file_name .. ".md#" .. header_text .. ")"
	else
		-- Simple case - just create a direct link

		-- Trim whitespace from the selected text before processing
		local trimmed_text = selected_text:match("^%s*(.-)%s*$")

		-- Keep the original trimmed text for display
		link_text = trimmed_text

		-- Replace spaces with underscores for the file name and make lowercase
		file_name = trimmed_text:gsub("%s+", "_"):lower()

		-- Create markdown link
		link_text = "[" .. trimmed_text .. "](./" .. file_name .. ".md)"
	end

	-- Delete the selected text and replace it with the markdown link
	-- Ensure there's a space before and after the link
	vim.cmd("normal! `<v`>d")

	-- Check if there was a space before the selection
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local col = cursor_pos[2]

	local pre_space = ""
	local post_space = ""

	-- Add space before if needed
	if col > 0 and line:sub(col, col) ~= " " then
		pre_space = " "
	end

	-- Add space after if needed
	if col < #line and line:sub(col + 1, col + 1) ~= " " then
		post_space = " "
	end

	-- Insert the link with proper spacing
	vim.api.nvim_put({ pre_space .. link_text .. post_space }, "c", false, true)

	-- Create the file if it doesn't exist
	local file_path = current_dir .. "/" .. file_name .. ".md"
	local file = io.open(file_path, "r")
	if not file then
		-- File doesn't exist, create it
		file = io.open(file_path, "w")
		if file then
			file:write("# " .. file_name:gsub("_", " "):gsub("^%l", string.upper))
			file:close()
		else
			vim.notify("Failed to create file: " .. file_path, vim.log.levels.ERROR)
			return
		end
	else
		file:close()
	end

	-- Open the file in a vertical split
	vim.cmd("vsplit " .. file_path)
end

-- Set up the keybinding for markdown files only
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Map <leader>p in visual mode for markdown files
		vim.api.nvim_buf_set_keymap(
			0,
			"v",
			"<leader>ml",
			":<C-u>lua _G.markdown_link_creator()<CR>",
			{ noremap = true, silent = true, desc = "Create markdown link from selection" }
		)
	end,
})

-- Make the function globally available
_G.markdown_link_creator = markdown_link_creator
