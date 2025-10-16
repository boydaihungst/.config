local is_windows = jit.os:find "Windows"
---@type LazySpec
return {
  "gbprod/yanky.nvim",
  -- Enabled this if you want to use yank history Leader + f + y
  enabled = false,
  event = "User AstroFile",
  dependencies = {
    { "kkharji/sqlite.lua", enabled = not is_windows },
    { "folke/snacks.nvim" },
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>fy"] = { function() require("snacks").picker.yanky() end, desc = "Find yanks" },
            -- ["y"] = { "<Plug>(YankyYank)", desc = "Yank text" },
            -- ["p"] = { "<Plug>(YankyPutAfter)", desc = "Put yanked text after cursor" },
            -- ["P"] = { "<Plug>(YankyPutBefore)", desc = "Put yanked text before cursor" },
            -- ["gp"] = { "<Plug>(YankyGPutAfter)", desc = "Put yanked text after selection" },
            -- ["gP"] = { "<Plug>(YankyGPutBefore)", desc = "Put yanked text before selection" },
            -- ["[y"] = { "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
            -- ["]y"] = { "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
            -- ["]p"] = { "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
            -- ["[p"] = { "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
            -- ["]P"] = { "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
            -- ["[P"] = { "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
            -- [">p"] = { "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
            -- ["<p"] = { "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
            -- [">P"] = { "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
            -- ["<P"] = { "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
            -- ["=p"] = { "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
            -- ["=P"] = { "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
          },
          x = {
            -- ["y"] = { "<Plug>(YankyYank)", desc = "Yank text" },
            -- ["p"] = { "<Plug>(YankyPutAfter)", desc = "Put yanked text after cursor" },
            -- ["P"] = { "<Plug>(YankyPutBefore)", desc = "Put yanked text before cursor" },
            -- ["gp"] = { "<Plug>(YankyGPutAfter)", desc = "Put yanked text after selection" },
            -- ["gP"] = { "<Plug>(YankyGPutBefore)", desc = "Put yanked text before selection" },
          },
        },
      },
    },
  },
  opts = {
    highlight = { timer = 200 },
    -- ring = { storage = is_windows and "shada" or "sqlite" },
    -- system_clipboard = {
    --   sync_with_ring = false,
    -- },
  },
}
