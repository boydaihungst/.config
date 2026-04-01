-- Change markdown render header background color. from 0 to 1
vim.g.markview_alpha = 0.4
---@type LazySpec
return {
  "OXY2DEV/markview.nvim",
  optional = true,
  enabled = true,
  dependencies = {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local astrocore = require "astrocore"

      if opts.treesitter == nil then opts.treesitter = {} end
      if opts.treesitter.ensure_installed == nil then opts.treesitter.ensure_installed = {} end

      if opts.treesitter.ensure_installed ~= "all" then
        astrocore.list_insert_unique(opts.treesitter.ensure_installed, { "latex", "typst", "yaml" })
      end
    end,
  },
  opts = {
    preview = {
      hybrid_modes = { "n" },
      headings = { shift_width = 0 },
      icon_provider = "mini", -- "mini" or "devicons"
      ignore_buftypes = { "nofile" },
      -- condition = function(buffer)
      --   local is_enabled = spec.get({ "experimental", "fancy_comments" }, {
      --     fallback = false,
      --   })
      --
      --   if not is_enabled then return false end
      --
      --   local success, parser = pcall(vim.treesitter.get_parser, buffer)
      --   if success and parser ~= nil then return true end
      -- end,
    },
    filetypes = {
      "markdown",
      "markdown_inline",
      "quarto",
      "rmd",
      "Avante",
      "codecompanion",
      "help",
      "checkhealth",
    },
    -- experimental = {
    --   fancy_comments = true,
    -- },
    markdown = {
      headings = require("markview.presets").headings.arrowed,
      horizontal_rules = require("markview.presets").horizontal_rules.thin,
      tables = require("markview.presets").tables.single,

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
}
