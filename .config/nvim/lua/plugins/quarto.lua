return {

	{ -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
		-- for complete functionality (language features)
		"quarto-dev/quarto-nvim",
		dev = false,
		opts = {
			lspFeatures = {
				enabled = true,
				chunks = "curly",
			},
			codeRunner = {
				enabled = true,
				default_method = "slime",
			},
		},
		dependencies = {
			-- for language features in code cells
			-- configured in lua/plugins/lsp.lua
			"jmbuhr/otter.nvim",
		},
	},

	{ -- directly open ipynb files as quarto docuements
		-- and convert back behind the scenes
		"GCBallesteros/jupytext.nvim",
		opts = {
			custom_language_formatting = {
				python = {
					extension = "qmd",
					style = "quarto",
					force_ft = "quarto",
				},
				r = {
					extension = "qmd",
					style = "quarto",
					force_ft = "quarto",
				},
			},
		},
	},

	{ -- paste an image from the clipboard or drag-and-drop
		"HakonHarnes/img-clip.nvim",
		event = "BufEnter",
		ft = { "markdown", "quarto", "latex" },
		opts = {
			default = {
				dir_path = "img",
			},
			filetypes = {
				markdown = {
					url_encode_path = true,
					template = "![$CURSOR]($FILE_PATH)",
					drag_and_drop = {
						download_images = false,
					},
				},
				quarto = {
					url_encode_path = true,
					template = "![$CURSOR]($FILE_PATH)",
					drag_and_drop = {
						download_images = false,
					},
				},
			},
		},
		config = function(_, opts)
			require("img-clip").setup(opts)
			vim.keymap.set("n", "<leader>ii", ":PasteImage<cr>", { desc = "insert [i]mage from clipboard" })
		end,
	},

	{ -- preview equations
		"jbyuki/nabla.nvim",
		keys = {
			{ "<leader>qm", ':lua require"nabla".toggle_virt()<cr>', desc = "toggle [m]ath equations" },
		},
	},
	-- {
	-- 	-- TO CREATE ENV : python -m ipykernel install --user --name=myenv --display-name "MyEnv"
	-- 	"benlubas/molten-nvim",
	-- 	dev = false,
	-- 	enabled = true,
	-- 	version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
	-- 	build = ":UpdateRemotePlugins",
	-- 	dependencies = {
	-- 		"willothy/wezterm.nvim",
	-- 		"3rd/image.nvim",
	-- 	},
	-- 	init = function()
	-- 		vim.g.molten_image_provider = "image.nvim"
	-- 		-- vim.g.molten_output_win_max_height = 20
	-- 		vim.g.molten_auto_open_output = false
	-- 		vim.g.molten_auto_open_html_in_browser = true
	-- 		vim.g.molten_output_show_more = true
	-- 		vim.g.molten_output_virt_lines = true
	-- 		vim.g.molten_virt_text_output = true
	-- 		vim.g.molten_tick_rate = 200
	-- 	end,
	-- 	config = function()
	-- 		local init = function()
	-- 			local quarto_cfg = require("quarto.config").config
	-- 			quarto_cfg.codeRunner.default_method = "molten"
	-- 			vim.cmd([[MoltenInit]])
	-- 		end
	-- 		local deinit = function()
	-- 			local quarto_cfg = require("quarto.config").config
	-- 			quarto_cfg.codeRunner.default_method = "slime"
	-- 			vim.cmd([[MoltenDeinit]])
	-- 		end
	-- 		vim.keymap.set("n", "<localleader>mi", init, { silent = true, desc = "Initialize molten" })
	-- 		vim.keymap.set("n", "<localleader>md", deinit, { silent = true, desc = "Stop molten" })
	-- 		vim.keymap.set("n", "<localleader>md", deinit, { silent = true, desc = "Stop molten" })
	-- 		vim.keymap.set(
	-- 			"n",
	-- 			"<localleader>mp",
	-- 			":MoltenImagePopup<CR>",
	-- 			{ silent = true, desc = "molten image popup" }
	-- 		)
	-- 		vim.keymap.set(
	-- 			"n",
	-- 			"<leader>mb",
	-- 			":MoltenOpenInBrowser<CR>",
	-- 			{ silent = true, desc = "molten open in browser" }
	-- 		)
	-- 		vim.keymap.set("n", "<localleader>mh", ":MoltenHideOutput<CR>", { silent = true, desc = "hide output" })
	-- 		vim.keymap.set(
	-- 			"n",
	-- 			"<localleader>mr",
	-- 			":MoltenReevaluateCell<CR>",
	-- 			{ silent = true, desc = "Re-evaluate cell" }
	-- 		)
	-- 		vim.keymap.set(
	-- 			"n",
	-- 			"<localleader>u",
	-- 			":MoltenReevaluateAll<CR>",
	-- 			{ silent = true, desc = "Re-evaluate all" }
	-- 		)
	-- 		vim.keymap.set(
	-- 			"n",
	-- 			"<localleader>ms",
	-- 			":noautocmd MoltenEnterOutput<CR>",
	-- 			{ silent = true, desc = "show/enter output" }
	-- 		)
	--
	-- 		vim.keymap.set(
	-- 			"v",
	-- 			"<localleader>/",
	-- 			":<C-u>MoltenEvaluateVisual<CR>gv",
	-- 			{ desc = "execute visual selection", buffer = true, silent = true }
	-- 		)
	-- 	end,
	-- },
}
