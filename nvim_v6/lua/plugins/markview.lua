---@diagnostic disable: missing-fields
local allowed_hybrid_modes_ft = { "Avante", "codecompanion", "help" }
local disabled_buftypes = { "sagacodeaction", "sagadiagnostic" }
local allowed_ft = {
  "markdown",
  "markdown_inline",
  "quarto",
  "rmd",
  "Avante",
  "codecompanion",
  "help",
  "checkhealth",
}

-- Change markdown render header background color. from 0 to 1
---@type LazySpec
return {
  "OXY2DEV/markview.nvim",
  enabled = true,
  specs = {
    "AstroNvim/astrocore",
    opts = {
      treesitter = {
        ensure_installed = { "html", "markdown", "markdown_inline", "latex", "typst", "yaml" },
      },
    },
  },
  ft = function()
    local plugin = require("lazy.core.config").spec.plugins["markview.nvim"]
    local opts = require("lazy.core.plugin").values(plugin, "opts", false)
    return opts.filetypes or { "markdown", "quarto", "rmd" }
  end,

  init = function() vim.g.markview_alpha = 0.4 end,
  ---@type markview.config
  opts = {
    experimental = {
      fancy_comments = true,
    },
    preview = {
      debounce = 100,
      -- Prefer pathfinder.nvim
      map_gx = false,
      hybrid_modes = { "n" },
      enable_hybrid_mode = false,
      headings = { shift_width = 0 },
      icon_provider = "mini", -- "mini" or "devicons"
      -- Use disabled_buftypes list above instead
      ignore_buftypes = {},
      condition = function(bufnr)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
        if vim.tbl_contains(disabled_buftypes, buftype) then return false end
        return nil
      end,
      filetypes = allowed_ft,
    },
    markdown = {
      reference_definitions = {
        enable = true,
        -- Setting website here
        -- ["github%.com/[%a%d%-%_%.]+%/?$"] = {
        --   --- github.com/<user>
        --
        --   icon = " ",
        --   hl = "MarkviewPalette0Fg",
        -- },
      },
      code_blocks = {
        sign = false,
      },

      list_items = {
        shift_width = function(buffer, item)
          ---@type integer Parent list items indent. Must be at least 1.
          local parent_indnet = math.max(1, item.indent - vim.bo[buffer].shiftwidth)
          return item.indent * (1 / (parent_indnet * 2))
        end,
        marker_minus = {
          add_padding = function(_, item) return item.indent > 1 end,
        },
      },
    },
  },
  config = function(_, opts)
    opts.markdown = opts.markers or {}
    opts.markdown.headings = require("markview.presets").headings.arrowed
    opts.markdown.horizontal_rules = require("markview.presets").horizontal_rules.thin
    opts.markdown.tables = require("markview.presets").tables.single
    require("markview.extras.headings").setup()
    -- require("markview.extras.editor").setup()
    require("markview.extras.checkboxes").setup {
      --- Default checkbox state(used when adding checkboxes).
      ---@type string
      default = "x",

      --- Changes how checkboxes are removed.
      ---@type
      ---| "disable" Disables the checkbox.
      ---| "checkbox" Removes the checkbox.
      ---| "list_item" Removes the list item markers too.
      remove_style = "list_item",

      --- Various checkbox states.
      ---
      --- States are in sets to quickly change between them
      --- when there are a lot of states.
      ---@type string[][]
      states = {
        { " ", "x" },
        { "<", ">" },
        { "?", "!", "*" },
        { '"' },
        { "l", "b", "i" },
        { "S", "I" },
        { "p", "c" },
        { "f", "k", "w" },
        { "u", "d" },
      },
    }
    require("markview").setup(opts)
    -- Enable hybrid mode for real markdown file only
    vim.api.nvim_create_autocmd("User", {
      pattern = "MarkviewAttach",
      callback = function(event)
        local data = event.data
        if data and vim.api.nvim_buf_is_valid(data.buffer) then
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = data.buffer })
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = data.buffer })
          if buftype ~= "nofile" or vim.tbl_contains(allowed_hybrid_modes_ft, filetype) then
            require("markview.actions").hybridEnable(data.buffer)
          end
        end
      end,
    })
  end,
}
