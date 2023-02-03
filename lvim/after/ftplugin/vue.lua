local lsp_manager = require("lvim.lsp.manager")
local util = require "lspconfig.util"

local function get_typescript_server_path(root_dir)
	local global_ts = os.getenv("HOME") .. "/.config/yarn/global/node_modules/typescript/lib/"
	local found_ts = ""
	local function check_dir(path)
		found_ts = util.path.join(path, "node_modules", "typescript", "lib")
		if util.path.exists(found_ts) then
			return path
		end
	end
	if util.search_ancestors(root_dir, check_dir) then
		return found_ts
	else
		return global_ts
	end
end

lsp_manager.setup("tailwindcss", {
	filetypes = {
		"aspnetcorerazor",
		"astro",
		"astro-markdown",
		"blade",
		"django-html",
		"htmldjango",
		"edge",
		"eelixir",
		"ejs",
		"erb",
		"eruby",
		"gohtml",
		"haml",
		"handlebars",
		"hbs",
		"html",
		"html-eex",
		"heex",
		"jade",
		"leaf",
		"liquid",
		"markdown",
		"mdx",
		"mustache",
		"njk",
		"nunjucks",
		"php",
		"razor",
		"slim",
		"twig",
		"css",
		"less",
		"postcss",
		"sass",
		"scss",
		"stylus",
		"sugarss",
		"javascriptreact",
		"reason",
		"rescript",
		"typescriptreact",
		"vue",
		"svelte",
	},
})
lsp_manager.setup("stylelint_lsp", {
	filetypes = { "css", "less", "scss", "sugarss", "vue", "wxss", "javascriptreact", "typescriptreact" },
})
lsp_manager.setup("graphql", {
	filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
})

lsp_manager.setup("volar", {
	on_attach = function(client, bufnr)
		require("lvim.lsp").common_on_attach(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	on_new_config = function(new_config, new_root_dir)
		new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
	end,
})
