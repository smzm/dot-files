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

-- -- >>>>>>>>>>>>>>>>>>>>>>>> Markdown link creator with file generation functionality
-- Markdown link creator with file generation functionality

-- Define the markdown link creator function
local function markdown_link_creator()
	-- Get visual selection
	local function get_visual_selection()
		local reg_save = vim.fn.getreg('"')
		local regtype_save = vim.fn.getregtype('"')
		vim.cmd("normal! `<v`>y") -- Yank visual selection
		local selection = vim.fn.getreg('"')
		vim.fn.setreg('"', reg_save, regtype_save) -- Restore previous register content
		return selection
	end

	local raw_visual_selection = get_visual_selection()
	if not raw_visual_selection or raw_visual_selection == "" then
		vim.notify("No text selected.", vim.log.levels.ERROR)
		return
	end

	-- Process selection: trim, replace newlines with spaces for link text and filename generation
	local processed_selection = raw_visual_selection:gsub("\n", " "):match("^%s*(.-)%s*$")
	if not processed_selection or processed_selection == "" then
		vim.notify("Selection is empty after processing.", vim.log.levels.ERROR)
		return
	end

	local suggested_filename_base
	local display_text_for_link = processed_selection -- Default display text is the processed selection
	local header_slug_for_link -- For #header part, e.g., "my-section-title"

	-- Check for special "text#header" pattern in the processed selection
	if string.find(processed_selection, "#") then
		local parts = vim.split(processed_selection, "#", { plain = true }) -- Keep all parts, check #parts later
		if #parts >= 2 then
			-- Extract and clean text for file part and header part
			local file_text_part = (parts[1] or ""):gsub("[{}]", ""):match("^%s*(.-)%s*$")
			local header_text_part = (parts[2] or ""):gsub("[{}]", ""):match("^%s*(.-)%s*$")

			if file_text_part == "" then -- Header part can exist alone if selection is like "#myheader"
				vim.notify(
					"Warning: 'text#header' format has empty text part. Using full selection for filename.",
					vim.log.levels.WARN
				)
				suggested_filename_base = processed_selection:gsub("#", "_"):gsub("%s+", "_"):lower() -- replace # too
				display_text_for_link = processed_selection
			else
				suggested_filename_base = file_text_part:gsub("%s+", "_"):lower()
				display_text_for_link = file_text_part -- Text before # is the primary display text for the link
				if header_text_part ~= "" then
					header_slug_for_link = header_text_part:gsub("%s+", "-"):lower() -- slug for #header
				end
			end
		else
			-- '#' found but not in a clear 'text#header' structure (e.g., "text#", "#header" alone might be handled by above if parts[1] is empty)
			vim.notify(
				"Warning: '#' found but not in valid 'text#header' format. Treating as literal.",
				vim.log.levels.WARN
			)
			suggested_filename_base = processed_selection:gsub("%s+", "_"):lower()
			display_text_for_link = processed_selection
		end
	else
		-- No '#' in selection, simple case
		suggested_filename_base = processed_selection:gsub("%s+", "_"):lower()
		display_text_for_link = processed_selection
	end

	if not suggested_filename_base or suggested_filename_base == "" then
		-- This case should ideally be caught by processed_selection check, but as a safeguard:
		suggested_filename_base = "unnamed_file" -- Default if somehow previous logic fails
		vim.notify("Could not determine filename base from selection, using default.", vim.log.levels.WARN)
	end

	local suggested_file_path_default = "./" .. suggested_filename_base .. ".md"

	vim.ui.input({
		prompt = "File path for Markdown link: ",
		default = suggested_file_path_default,
		completion = "file",
	}, function(user_input_path)
		if not user_input_path or user_input_path == "" then
			vim.notify("File path input cancelled or empty.", vim.log.levels.INFO)
			return
		end

		local final_user_path = user_input_path
		if not final_user_path:match("%.md$") then
			final_user_path = final_user_path .. ".md"
		end

		local current_buffer_dir = vim.fn.expand("%:p:h")
		local fs_target_path -- Full path for file system ops (e.g., /abs/path/to/file.md)
		local link_target_uri -- Path used in Markdown link [](...) (e.g., ./file.md or /abs/path/file.md)

		if final_user_path:match("^/") or final_user_path:match("^[a-zA-Z]:[\\/]") then -- Absolute path (Unix or Windows)
			fs_target_path = final_user_path
			link_target_uri = final_user_path
		else -- Relative path
			fs_target_path = current_buffer_dir .. "/" .. final_user_path
			link_target_uri = final_user_path
			-- Ensure relative link_target_uri starts with "./" if it's not "../"
			if not link_target_uri:match("^%./") and not link_target_uri:match("^%../") then
				link_target_uri = "./" .. link_target_uri
			end
		end

		fs_target_path = vim.fn.fnamemodify(fs_target_path, ":p") -- Resolve to absolute, clean path

		-- Check if fs_target_path resolved to something sensible (not just the current dir path itself if input was empty or just "./")
		if
			fs_target_path == ""
			or fs_target_path == vim.fn.fnamemodify(current_buffer_dir, ":p")
			or fs_target_path == vim.fn.fnamemodify(current_buffer_dir .. "/", ":p")
		then
			vim.notify("Invalid or empty file path processed: " .. user_input_path, vim.log.levels.ERROR)
			return
		end

		local markdown_link_string = "[" .. display_text_for_link .. "](" .. link_target_uri
		if header_slug_for_link then
			markdown_link_string = markdown_link_string .. "#" .. header_slug_for_link
		end
		markdown_link_string = markdown_link_string .. ")"

		-- Replace the original visual selection with the generated markdown link
		-- The keymap calls the Lua function using :<C-u>lua ... which means we are in command line mode.
		-- The visual marks '< and '> are set from the visual mode selection.
		vim.cmd("normal! `<v`>d") -- Delete characters in the original visual selection range
		vim.api.nvim_put({ markdown_link_string }, "c", false, true) -- Insert new text at cursor (false=before cursor, true=move cursor after)

		-- Create the file if it doesn't exist
		local file_exists = vim.fn.filereadable(fs_target_path) == 1
		if not file_exists then
			local dir_to_create = vim.fn.fnamemodify(fs_target_path, ":h")
			-- Check if dir_to_create is not "." (current dir) or an empty string
			if dir_to_create ~= "." and dir_to_create ~= "" and vim.fn.isdirectory(dir_to_create) == 0 then
				vim.fn.mkdir(dir_to_create, "p") -- Create parent directories if they don't exist
				if vim.fn.isdirectory(dir_to_create) == 0 then
					vim.notify("Failed to create directory: " .. dir_to_create, vim.log.levels.ERROR)
					return
				end
			end

			-- Generate title for the new file based on the filename part of fs_target_path
			local file_content_title_base = vim.fn.fnamemodify(fs_target_path, ":t:r")
			local title_for_file = file_content_title_base:gsub("[_-]", " ") -- Replace underscores/hyphens with spaces
			title_for_file = title_for_file:match("^%s*(.-)%s*$") -- Trim whitespace
			if #title_for_file > 0 then
				title_for_file = title_for_file:sub(1, 1):upper() .. title_for_file:sub(2) -- Capitalize first letter
			else
				title_for_file = "Untitled" -- Default title if base is empty
			end

			local ok, err = pcall(function()
				local file = io.open(fs_target_path, "w")
				if not file then
					error("Cannot open file for writing.")
				end
				file:write("# " .. title_for_file .. "\n") -- Add a newline after the header
				file:close()
			end)

			if not ok then
				vim.notify("Failed to create file: " .. fs_target_path .. " (" .. err .. ")", vim.log.levels.ERROR)
				return
			else
				vim.notify("Created file: " .. fs_target_path, vim.log.levels.INFO)
			end
		end

		-- Open the file in a vertical split
		vim.api.nvim_command("vsplit " .. vim.fn.fnameescape(fs_target_path))
	end)
end

-- Make the function globally available
_G.markdown_link_creator = markdown_link_creator

-- Set up the keybinding for markdown files only
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Map <leader>ml in visual mode for markdown files
		vim.api.nvim_buf_set_keymap(
			0, -- Buffer handle 0 for current buffer
			"v", -- Visual mode
			"<leader>ml",
			":<C-u>lua _G.markdown_link_creator()<CR>",
			{ noremap = true, silent = true, desc = "Create markdown link and file from selection" }
		)
	end,
})

-- -- >>>>>>>>>>>>>>>>>>>>>>>>  Function to toggle markdown task checkbox
local function toggle_markdown_task()
	local line = vim.api.nvim_get_current_line()

	-- Check if line contains an unchecked task
	if line:match("^%s*-%s*%[%s*%]") then
		-- Replace [ ] with [x]
		local new_line = line:gsub("^(%s*-%s*)%[%s*%]", "%1[x]")
		vim.api.nvim_set_current_line(new_line)
	-- Check if line contains a checked task
	elseif line:match("^%s*-%s*%[x%]") or line:match("^%s*-%s*%[X%]") then
		-- Replace [x] or [X] with [ ]
		local new_line = line:gsub("^(%s*-%s*)%[[xX]%]", "%1[]")
		vim.api.nvim_set_current_line(new_line)
	end
end

-- Create keymap only for markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.keymap.set("n", "<leader>tt", toggle_markdown_task, {
			buffer = true,
			desc = "Toggle markdown task checkbox",
			silent = true,
		})
	end,
})
