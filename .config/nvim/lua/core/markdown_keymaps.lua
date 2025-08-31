-------------------------------------------------------------------------------
--                       Markdown keymaps
-------------------------------------------------------------------------------
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
