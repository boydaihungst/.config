--- Optional: rg for faster usage scans (falls back to git ls-files).
---@type LazySpec
return {
  "yelog/i18n.nvim",
  enabled = false,
  lazy = true,
  ft = { "vue", "typescript", "javascript", "typescriptreact", "javascriptreact", "tsx", "jsx", "java", "json", "yaml" },
  dependencies = {
    "folke/snacks.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local astrocore = require "astrocore"
        local original_sig_help = vim.lsp.buf.signature_help
        if not vim.g.changed_sign_helper then
          vim.lsp.buf.signature_help = function(opts)
            if astrocore.is_available "i18n.nvim" and require("i18n.display").get_key_under_cursor() then
              require("i18n").show_popup()
            else
              opts = astrocore.extend_tbl(opts, {
                anchor_bias = "above",
              })
              return original_sig_help(opts)
            end
          end
          vim.g.changed_sign_helper = true
        end

        opts.autocmds = vim.tbl_deep_extend("force", opts.autocmds, {
          reload_i18n_on_cwd_changed = {
            {
              event = "DirChanged",
              pattern = { "*" },
              desc = "Reload i18n on cwd changed",
              callback = function(_)
                if vim.fn.exists ":I18nReload" == 2 then vim.cmd "I18nReload" end
              end,
            },
          },
        })
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
  opts = {
    activation = "lazy",
    show_mode = "both",
    diagnostic = true,
    -- Locales to parse; first is the default locale
    -- Use I18nNextLocale command to switch the default locale in real time
    locales = { "en", "vn", "jp", "zh", "en_US", "vi_VN", "ja_JP", "zh_CN" },
    usage = {
      -- Popup provider used when choosing between multiple usage locations
      -- Available values: 'vim_ui', 'telescope', 'fzf-lua', 'snacks'
      popup_type = "snacks",
      notify_no_key = false,
      max_file_size = 0, -- 0 = no limit
      scan_on_startup = true,
    },
    func_pattern = { "t", "$t" },
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
    i18n_keys = {
      popup_type = "snacks",
    },

    -- Enable namespace resolution
    -- false: Disabled, no namespace resolution
    -- 'auto': Auto-detect framework based on filetype (tsx/jsx → react_i18next, vue → vue_i18n)
    -- 'react_i18next': Detect useTranslation('namespace') calls in React components
    -- 'vue_i18n': Detect useI18n({ namespace: '...' }) in Vue components
    namespace_resolver = "auto", -- or 'react_i18next', 'vue_i18n', custom function, or table
    -- Separator between namespace and key
    namespace_separator = ".", -- set ':' for i18next standard
  },
}
