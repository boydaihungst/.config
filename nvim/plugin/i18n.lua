on_filetype(
  { "vue", "typescript", "javascript", "typescriptreact", "javascriptreact", "tsx", "jsx", "java", "json", "yaml" },
  function()
    add {
      "https://github.com/yelog/i18n.nvim",
      { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1.x" },
    }

    local i18n = require "i18n"
    i18n.setup {
      activation = "lazy",
      show_mode = "both",
      diagnostic = true,
      -- Locales to parse; first  the default locale
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
      -- false: disabled, no namespace resolution
      -- 'auto': Auto-detect framework based on filetype (tsx/jsx → react_i18next, vue → vue_i18n)
      -- 'react_i18next': Detect useTranslation('namespace') calls in React components
      -- 'vue_i18n': Detect useI18n({ namespace: '...' }) in Vue components
      namespace_resolver = "auto", -- or 'react_i18next', 'vue_i18n', custom function, or table
      -- Separator between namespace and key
      namespace_separator = ".", -- set ':' for i18next standard
    }
    local original_sig_help = vim.lsp.buf.signature_help
    vim.lsp.buf.signature_help = function(opts)
      if require("i18n.display").get_key_under_cursor() then
        require("i18n").show_popup()
      else
        opts = vim.tbl_extend("force", opts, {
          anchor_bias = "above",
        })
        return original_sig_help(opts)
      end
    end

    Config.new_autocmd("DirChanged", "*", function()
      if vim.fn.exists ":I18nReload" ~= 0 and i18n._activated then vim.cmd "I18nReload" end
    end, "Reload i18n on cwd/workspace changed")

    local blink_avail, blink = pcall(require, "blink.cmp")
    if blink_avail then
      for _, filetype in ipairs {
        "vue",
        "typescript",
        "javascript",
        "typescriptreact",
        "javascriptreact",
        "tsx",
        "jsx",
        "java",
        "json",
        "yaml",
      } do
        blink.add_filetype_source(filetype, "i18n")
      end
      blink.add_source_provider("i18n", {
        name = "i18n",
        module = "i18n.integration.blink_source",
      })
    end
  end
)
