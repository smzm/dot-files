return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },  -- Specify noice as a dependency
    config = function()

      local colors = {
          Purple="#a277ff",
          Purple2="#3d375e",
          Purple3="#29263c",
          Green="#61ffca",
          Orange="#ffca85",
          Pink="#f694ff",
          Blue="#82e2ff",
          Red="#ff6767",
          White="#edecee",
          Gray="#6d6d6d",
          Black="#15141b",
		}
    local aura_dark_theme = {
      normal = {
				a = { bg = colors.Purple3, fg = colors.Blue },
				b = { bg = colors.Black, fg = colors.Gray },
				c = { bg = colors.Black, fg = colors.Gray },
				x = { bg = colors.Purple3, fg = colors.Gray },
        y = { bg = colors.Purple3, fg = colors.Blue },
				z = { bg = colors.Purple3, fg = colors.Gray },
      },
      insert = {
        a = { bg = colors.Black, fg = colors.Green },
        b = { bg = colors.Black, fg = colors.Gray },
        c = { bg = colors.Black, fg = colors.Gray },
				x = { bg = colors.Purple3, fg = colors.Gray },
        y = { bg = colors.Purple3, fg = colors.Green },
				z = { bg = colors.Purple3, fg = colors.Gray },
      },
      visual = {
        a = { bg = colors.Black, fg = colors.bg, gui = "bold" },
        b = { bg = colors.Black, fg = colors.fg },
        c = { bg = colors.Black, fg = colors.fg },
				x = { bg = colors.Purple3, fg = colors.Gray },
        y = { bg = colors.Purple3, fg = colors.Pink },
				z = { bg = colors.Purple3, fg = colors.Gray },
      },
      command = {
        a = { bg = colors.Black, fg = colors.bg, gui = "bold" },
        b = { bg = colors.Black, fg = colors.fg },
        c = { bg = colors.Black, fg = colors.fg },
				x = { bg = colors.Purple3, fg = colors.Gray },
        y = { bg = colors.Purple3, fg = colors.Purple },
				z = { bg = colors.Purple3, fg = colors.Gray },
      },
      replace = {
        a = { bg = colors.Black, fg = colors.bg, gui = "bold" },
        b = { bg = colors.Black, fg = colors.fg },
        c = { bg = colors.Black, fg = colors.fg },
				x = { bg = colors.Purple3, fg = colors.Gray },
        y = { bg = colors.Purple3, fg = colors.Purple },
				z = { bg = colors.Purple3, fg = colors.Gray },
      },
      inactive = {
        a = { bg = colors.Black, fg = colors.semilightgray, gui = "bold" },
        b = { bg = colors.Black, fg = colors.semilightgray },
        c = { bg = colors.Black, fg = colors.semilightgray },
				x = { bg = colors.Purple3, fg = colors.Gray },
        y = { bg = colors.Purple3, fg = colors.Purple },
				z = { bg = colors.Purple3, fg = colors.Gray },
      },
    }

    local scrollbar = {
			function()
				local current_line = vim.fn.line(".")
				local total_lines = vim.fn.line("$")
				local chars = { "  ", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
				local line_ratio = current_line / total_lines
				local index = math.ceil(line_ratio * #chars)
				return chars[index]
			end,
			padding = { bottom = 0, left = 0,  right = 0 },
			color = { fg = colors.Purple3, bg = colors.Black },
			cond = nil,
		}

    local empty = require("lualine.component"):extend()
		function empty:draw(default_highlight)
			self.status = ""
			self.applied_separator = ""
			self:apply_highlights(default_highlight)
			self:apply_section_separators()
			return self.status
		end

		-- Put proper separators and gaps between components in sections
		local function process_sections(sections)
			for name, section in pairs(sections) do
				local left = name:sub(9, 10) < "x"
				for pos = 1, name ~= "lualine_z" and #section or #section - 1 do
					table.insert(section, pos * 2, { empty, color = { fg = colors.White, bg = colors.Black } })
				end
				for id, comp in ipairs(section) do
					if type(comp) ~= "table" then
						comp = { comp }
						section[id] = comp
					end
					comp.separator = left and { right = " " } or { left = " "} --  
				end
			end
			return sections
		end

      require('lualine').setup {
        options = {
          theme=aura_dark_theme,
          icons_enabled = true,
          component_separators = ' ',
          section_separators = ' ',
        },
        sections = process_sections({
          lualine_a = {},
          lualine_b = {},
          lualine_c = { },
          lualine_x= {'branch','diff', 'diagnostics'},
          lualine_y = {'filetype'},
          lualine_z = { scrollbar }
        })
      }
    end,
    lazy = true,
    event = "VeryLazy"  -- Customize the event based on when you want lualine to load
  }
}
