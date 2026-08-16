return {
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> supermaven
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<M-l>",
					clear_suggestion = "<C-]>",
					accept_word = "<C-l>",
				},
				-- ignore_filetypes = { md = true },
				-- color = {
				-- 	suggestion_color = "#ffffff",
				-- 	cterm = 244,
				-- },
			})
		end,
	},

	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> opencode
	{
		"nickjvandyke/opencode.nvim",
		version = "*",

		dependencies = {
			{
				"folke/snacks.nvim",
				optional = true,

				opts = {
					input = {},

					picker = {
						actions = {
							opencode_send = function(...)
								return require("opencode").snacks_picker_send(...)
							end,
						},

						win = {
							input = {
								keys = {
									["<a-a>"] = {
										"opencode_send",
										mode = { "n", "i" },
									},
								},
							},
						},
					},
				},
			},
		},

		config = function()
			local opencode = require("opencode")
			local Snacks = require("snacks")

			-- =========================================================
			-- OpenCode
			-- =========================================================

			local OPENCODE_CMD = "opencode --port"

			local OPENCODE_WIN = {
				position = "float",

				width = 0.90,
				height = 0.90,

				border = "rounded",

				title = " 󰚩 OpenCode ",
				title_pos = "center",

				wo = {
					winblend = 0,
				},
			}

			---@type opencode.Opts
			vim.g.opencode_opts = {
				server = {
					start = function()
						Snacks.terminal.open(OPENCODE_CMD, {
							win = OPENCODE_WIN,
						})
					end,
				},
			}

			-- Required for opencode.nvim events.reload
			vim.o.autoread = true

			-- =========================================================
			-- Toggle OpenCode
			-- =========================================================

			local function toggle_opencode()
				Snacks.terminal.toggle(OPENCODE_CMD, {
					win = OPENCODE_WIN,
				})
			end

			-- Normal mode
			vim.keymap.set("n", "<localleader><localleader>", toggle_opencode, {
				desc = "Toggle OpenCode",
			})

			-- Terminal mode
			--
			-- Snacks terminals start in insert mode by default.
			-- This mapping allows <localleader><localleader> to work
			-- without pressing <Esc> first.
			vim.keymap.set("t", "<localleader><localleader>", function()
				Snacks.terminal.toggle(OPENCODE_CMD, {
					win = OPENCODE_WIN,
				})
			end, {
				desc = "Toggle OpenCode",
			})

			-- =========================================================
			-- Ask OpenCode
			-- =========================================================

			vim.keymap.set({ "n", "x" }, "<localleader>o", function()
				opencode.ask("@this: ")
			end, {
				desc = "Ask OpenCode…",
			})

			-- =========================================================
			-- Send range to OpenCode
			-- =========================================================

			vim.keymap.set({ "n", "x" }, "<localleader>go", function()
				return opencode.operator("@this ")
			end, {
				desc = "Append range to OpenCode",
				expr = true,
			})

			-- =========================================================
			-- Send current line to OpenCode
			-- =========================================================

			vim.keymap.set("n", "goo", function()
				return opencode.operator("@this ") .. "_"
			end, {
				desc = "Append line to OpenCode",
				expr = true,
			})

			-- =========================================================
			-- Scroll OpenCode
			-- =========================================================

			vim.keymap.set("n", "<S-C-u>", function()
				opencode.command("session.half.page.up")
			end, {
				desc = "Scroll OpenCode up",
			})

			vim.keymap.set("n", "<S-C-d>", function()
				opencode.command("session.half.page.down")
			end, {
				desc = "Scroll OpenCode down",
			})
		end,
	},
}
