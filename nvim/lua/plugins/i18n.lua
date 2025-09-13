---@type LazySpec
return {
  "yelog/i18n.nvim",
  enabled = false,
  lazy = true,
  ft = { "json", "vue", "typescript", "javascript", "tsx", "jsx" },
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    show_translation = true,
    show_origin = false,
    diagnostic = false,
    -- Locales to parse; first is the default locale
    -- Use I18nNextLocale command to switch the default locale in real time
    locales = { "en", "vn", "jp", "zh" },
    -- sources can be string or table { pattern = "...", prefix = "..." }
    -- Project-level configuration files
    -- .i18nrc.json
    -- i18n.config.json
    -- .i18nrc.lua
    sources = {
      "src/locales/{locales}.json",
      "src/lang/{locales}.json",
      -- { pattern = "src/locales/lang/{locales}/{module}.ts",            prefix = "{module}." },
      -- { pattern = "src/views/{bu}/locales/lang/{locales}/{module}.ts", prefix = "{bu}.{module}." },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local astrocore = require "astrocore"
        if not astrocore.is_available "i18n.nvim" then return end
        if not opts.mappings then opts.mappings = astrocore.empty_map_table() end
        local maps = opts.mappings

        local signature_help = {
          function()
            if require("i18n.display").get_key_under_cursor() then
              require("i18n").show_popup()
            else
              vim.lsp.buf.signature_help()
            end
          end,
          desc = "Signature help",
        }

        maps.n["<Leader>gK"] = signature_help
        maps.s["<Leader>gK"] = signature_help
        maps.i["<Leader>gK"] = signature_help
      end,
    },
    {
      "AstroNvim/astrolsp",
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
        local maps = opts.mappings
        maps.n["<Leader>lh"] = {
          function()
            if require("i18n.display").get_key_under_cursor() then
              require("i18n").show_popup()
            else
              vim.lsp.buf.signature_help()
            end
          end,
          desc = "Signature help",
          cond = "textDocument/signatureHelp",
        }
      end,
    },
    {
      "saghen/blink.cmp",
      optional = true,
      opts = {
        sources = {
          default = { "i18n" },
          providers = {
            i18n = {
              name = "i18n",
              module = "i18n.integration.blink_source",
              opts = {
                -- future options can be placed here
              },
            },
          },
        },
      },
    },
  },
}
