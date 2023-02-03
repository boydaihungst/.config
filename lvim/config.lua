require("user.null-ls")
require("user.keybind")

local lualine_components = require("lvim.core.lualine.components")
vim.g.netrw_browsex_viewer = "xdg-open"
vim.opt.mouse = ""
lvim.format_on_save = false

lvim.foldmethod = "expr"
lvim.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt["foldmethod"] = "expr"
vim.opt["foldenable"] = false
vim.opt["foldlevel"] = 99
vim.opt["foldexpr"] = "nvim_treesitter#foldexpr()"
vim.opt.scrolloff = 8
vim.opt.wrap = true
vim.opt.list = true
vim.opt.termguicolors = true

vim.cmd([[
  autocmd FileType help wincmd L
  augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
]])
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help" },
	command = "wincmd L",
})

lvim.builtin.terminal.active = true
lvim.builtin.bufferline.active = true
lvim.builtin.dap.active = true
lvim.builtin.alpha.active = true
lvim.builtin.project.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.bufferline.options.offsets = {
	{
		filetype = "NvimTree",
		text = "File Explorer",
		highlight = "Directory",
		text_align = "center",
	},
}
lvim.builtin.bufferline.options.always_show_bufferline = true
lvim.builtin.bufferline.options.show_buffer_close_icons = false
lvim.builtin.bufferline.options.close_command = function(bufnum)
	require("bufdelete").bufdelete(bufnum, true)
end
lvim.builtin.lualine.sections.lualine_a = {
	lualine_components.mode,
	lualine_components.filename,
}
lvim.builtin.lualine.sections.lualine_x = {
	lualine_components.diagnostics,
	lualine_components.treesitter,
	lualine_components.encoding,
	lualine_components.filetype,
}
lvim.builtin.lualine.options.globalstatus = false
lvim.builtin.lualine.options.disabled_filetypes = {
	"fugitive",
	"spectre_panel",
	"tagbar",
	"fzf",
	"Trouble",
	"NvimTree",
	"quickfix",
	"minimap",
	"packer",
	"telescope",
	"alpha",
}
lvim.builtin.lualine.options.theme = "catppuccin"
lvim.builtin.lualine.options.refresh = {
	winbar = 200,
}
-- vim.opt.winbar = components.treesitter[1]()
lvim.builtin.nvimtree.setup.view.adaptive_size = false
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.nvimtree.setup.renderer.full_name = false
lvim.builtin.nvimtree.setup.view.number = true
lvim.builtin.nvimtree.setup.view.relativenumber = true
lvim.builtin.nvimtree.setup.renderer.indent_markers.enable = true
lvim.builtin.nvimtree.setup.hijack_netrw = false
lvim.builtin.nvimtree.setup.disable_netrw = false
lvim.builtin.nvimtree.setup.filters.custom = {}
lvim.builtin.terminal.shell = "fish"
lvim.builtin.treesitter.context_commentstring.config = {
	typescript = "// %s",
	css = "/* %s */",
	scss = "// %s",
	html = "<!-- %s -->",
	vue = "<!-- %s -->",
	json = "",
}

lvim.builtin.treesitter.matchup = {
	enable = true,
	include_match_words = true,
}
lvim.builtin.treesitter.autotag.enable = true

lvim.builtin.treesitter.ensure_installed = {
	"bash",
	"c",
	"javascript",
	"json",
	"lua",
	"python",
	"typescript",
	"tsx",
	"css",
	"rust",
	"java",
	"yaml",
	"vue",
}
lvim.builtin.treesitter.rainbow = {
	enable = true,
	-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
	extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
	max_file_lines = nil, -- Do not enable for files with more than n lines, int
	-- colors = {}, -- table of hex strings
	-- termcolors = {} -- table of colour name strings
}
lvim.builtin.treesitter.highlight.enabled = true
vim.g.catppuccin_flavour = "mocha"
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, {
	"vuels",
	"volar",
	"tsserver",
})
lvim.builtin.cmp.sources = {
	{ name = "nvim_lsp" },
	{ name = "path", option = {
		trailing_slash = true,
	} },
	{ name = "luasnip" },
	{ name = "cmp_tabnine" },
	{ name = "nvim_lua" },
	{ name = "buffer" },
	{ name = "calc" },
	{ name = "emoji" },
	{ name = "treesitter" },
	{ name = "crates" },
	{ name = "tmux" },
}
lvim.builtin.cmp.source_names = {
	treesitter = "(TreeSitter)",
	nvim_lsp = "(LSP)",
	emoji = "(Emoji)",
	path = "(Path)",
	calc = "(Calc)",
	cmp_tabnine = "(Tabnine)",
	vsnip = "(Snippet)",
	luasnip = "(Snippet)",
	buffer = "(Buffer)",
	tmux = "(TMUX)",
}
lvim.builtin.cmp.completion.autocomplete = {
	require("cmp.types").cmp.TriggerEvent.TextChanged,
	require("cmp.types").cmp.TriggerEvent.InsertEnter,
	completeopt = "menu,menuone,noinsert,noselect",
}

lvim.builtin.cmp.view = {
	entries = { name = "custom", selection_order = "near_cursor" },
}
require("lvim.lsp.manager").setup("eslint", {
	settings = {
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
		codeActionOnSave = {
			enable = false,
			mode = "all",
		},
		format = true,
		onIgnoredFiles = "off",
		packageManager = "yarn",
		quiet = false,
		rulesCustomizations = {},
		run = "onType",
		useESLintClass = false,
		validate = "on",
		workingDirectory = {
			mode = "location",
		},
	},
})

-- lvim.lsp.on_attach_callback = function(_, bufnr)
-- 	-- show hint
-- 	require("lsp_signature").on_attach({
-- 		bind = true, -- This is mandatory, otherwise border config won't get registered.
-- 		hint_prefix = "💡 ",
-- 		floating_window = false,
-- 		hi_parameter = "LspDiagnosticsHint",
-- 		handler_opts = {
-- 			border = "rounded",
-- 		},
-- 	}, bufnr)
-- end

-- vim.lsp.handlers.hover = function(_, result, ctx, config)
-- 	local util = require("vim.lsp.util")
-- 	config = config or {}
-- 	config.focus_id = ctx.method
-- 	if not (result and result.contents) then
-- 		return
-- 	end
-- 	local markdown_lines = util.convert_input_to_markdown_lines(result.contents, {})
-- 	markdown_lines = util.trim_empty_lines(markdown_lines)
-- 	if vim.tbl_isempty(markdown_lines) then
-- 		return
-- 	end
-- 	return util.open_floating_preview(markdown_lines, "markdown", config)
-- end

vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
lvim.builtin.autopairs.enable_check_bracket_line = true
lvim.plugins = {
	{
		"ray-x/lsp_signature.nvim",
	},
	{
		"hrsh7th/cmp-cmdline",
		after = { "nvim-cmp", "nvim-autopairs" },
		config = function()
			local cmp = require("cmp")
			-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			-- local handlers = require("nvim-autopairs.completion.handlers")
			cmp.setup.cmdline("/", {
				sources = {
					{ name = "buffer" },
				},
				view = {
					entries = { name = "custom", selection_order = "near_cursor" },
				},
			})
			-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			-- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	-- theme
	{
		"catppuccin/nvim",
		as = "catppuccin",
		config = function()
			require("catppuccin").setup({
				dim_inactive = {
					enabled = false,
					shade = "dark",
					percentage = 0.15,
				},
				transparent_background = false,
				term_colors = true,
				compile = {
					enabled = true,
					path = get_cache_dir() .. "/catppuccin",
				},
				styles = {
					comments = { "italic" },
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
				},
				integrations = {
					treesitter = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
					},
					coc_nvim = false,
					lsp_trouble = false,
					cmp = true,
					lsp_saga = false,
					gitgutter = false,
					gitsigns = true,
					telescope = true,
					nvimtree = {
						enabled = true,
						show_root = true,
						transparent_panel = false,
					},
					neotree = {
						enabled = false,
						show_root = true,
						transparent_panel = false,
					},
					dap = {
						enabled = true,
						enable_ui = true,
					},
					which_key = true,
					indent_blankline = {
						enabled = true,
						colored_indent_levels = false,
					},
					dashboard = true,
					neogit = false,
					vim_sneak = false,
					fern = false,
					barbar = false,
					bufferline = true,
					markdown = true,
					lightspeed = false,
					ts_rainbow = true,
					hop = true,
					notify = true,
					telekasten = true,
					symbols_outline = true,
					mini = false,
				},
			})
			vim.cmd([[colorscheme catppuccin]])
			lvim.colorscheme = "catppuccin"
		end,
	},
	-- background color for RGB hex codes
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "*" }, {
				RGB = true, -- #RGB hex codes
				RRGGBB = true, -- #RRGGBB hex codes
				RRGGBBAA = true, -- #RRGGBBAA hex codes
				rgb_fn = true, -- CSS rgb() and rgba() functions
				hsl_fn = true, -- CSS hsl() and hsla() functions
				css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
				css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
			})
		end,
	},
	-- multiple cursors position
	{ "mg979/vim-visual-multi" },
	{ "p00f/nvim-ts-rainbow", event = "BufRead", requires = { "nvim-treesitter" } },
	-- move motion
	{
		"phaazon/hop.nvim",
		event = "BufRead",
		setup = function()
			vim.api.nvim_set_keymap("n", "f", ":HopChar2<cr>", { silent = true })
			vim.api.nvim_set_keymap("n", "F", ":HopWord<cr>", { silent = true })
		end,
		config = function()
			require("hop").setup()
		end,
	},
	{
		"andymass/vim-matchup",
		event = "VimEnter",
		after = { "nvim-treesitter" },
		setup = function()
			vim.g.loaded_matchit = 1
		end,
	},
	-- jump to lines
	{
		"nacro90/numb.nvim",
		event = "BufRead",
		config = function()
			require("numb").setup({
				show_numbers = true, -- Enable 'number' for the window while peeking
				show_cursorline = true, -- Enable 'cursorline' for the window while peeking
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	-- Show current focused function at top
	{
		"romgrk/nvim-treesitter-context",
		run = ":TSUpdateSync",
		after = "nvim-treesitter",
		config = function()
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				throttle = true, -- Throttles plugin updates (may improve performance)
				max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
				patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
					default = {
						"class",
						"function",
						"method",
						"for",
						"while",
						"if",
						"switch",
						"case",
						"else",
					},
				},
			})
		end,
	},
	-- support missing lsp colorscheme supports
	{ "folke/lsp-colors.nvim", event = "BufRead" },
	{
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		ft = "markdown",
		cmd = "MarkdownPreview",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
			-- auto open preview in browser when enter md buf
			vim.g.mkdp_auto_start = false
		end,
	},
	{ "tpope/vim-repeat" },
	{
		"ethanholz/nvim-lastplace",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help", "terminal" },
				lastplace_ignore_filetype = {
					"gitcommit",
					"gitrebase",
					"svn",
					"hgcommit",
					"NvimTree",
					"spectre_panel",
					"ctrlsf",
				},
				lastplace_open_folds = true,
			})
		end,
	},
	{ "tpope/vim-surround" },
	{ "famiu/bufdelete.nvim" },
	{
		"tpope/vim-abolish",
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		config = function()
			require("user.dap").setup()
		end,
	},
	{
		"nvim-neotest/neotest",
		requires = {
			"haydenmeade/neotest-jest",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-jest")({
						-- jestCommand = "yarn test --",
						-- jestConfigFile = "jest.config.js",
						-- env = { CI = true },
						-- cwd = function(_)
						--   return vim.fn.getcwd()
						-- end,
					}),
				},
			})
		end,
	},
	{
		"rmagatti/auto-session",
		config = function()
			require("auto-session").setup({
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
			})
		end,
	},
	{
		"rmagatti/session-lens",
		after = { "auto-session", "telescope.nvim" },
		config = function()
			require("session-lens").setup({
				prompt_title = "Restore Session",
			})
		end,
	},
}
