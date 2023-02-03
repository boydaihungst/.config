
require("lvim.lsp.manager").setup("tsserver", {
	settings = { documentFormatting = false },
})
require("lvim.lsp.manager").setup("graphql", {
	filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
})

