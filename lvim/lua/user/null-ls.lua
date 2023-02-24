local formatters = require("lvim.lsp.null-ls.formatters")
local code_actions = require("lvim.lsp.null-ls.code_actions")
local linters = require("lvim.lsp.null-ls.linters")

formatters.setup({
	-- { name = "deno_fmt" },
	{ name = "prettier", filetypes = { "html", "css", "yaml", "handlebars" } },
	-- { name = "eslint_d" },
	{ name = "rustywind" },
	-- { name = "stylua" },
	-- { name = "clang_format" },
	-- { name = "shfmt" },
	{ name = "markdownlint" },
	-- { name = "black" },
	-- { name = "reorder_python_imports" },
	-- { name = "rustfmt" },
	{ name = "nginx_beautifier" },
	{ name = "fish_indent" },
})
code_actions.setup({
	-- { name = "eslint_d", filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" } },
})
linters.setup({
	-- { name = "eslint_d" },
	-- { name = "luacheck" },
	-- { name = "shellcheck" },
	{ name = "markdownlint" },
	-- { name = "pylint" },
	-- { name = "yamllint" },
	{ name = "commitlint" },
	-- { name = "hadolint" },
	{ name = "fish" },
})
