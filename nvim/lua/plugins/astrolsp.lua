-- if vim.fn.has "nvim-0.12" == 1 then vim.lsp.on_type_formatting.enable() end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  version = false,
  branch = "v4",
  ---@type AstroLSPOpts
  opts = {
    defaults = {},
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
      signature_help = true,
      linked_editing_range = true,
    },
    capabilities = vim.fn.has "nvim-0.12" == 1 and {
      textDocument = {
        -- TODO: python won't work Wait till this PR is merged https://github.com/neovim/neovim/pull/35578
        -- This is because require('blink.cmp').get_lsp_capabilities() doesn't set the necessary capability for onTypeFormatting.
        -- onTypeFormatting = { dynamicRegistration = false },

        -- Force enable callHierarchy
        callHierarchy = {
          dynamicRegistration = true,
        },
      },
    },
    -- customize lsp formatting options
    formatting = {
      -- use conform-nvim
      disabled = true,
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      -- disabled = { -- disable formatting capabilities for the listed language servers
      --   -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
      --   -- "lua_ls",
      -- },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    -- customize language server configuration passed to `vim.lsp.config`
    -- client specific configuration can also go in `lsp/` in your configuration root (see `:h lsp-config`)
    config = {
      -- ["*"] = { capabilities = {} }, -- modify default LSP client settings such as capabilities
    },
    -- customize how language servers are attached
    handlers = {
      -- a function with the key `*` modifies the default handler, functions takes the server name as the parameter
      -- ["*"] = function(server) vim.lsp.enable(server) end

      -- the key is the server that is being setup with `vim.lsp.config`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {

      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client, bufnr)
            return client:supports_method("textDocument/semanticTokens/full", bufnr) and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lsp-attach`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
