---@type LazySpec
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim", "AstroNvim/astrocore" },
  opts = {
    lsp = {
      hover = {
        enabled = false,
        silent = false,
      },
      signature = {
        enabled = false,
      },
      progress = { enabled = false, view = "mini" }, -- Optional: If you want less clutter
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
      command_palette = true, -- If you're using a command palette (e.g., dressing.nvim)
      long_message_to_split = false, -- long messages will be sent to a split
      inc_rename = require("astrocore").is_available "inc-rename.nvim", -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true,
    },
    messages = {
      enabled = true, -- Ensure messages are enabled
      view_search = false, -- view for search count messages. Set to `false` to disable
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "search_count",
        },
        opts = { skip = false },
      },
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "Starting Supermaven" },
            { find = "Supermaven Free Tier" },
            -- disable deprecated message
            -- { find = 'is deprecated. Run ":checkhealth vim.deprecated' },
            { find = "No snippets in contex" },
            -- { find = "deprecated" },
          },
        },
        opts = { skip = true },
      },
      -- Hide recoding message -> use heirline instead
      {
        filter = {
          event = "msg_showmode",
          find = "recording @",
        },
        -- view = "mini",
        opts = { skip = true },
      },
      {
        filter = {
          event = "msg_show",
          find = "Hop %d char:",
        },
        view = "mini",
      },
      {
        filter = { event = "msg_showmode" },
        view = "mini",
        -- opts = { skip = true },
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      optional = true,
      ---@type AstroCoreOpts
      opts = {
        treesitter = { ensure_installed = { "bash", "markdown", "markdown_inline", "regex", "vim" } },
      },
    },
    {
      "AstroNvim/astrolsp",
      optional = true,
      ---@param opts AstroLSPOpts
      opts = function(_, opts)
        local noice_opts = require("astrocore").plugin_opts "noice.nvim"
        -- disable the necessary settings in AstroLSP
        if not opts.defaults then opts.defaults = {} end
        if vim.tbl_get(noice_opts, "lsp", "hover", "enabled") ~= false then
          opts.defaults.hover = false
        end
        if vim.tbl_get(noice_opts, "lsp", "signature", "enabled") ~= false then
          if not opts.features then opts.features = {} end
          opts.features.signature_help = false
        end
      end,
    },
    {
      "folke/edgy.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.bottom then opts.bottom = {} end
        table.insert(opts.bottom, {
          ft = "noice",
          size = { height = 0.4 },
          filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == "" end,
        })
      end,
    },
    {
      "catppuccin",
      optional = true,
      ---@type CatppuccinOptions
      opts = { integrations = { noice = true } },
    },
  },
}
