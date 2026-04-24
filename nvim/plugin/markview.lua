later(function()
  vim.g.markview_alpha = 0.4
  add { "https://github.com/OXY2DEV/markview.nvim" }

  local allowed_hybrid_modes_ft = { "Avante", "codecompanion", "help" }
  local disabled_buftypes = { "sagacodeaction", "sagadiagnostic", "sagatypehierarchy" }
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
  ---@type markview.config
  local opts = {
    experimental = {
      fancy_comments = true,
    },
    preview = {
      debounce = 100,
      -- Prefer mini
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
        return
      end,
      filetypes = allowed_ft,
    },
    markdown_inline = {
      tags = {
        default = {
          hl = "MarkviewCodeInfo",
          padding_left = "",
          padding_left_hl = "MarkviewCodeFg",
          padding_right = "",
          padding_right_hl = "MarkviewCodeFg",
        },
        enable = true,
      },
    },
    markdown = {
      block_quotes = require("markview.presets").block_quotes.obsidian,
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
        -- disable to prevent hover window shifting
        sign = false,
        label_direction = "right",
        enable = true,
      },

      list_items = {
        shift_width = function(buffer, item)
          ---@type integer Parent list items indent. Must be at least 1.
          local parent_indent = math.max(1, item.indent - vim.bo[buffer].shiftwidth)
          return item.indent * (1 / (parent_indent * 2))
        end,
        marker_minus = {
          add_padding = function(_, item) return item.indent > 1 end,
        },
      },
    },
  }

  opts.markdown.headings = require("markview.presets").headings.arrowed
  opts.markdown.horizontal_rules = require("markview.presets").horizontal_rules.thin
  opts.markdown.tables = require("markview.presets").tables.single
  require("markview.extras.headings").setup()
  require("markview.extras.editor").setup {
    max_height = math.floor(vim.o.lines * 0.75),
  }
  require("markview.extras.checkboxes").setup {
    --- Default checkbox state(used when adding checkboxes).
    ---@type string
    default = "x",

    --- Changes how checkboxes are removed.
    ---@type
    ---| "disable" Disables the checkbox.
    ---| "checkbox" Removes the checkbox.
    ---| "list_item" Removes the list item markers too.
    remove_style = "checkbox",

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
end)
