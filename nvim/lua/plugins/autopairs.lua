---@type LazySpec
return {
  "windwp/nvim-autopairs",
  optional = true,
  opts = {
    fast_wrap = {
      avoid_move_to_end = false,
    },
  },
  -- config = function(plugin, opts)
  --   require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
  --   -- add more custom autopairs configuration such as custom rules
  --   local npairs = require "nvim-autopairs"
  --   local Rule = require "nvim-autopairs.rule"
  --   local cond = require "nvim-autopairs.conds"
  --   -- npairs.ts_config = {
  --   --   lua = { "string", "source" },
  --   --   javascript = { "string", "template_string" },
  --   --   java = false,
  --   --   typescript = { "string", "template_string" },
  --   --   vue = { "string", "template_string" },
  --   -- }
  --   npairs.add_rules {
  --     -- specify a list of rules to add
  --     Rule(" ", " "):with_pair(function(options)
  --       local pair = options.line:sub(options.col - 1, options.col)
  --       return vim.tbl_contains({ "()", "[]", "{}" }, pair)
  --     end),
  --     Rule("( ", " )")
  --       :with_pair(function() return false end)
  --       :with_move(function(options) return options.prev_char:match ".%)" ~= nil end)
  --       :use_key ")",
  --     Rule("{ ", " }")
  --       :with_pair(function() return false end)
  --       :with_move(function(options) return options.prev_char:match ".%}" ~= nil end)
  --       :use_key "}",
  --     Rule("[ ", " ]")
  --       :with_pair(function() return false end)
  --       :with_move(function(options) return options.prev_char:match ".%]" ~= nil end)
  --       :use_key "]",
  --   }
  -- end,
}
