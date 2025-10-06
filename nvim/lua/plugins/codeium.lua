---@type LazySpec
return {
  "Exafunction/codeium.nvim",
  event = "InsertEnter",
  cmd = "Codeium",
  -- codeium suck
  enabled = false,
  -- build = ":Codeium Auth",
  opts = {
    enable_chat = false,
    enable_cmp_source = false,
    -- workspace_root = {
    --   use_lsp = true,
    --   find_root = function() return vim.fn.getcwd() end,
    -- },
    virtual_text = {
      manual = false,
      enabled = true,
      map_keys = true,
      filetypes = { ["grug-far"] = false },
      key_bindings = {
        -- Accept the current completion.
        accept = "<C-l>",
        -- Accept the next word.
        accept_word = "<C-w>",
        -- Accept the next line.
        accept_line = "<C-j>",
        -- Clear the virtual text.
        clear = false,
        -- Cycle to the next completion.
        next = "<C-;>",
        -- Cycle to the previous completion.
        prev = "<C-,>",
      },
    },
  },
  dependencies = {
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          Codeium = "",
        },
      },
    },
  },
  specs = {
    {
      "onsails/lspkind.nvim",
      optional = true,
      -- Adds icon for codeium using lspkind
      opts = function(_, opts)
        if not opts.symbol_map then opts.symbol_map = {} end
        opts.symbol_map.Codeium = require("astroui").get_icon("Codeium", 1, true)
      end,
    },
    {
      "nvim-mini/mini.icons",
      optional = true,
      -- Adds icon for codeium using mini.icons
      opts = function(_, opts)
        if not opts.lsp then opts.lsp = {} end
        if not opts.symbol_map then opts.symbol_map = {} end
        opts.symbol_map.codeium = { glyph = require("astroui").get_icon("Codeium", 1, true), hl = "MiniIconsCyan" }
      end,
    },
  },
}
