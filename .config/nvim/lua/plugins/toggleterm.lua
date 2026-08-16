return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",

		config = function()
			-- =========================================================
			-- Environment
			-- =========================================================

			vim.env.IN_TOGGLETERM = "true"

			-- =========================================================
			-- Terminal keymaps
			-- =========================================================

			local function set_terminal_keymaps()
				local opts = {
					noremap = true,
					silent = true,
					buffer = true,
				}

				vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
				vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
				vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
				vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
			end

			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*toggleterm#*",
				callback = set_terminal_keymaps,
			})

			-- =========================================================
			-- ToggleTerm setup
			-- =========================================================

			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return math.floor(vim.o.columns * 0.4)
					end

					return 20
				end,

				open_mapping = [[<F12>]],

				start_in_insert = true,
				insert_mappings = true,

				persist_mode = false,
				persist_size = true,

				direction = "float",

				close_on_exit = true,

				shell = vim.o.shell,

				highlights = {
					Normal = {
						guibg = "#15141b",
						guifg = "NONE",
					},

					NormalFloat = {
						guibg = "#15141b",
						guifg = "NONE",
					},

					FloatBorder = {
						guibg = "#15141b",
						guifg = "#6e6a7c",
					},
				},

				shade_filetypes = {},
				shade_terminals = false,
				shading_factor = 1,

				float_opts = {
					border = "curved",

					width = math.floor(0.8 * vim.o.columns),
					height = math.floor(0.9 * vim.o.lines),

					winblend = 4,
				},

				winbar = {
					enabled = true,
				},
			})

			-- =========================================================
			-- Terminal objects
			-- =========================================================

			local Terminal = require("toggleterm.terminal").Terminal

			-- ---------------------------------------------------------
			-- Terminal 1: Normal shell
			-- ---------------------------------------------------------

			local shell = Terminal:new({
				direction = "float",

				-- Keep the terminal/process alive when hidden.
				close_on_exit = false,
			})

			-- ---------------------------------------------------------
			-- Terminal 2: OpenCode
			-- ---------------------------------------------------------

			local opencode = Terminal:new({
				cmd = "opencode",
				direction = "float",

				-- Keep OpenCode alive when the window is hidden.
				close_on_exit = false,
			})

			-- ---------------------------------------------------------
			-- Terminal 3: OMP
			-- ---------------------------------------------------------

			local omp = Terminal:new({
				cmd = "omp",
				direction = "float",

				-- Keep OMP alive when the window is hidden.
				close_on_exit = false,
			})

			-- =========================================================
			-- Named terminal keymaps
			--
			-- Your localleader is '\'
			--
			-- \1 -> shell
			-- \2 -> OpenCode
			-- \3 -> OMP
			-- =========================================================

			vim.keymap.set("n", "<localleader>t", function()
				shell:toggle()
			end, {
				desc = "Shell terminal",
			})

			vim.keymap.set("n", "<localleader>o", function()
				opencode:toggle()
			end, {
				desc = "OpenCode terminal",
			})

			vim.keymap.set("n", "<localleader>p", function()
				omp:toggle()
			end, {
				desc = "OMP terminal",
			})

			-- =========================================================
			-- Current buffer directory terminal
			-- =========================================================

			local function buf_dir()
				local dir = vim.fn.expand("%:p:h")

				-- Unnamed buffer -> current working directory
				if dir == nil or dir == "" or dir == "." then
					dir = vim.uv.cwd()
				end

				-- Resolve symlinks when possible
				local real = vim.uv.fs_realpath(dir)

				return real or dir
			end

			local cwd_terminal

			local function cwd_toggle()
				local dir = buf_dir()

				if not cwd_terminal then
					cwd_terminal = Terminal:new({
						direction = "float",
						dir = dir,
						close_on_exit = false,
					})
				else
					cwd_terminal.dir = dir
				end

				cwd_terminal:toggle()
			end

			vim.keymap.set("n", "<leader><F12>", cwd_toggle, {
				desc = "Open buffer directory terminal",
			})

			-- =========================================================
			-- Generic ToggleTerm terminals
			-- =========================================================

			vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", {
				desc = "Terminal float",
			})

			vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", {
				desc = "Terminal horizontal",
			})

			vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", {
				desc = "Terminal vertical",
			})

			vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=tab<CR>", {
				desc = "Terminal tab",
			})

			-- =========================================================
			-- Numbered generic ToggleTerm terminals
			-- =========================================================

			vim.keymap.set("n", "<leader>t1", "<cmd>1ToggleTerm<CR>", {
				desc = "Toggle terminal #1",
			})

			vim.keymap.set("n", "<leader>t2", "<cmd>2ToggleTerm<CR>", {
				desc = "Toggle terminal #2",
			})

			vim.keymap.set("n", "<leader>t3", "<cmd>3ToggleTerm<CR>", {
				desc = "Toggle terminal #3",
			})

			vim.keymap.set("n", "<leader>t4", "<cmd>4ToggleTerm<CR>", {
				desc = "Toggle terminal #4",
			})
		end,
	},
}
