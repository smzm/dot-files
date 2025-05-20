-------------------------------------------------------------------------------
--                       Markdown keymaps
-------------------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>> Smart markdown link opener
vim.keymap.set("n", "gl", function()
	local line = vim.fn.getline(".")
	local link_target = line:match("%[.-%]%((.-)%)") -- This is the full content within ()

	if not link_target then
		vim.notify("No markdown link found on this line.", vim.log.levels.WARN)
		return
	end

	-- Check for web link first, using the full link_target
	if link_target:match("^https?://") then
		vim.notify("Opening in browser: " .. link_target, vim.log.levels.INFO)
		if vim.ui.open then -- Preferred method for Neovim 0.8+
			vim.ui.open(link_target)
		else
			-- Fallback for older Neovim or if vim.ui.open is not configured
			local cmd
			if vim.fn.has("macunix") then
				cmd = { "open", link_target }
			elseif vim.fn.has("win32") or vim.fn.has("win64") then
				-- 'explorer' often works well for URLs directly.
				-- 'start' might need `cmd /c start ""` if the URL has spaces,
				-- so we add an empty title argument for 'start'.
				cmd = { "cmd", "/c", "start", "", link_target }
				-- Alternative for Windows: cmd = {"explorer", link_target}
			else -- Assume Linux/BSD
				cmd = { "xdg-open", link_target }
			end
			local job_id = vim.fn.jobstart(cmd, { detach = true })
			-- jobstart returns a positive job ID on success, or nil if detached immediately
			-- and the command is likely to succeed quickly.
			-- It returns 0 or -1 on failure to start.
			if not (job_id and job_id > 0) and job_id ~= nil then
				vim.notify("Failed to start browser command for: " .. link_target, vim.log.levels.ERROR)
			end
		end
		return -- We've handled the web link
	end

	-- If not a web link, proceed with local file/anchor logic
	-- Now, split the link_target into path and anchor for local navigation
	local path, anchor = link_target:match("([^#]*)#?(.*)")

	if path == "" then
		-- Inline anchor: stay in current buffer
		if anchor ~= "" then
			local anchor_pattern = "\\v^#{1,6}\\s.*" .. anchor:gsub("-", "[ -]?") -- Allow space or hyphen
			if vim.fn.search(anchor_pattern, "w") == 0 then
				vim.notify("Anchor #" .. anchor .. " not found in current file.", vim.log.levels.WARN)
			end
		else
			vim.notify("Empty local link target.", vim.log.levels.WARN)
		end
	else
		-- Handle local file paths
		local file_to_open
		if path:match("^%./") or path:match("^%ऊं/") then -- Starts with ./ or ../
			local current_file_path = vim.fn.expand("%:p")
			if current_file_path == "" then
				vim.notify("Cannot resolve relative path: current buffer has no name.", vim.log.levels.ERROR)
				return
			end
			local current_dir = vim.fn.fnamemodify(current_file_path, ":h")
			file_to_open = vim.fn.simplify(current_dir .. "/" .. path)
		elseif not path:match("^/") and not path:match("^[a-zA-Z]:\\") then -- Not absolute, try relative to current file
			local current_file_path = vim.fn.expand("%:p")
			if current_file_path ~= "" then
				local current_dir = vim.fn.fnamodify(current_file_path, ":h")
				local potential_path = vim.fn.simplify(current_dir .. "/" .. path)
				if vim.fn.filereadable(potential_path) == 1 or vim.fn.isdirectory(potential_path) == 1 then
					file_to_open = potential_path
				else
					file_to_open = path -- Fallback to original path (could be relative to cwd)
				end
			else
				file_to_open = path -- No current file, assume relative to cwd or absolute
			end
		else
			-- Absolute path
			file_to_open = path
		end

		-- Check if the file exists before trying to open
		if vim.fn.filereadable(file_to_open) == 1 or vim.fn.isdirectory(file_to_open) == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(file_to_open))

			-- Jump to anchor if present
			if anchor ~= "" then
				local anchor_pattern = "\\v^#{1,6}\\s.*" .. anchor:gsub("-", "[ -]?") -- Allow space or hyphen
				if vim.fn.search(anchor_pattern, "w") == 0 then
					vim.notify("Anchor #" .. anchor .. " not found in " .. file_to_open, vim.log.levels.WARN)
				end
			end
		else
			vim.notify("File not found: " .. file_to_open, vim.log.levels.ERROR)
		end
	end
end, { desc = "Open markdown link (web links in browser, local in nvim)", noremap = true, silent = true })

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

	-- Create GitHub-style anchor: lowercase, hyphenated, no special chars
	local anchor = header_text
		:lower()
		:gsub("[^a-z0-9 -]", "") -- remove special characters
		:gsub("%s+", "-") -- spaces to dashes
		:gsub("-+", "-") -- collapse multiple dashes
		:gsub("^%-", "")
		:gsub("%-$", "") -- trim leading/trailing dashes

	-- Get current file name only (e.g., "series.md")
	local filename = vim.fn.expand("%:t")

	-- Build the final Markdown link
	local link = string.format("[%s](./%s#%s)", header_text, filename, anchor)

	-- Copy to clipboard
	vim.fn.setreg("+", link)

	-- Show message
	print("Copied: " .. link)
end, { desc = "Copy Markdown link to current header (clean)" })
