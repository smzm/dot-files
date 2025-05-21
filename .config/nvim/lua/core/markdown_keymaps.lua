-------------------------------------------------------------------------------
--                       Markdown keymaps
-------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>> Smart markdown link opener

-- Helper function to check if a line is inside a code block using Tree-sitter
local function is_line_in_code_block(bufnr, lnum)
	if not vim.treesitter or not vim.treesitter.get_parser then
		vim.schedule(function()
			vim.notify("Tree-sitter not available for code block check.", vim.log.levels.DEBUG)
		end)
		return false
	end
	local lang = vim.bo[bufnr].filetype -- Get language from buffer, default to 'markdown'
	if lang ~= "markdown" and lang ~= "md" then -- Ensure it's a markdown file type
		-- If we are in a non-markdown file (e.g. after opening a .py file from a link)
		-- this check isn't relevant, or we'd need the specific parser for that file.
		-- For now, let's assume headers in non-markdown files aren't what we're targeting with this logic.
		return false
	end

	local parser = vim.treesitter.get_parser(bufnr, "markdown") -- Explicitly use markdown parser
	if not parser then
		vim.schedule(function()
			vim.notify("Markdown Tree-sitter parser not available for buffer " .. bufnr, vim.log.levels.DEBUG)
		end)
		return false
	end

	local tree = parser:parse()[1]
	if not tree then
		return false
	end
	local root = tree:root()
	if not root then
		return false
	end

	-- Get the node at the beginning of the line (lnum is 1-indexed, TS is 0-indexed)
	local node = root:named_descendant_for_range(lnum - 1, 0, lnum - 1, 0)
	if not node then
		return false
	end

	local current_node = node
	while current_node do
		local node_type = current_node:type()
		if node_type == "fenced_code_block" or node_type == "indented_code_block" then
			return true
		end
		-- Stop if we hit a block-level element that isn't a code block,
		-- or if we reach too high up the tree without finding a code block.
		-- This prevents checking parents unnecessarily if the node itself is e.g. a paragraph.
		if current_node:parent() == root and node_type ~= "document" then -- 'document' is often the root node type
			-- If the direct child of root is not a code block, then this line isn't in one.
			-- This check can be refined based on specific tree structures.
			break
		end
		current_node = current_node:parent()
	end
	return false
end

-- Function to search for an anchor, skipping those in code blocks
local function search_markdown_anchor(anchor_pattern, bufnr)
	local original_cursor_pos = vim.api.nvim_win_get_cursor(0) -- {row, col} 0-indexed for API
	local found_valid_match = false

	-- Start search from the top of the buffer for consistency
	vim.api.nvim_win_set_cursor(0, { 1, 0 }) -- API cursor is 1-indexed for row

	while true do
		local current_search_line = vim.fn.search(anchor_pattern, "W") -- 'W' means don't wrap, returns line nr or 0
		if current_search_line == 0 then
			break -- No more matches
		end

		-- vim.fn.search() returns 1-indexed line number
		if not is_line_in_code_block(bufnr, current_search_line) then
			-- Found a valid header not in a code block.
			-- vim.fn.search() already moved the cursor to the match.
			found_valid_match = true
			break
		end

		-- Match was in a code block, continue search from the next line
		-- Move cursor to ensure search() continues from after the current invalid match
		if current_search_line == vim.api.nvim_buf_line_count(bufnr) then
			break -- Was last line and in code block, no further matches possible
		end
		vim.api.nvim_win_set_cursor(0, { current_search_line + 1, 0 })
	end

	if not found_valid_match then
		vim.api.nvim_win_set_cursor(0, original_cursor_pos) -- Restore cursor if no valid match found
		return false
	end
	return true -- Cursor is on the valid match
end

vim.keymap.set("n", "gl", function()
	local line = vim.fn.getline(".")
	local link_target = line:match("%[.-%]%((.-)%)")

	if not link_target then
		vim.notify("No markdown link found on this line.", vim.log.levels.WARN)
		return
	end

	if link_target:match("^https?://") then
		vim.notify("Opening in browser: " .. link_target, vim.log.levels.INFO)
		if vim.ui.open then
			vim.ui.open(link_target)
		else
			local cmd
			if vim.fn.has("macunix") then
				cmd = { "open", link_target }
			elseif vim.fn.has("win32") or vim.fn.has("win64") then
				cmd = { "cmd", "/c", "start", "", link_target }
			else
				cmd = { "xdg-open", link_target }
			end
			local job_id = vim.fn.jobstart(cmd, { detach = true })
			if not (job_id and job_id > 0) and job_id ~= nil then
				vim.notify("Failed to start browser command for: " .. link_target, vim.log.levels.ERROR)
			end
		end
		return
	end

	local path, anchor = link_target:match("([^#]*)#?(.*)")
	local current_bufnr = vim.api.nvim_get_current_buf()

	if path == "" then
		if anchor ~= "" then
			local anchor_pattern = "\\v^#{1,6}\\s.*\\c" .. vim.fn.escape(anchor:gsub("-", "[ -]?"), "\\")
			-- MODIFIED SECTION for current file anchor search
			if not search_markdown_anchor(anchor_pattern, current_bufnr) then
				vim.notify(
					"Anchor #" .. anchor .. " not found (or all in code blocks) in current file.",
					vim.log.levels.WARN
				)
			end
		else
			vim.notify("Empty local link target.", vim.log.levels.WARN)
		end
	else
		local file_to_open
		if path:match("^%./") or path:match("^%../") then
			local current_file_path = vim.fn.expand("%:p")
			if current_file_path == "" then
				vim.notify("Cannot resolve relative path: current buffer has no name.", vim.log.levels.ERROR)
				return
			end
			local current_dir = vim.fn.fnamemodify(current_file_path, ":h")
			file_to_open = vim.fn.simplify(current_dir .. "/" .. path)
		elseif not path:match("^/") and not path:match("^[a-zA-Z]:\\") then
			local current_file_path = vim.fn.expand("%:p")
			if current_file_path ~= "" then
				local current_dir = vim.fn.fnamemodify(current_file_path, ":h")
				local potential_path = vim.fn.simplify(current_dir .. "/" .. path)
				if vim.fn.filereadable(potential_path) == 1 or vim.fn.isdirectory(potential_path) == 1 then
					file_to_open = potential_path
				else
					file_to_open = path
				end
			else
				file_to_open = path
			end
		else
			file_to_open = path
		end

		if vim.fn.filereadable(file_to_open) == 1 or vim.fn.isdirectory(file_to_open) == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(file_to_open))
			-- After opening the file, its buffer becomes the current buffer
			local target_bufnr = vim.api.nvim_get_current_buf()

			if anchor ~= "" then
				-- Ensure the filetype is set correctly for Tree-sitter to work,
				-- especially if it was just opened.
				vim.cmd("doautocmd BufRead") -- Or more specifically filetype detection
				vim.api.nvim_command("set filetype=markdown") -- Force if necessary and known

				local anchor_pattern = "\\v^#{1,6}\\s.*\\c" .. vim.fn.escape(anchor:gsub("-", "[ -]?"), "\\")
				-- MODIFIED SECTION for other file anchor search
				if not search_markdown_anchor(anchor_pattern, target_bufnr) then
					vim.notify(
						"Anchor #" .. anchor .. " not found (or all in code blocks) in " .. file_to_open,
						vim.log.levels.WARN
					)
				end
			end
		else
			vim.notify("File not found: " .. file_to_open, vim.log.levels.ERROR)
		end
	end
end, { desc = "Open markdown link (skip code blocks for anchors)", noremap = true, silent = true }) -- Updated desc

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

-- >>>>>>>>>>>>>>>>>>>>>>>> Copy Markdown link to current header
vim.keymap.set("n", "<leader>mc", function()
	-- Get the current line under the cursor
	local line = vim.fn.getline(".")

	-- Strip leading '#' and any spaces to get the actual header text
	local header_text = line:gsub("^#+%s*", "")

	-- Create GitHub-style anchor following the specified rules:
	local anchor = header_text
		:lower()
		-- Specific pre-processing to match the example output's quirks
		:gsub("['’]", "") -- Remove apostrophes (e.g., "don't" -> "dont")
		:gsub("[()]", "") -- Remove parentheses (e.g., "reshape()" -> "reshape")
		:gsub(",", "") -- Remove commas
		-- At this point, for your example, header would be like:
		-- "changing shape of array but dont change data  :reshape" (assuming no space after colon in input for this exact output)
		-- or "changing shape of array but dont change data  : reshape" if space was there
		-- Now, the transformation to hyphens
		:gsub(
			":",
			"-"
		) -- Explicitly convert colons to hyphens
		:gsub("%s+", "-") -- Convert spaces to hyphens
		:gsub("-+", "-") -- Collapse multiple hyphens
		:gsub("^%-+", "")
		:gsub("%-+$", "")

	-- Get current file name only (e.g., "series.md")
	local filename = vim.fn.expand("%:t")
	if filename == "" then
		filename = "untitled.md" -- Fallback if buffer has no name
		print("Warning: Buffer has no name, using 'untitled.md' for link.")
	end

	-- Build the final Markdown link
	local link = string.format("[%s](./%s#%s)", header_text, filename, anchor)

	-- Copy to clipboard
	vim.fn.setreg("+", link)

	-- Show message
	print("Copied: " .. link)
end, { desc = "Copy Markdown link to current header (GitHub style)" })
