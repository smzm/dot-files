-- >>> Auto completion
-- You need to enable capabilities in lsp.lua based on plugin you are using here.
-- >>> CMP
-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- >>> Blink
-- local capabilities = require("blink.cmp").get_lsp_capabilities()

return {
	-- {
	-- 	"hrsh7th/nvim-cmp",
	-- 	dependencies = {
	-- 		"hrsh7th/cmp-buffer", -- source for text in buffer
	-- 		"hrsh7th/cmp-nvim-lsp",
	-- 		"hrsh7th/cmp-path", -- source for file system paths
	-- 		{
	-- 			"L3MON4D3/LuaSnip",
	-- 			-- follow latest release.
	-- 			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- 			-- install jsregexp (optional!).
	-- 			build = "make install_jsregexp",
	-- 		},
	-- 		"saadparwaiz1/cmp_luasnip", -- for autocompletion
	-- 		"rafamadriz/friendly-snippets", -- useful snippets
	-- 		"onsails/lspkind.nvim", -- vs-code like pictograms
	-- 	},
	-- 	event = "InsertEnter",
	-- 	config = function()
	-- 		local cmp = require("cmp")
	-- 		local luasnip = require("luasnip")
	-- 		local lspkind = require("lspkind")
	-- 		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	--
	-- 		-- cmp_autopairs : insert `(` after select function or method item
	-- 		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	--
	-- 		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
	-- 		require("luasnip.loaders.from_vscode").lazy_load()
	--
	-- 		local function border(hl_name)
	-- 			return {
	-- 				{ "╭", hl_name },
	-- 				{ "─", hl_name },
	-- 				{ "╮", hl_name },
	-- 				{ "│", hl_name },
	-- 				{ "╯", hl_name },
	-- 				{ "─", hl_name },
	-- 				{ "╰", hl_name },
	-- 				{ "│", hl_name },
	-- 			}
	-- 		end
	--
	-- 		vim.api.nvim_set_hl(0, "CmpWin", { link = "NormalFloat" })
	--
	-- 		cmp.setup({
	-- 			auto_brackets = { "python" },
	-- 			completion = {
	-- 				completeoptk = "menu,menuone,preview,noselect",
	-- 			},
	-- 			snippet = {
	-- 				expand = function(args)
	-- 					luasnip.lsp_expand(args.body) -- For `luasnip` users.
	-- 				end,
	-- 			},
	-- 			mapping = cmp.mapping.preset.insert({
	-- 				["<C-k>"] = cmp.mapping.select_prev_item(),
	-- 				["<C-j>"] = cmp.mapping.select_next_item(),
	-- 				["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
	-- 				["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
	-- 				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
	-- 				-- When hit enter, automatically add an import at the top of the file
	-- 				["<CR>"] = cmp.mapping(function(fallback)
	-- 					if cmp.visible() then
	-- 						local entry = cmp.get_selected_entry()
	-- 						if not entry then
	-- 							-- If nothing selected, select the first item
	-- 							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
	-- 							entry = cmp.get_selected_entry()
	-- 						end
	-- 						if entry then
	-- 							cmp.confirm({ select = true })
	-- 							local item = entry.completion_item
	-- 							if item.additionalTextEdits then
	-- 								vim.lsp.util.apply_text_edits(item.additionalTextEdits, 0)
	-- 							end
	-- 						else
	-- 							fallback()
	-- 						end
	-- 					else
	-- 						fallback()
	-- 					end
	-- 				end, { "i", "s" }),
	--
	-- 				-- ["<Up>"] = cmp.mapping(function(fallback)
	-- 				-- 	fallback() -- Allows Up arrow to fall back without interacting with cmp
	-- 				-- end, { "i", "c" }),
	-- 				-- ["<Down>"] = cmp.mapping(function(fallback)
	-- 				-- 	fallback() -- Allows Down arrow to fall back without interacting with cmp
	-- 				-- end, { "i", "c" }),
	-- 			}),
	-- 			sources = {
	-- 				{ name = "nvim_lsp" },
	-- 				{ name = "luasnip" }, -- snippets
	-- 				{ name = "buffer" }, -- text within current buffer
	-- 				{ name = "path" }, -- file system paths
	-- 				{ name = "dadbod" }, -- database
	-- 				{ name = "render-markdown" },
	-- 			},
	-- 			window = {
	-- 				completion = {
	-- 					winhighlight = "NormalNC:CmpWin,FloatBorder:Title,Search:None",
	-- 					col_offset = -3,
	-- 					side_padding = 0,
	-- 				},
	-- 				documentation = {
	-- 					-- border = border("CmpDocBorder"),
	-- 					winhighlight = "NormalNC:CmpWin",
	-- 					max_width = 80,
	-- 				},
	-- 			},
	-- 			formatting = {
	-- 				fields = { "kind", "abbr", "menu" },
	-- 				format = function(entry, vim_item)
	-- 					local kind =
	-- 						require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 80 })(entry, vim_item)
	-- 					local strings = vim.split(kind.kind, "%s", { trimempty = true })
	-- 					kind.kind = " " .. (strings[1] or "") .. " "
	-- 					kind.menu = "    (" .. (strings[2] or "") .. ")"
	--
	-- 					return kind
	-- 				end,
	-- 			},
	-- 			enabled = function()
	-- 				-- Disable nvim-cmp in a telescope prompt
	-- 				if buftype == "prompt" then
	-- 					return false
	-- 				end
	-- 				-- Disable completion in comments
	-- 				local context = require("cmp.config.context")
	-- 				-- Keep command mode completion enabled when cursor is in a comment
	-- 				if vim.api.nvim_get_mode().mode == "c" then
	-- 					return true
	-- 				else
	-- 					return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
	-- 				end
	-- 			end,
	-- 		})
	-- 	end,
	-- },
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = {
			{ "rafamadriz/friendly-snippets" },
			{ "moyiz/blink-emoji.nvim" },
			{ "Kaiser-Yang/blink-cmp-dictionary" },
			{
				"L3MON4D3/LuaSnip",
				-- follow latest release.
				version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				-- install jsregexp (optional!).
				build = "make install_jsregexp",
				config = function(_, opts)
					local ls = require("luasnip")
					local s = ls.snippet
					local t = ls.text_node
					local i = ls.insert_node

					ls.add_snippets("markdown", {
						s("pycode", {
							t("```python"),
							t({ "", "" }),
							i(1, ""),
							t({ "", "```" }),
						}),
					})

					ls.add_snippets("markdown", {
						s("tscode", {
							t("```typescript"),
							t({ "", "" }),
							i(1, ""),
							t({ "", "```" }),
						}),
					})

					ls.add_snippets("markdown", {
						s("jscode", {
							t("```javascript"),
							t({ "", "" }),
							i(1, ""),
							t({ "", "```" }),
						}),
					})

					ls.add_snippets("markdown", {
						s("tsxcode", {
							t("```tsx"),
							t({ "", "" }),
							i(1, ""),
							t({ "", "```" }),
						}),
					})
				end,
			},
		},

		-- use a release tag to download pre-built binaries
		version = "1.*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = {
				preset = "enter",
				["<Tab>"] = { "fallback" },
				["<S-Tab>"] = { "fallback" },
				-- ["<Tab>"] = { "snippet_forward", "fallback" },
				-- ["<S-Tab>"] = { "snippet_backward", "fallback" },

				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },

				["<S-k>"] = { "scroll_documentation_up", "fallback" },
				["<S-j>"] = { "scroll_documentation_down", "fallback" },

				["<S-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			-- (Default) Only show the documentation popup when manually triggered
			completion = {
				documentation = { auto_show = false },
			},

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			snippets = {
				preset = "luasnip",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "dadbod", "emoji", "dictionary" },
				per_filetype = {
					codecompanion = { "codecompanion" },
				},
				providers = {
					lsp = {
						name = "lsp",
						enabled = true,
						module = "blink.cmp.sources.lsp",
						min_keyword_length = 2,
						-- When linking markdown notes, I would get snippets and text in the
						-- suggestions, I want those to show only if there are no LSP
						-- suggestions
						--
						-- Enabled fallbacks as this seems to be working now
						-- Disabling fallbacks as my snippets wouldn't show up when editing
						-- lua files
						-- fallbacks = { "snippets", "buffer" },
						score_offset = 90, -- the higher the number, the higher the priority
					},
					path = {
						name = "Path",
						module = "blink.cmp.sources.path",
						score_offset = 25,
						-- When typing a path, I would get snippets and text in the
						-- suggestions, I want those to show only if there are no path
						-- suggestions
						fallbacks = { "snippets", "buffer" },
						-- min_keyword_length = 2,
						opts = {
							trailing_slash = false,
							label_trailing_slash = true,
							get_cwd = function(context)
								return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
							end,
							show_hidden_files_by_default = true,
						},
					},
					buffer = {
						name = "Buffer",
						enabled = true,
						max_items = 3,
						module = "blink.cmp.sources.buffer",
						min_keyword_length = 2,
						score_offset = 15, -- the higher the number, the higher the priority
					},
					-- Example on how to configure dadbod found in the main repo
					-- https://github.com/kristijanhusak/vim-dadbod-completion
					dadbod = {
						name = "Dadbod",
						module = "vim_dadbod_completion.blink",
						min_keyword_length = 2,
						score_offset = 85, -- the higher the number, the higher the priority
					},
					-- https://github.com/moyiz/blink-emoji.nvim
					emoji = {
						module = "blink-emoji",
						name = "Emoji",
						score_offset = 93, -- the higher the number, the higher the priority
						min_keyword_length = 2,
						opts = { insert = true }, -- Insert emoji (default) or complete its name
					},
					-- https://github.com/Kaiser-Yang/blink-cmp-dictionary
					-- In macOS to get started with a dictionary:
					-- cp /usr/share/dict/words ~/github/dotfiles-latest/dictionaries/words.txt
					--
					-- NOTE: For the word definitions make sure "wn" is installed
					-- brew install wordnet
					dictionary = {
						module = "blink-cmp-dictionary",
						name = "Dict",
						score_offset = 10, -- the higher the number, the higher the priority
						-- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
						enabled = true,
						max_items = 3,
						min_keyword_length = 3,
						opts = {
							-- -- The dictionary by default now uses fzf, make sure to have it
							-- -- installed
							-- -- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
							--
							-- Do not specify a file, just the path, and in the path you need to
							-- have your .txt files
							dictionary_directories = { vim.fn.expand("~/.config/nvim/spell") },
							-- Notice I'm also adding the words I add to the spell dictionary
							dictionary_files = {
								vim.fn.expand("~/.config/nvim/spell/en.utf-8.add"),
							},
							-- --  NOTE: To disable the definitions uncomment this section below
							--
							-- separate_output = function(output)
							--   local items = {}
							--   for line in output:gmatch("[^\r\n]+") do
							--     table.insert(items, {
							--       label = line,
							--       insert_text = line,
							--       documentation = nil,
							--     })
							--   end
							--   return items
							-- end,
						},
					},
				},
			},
			cmdline = {
				enabled = true,
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
}
