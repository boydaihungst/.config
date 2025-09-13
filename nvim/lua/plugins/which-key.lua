---@type LazySpec
return {
  "folke/which-key.nvim",
  ---@class wk.Opts
  opts = {
    preset = "modern",
    notify = true,
    plugins = {
      marks = true, -- shows a list of your marks on ' and `
      registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      spelling = {
        enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
        suggestions = 20, -- how many suggestions should be shown in the list?
      },
      presets = {
        operators = true, -- adds help for operators like d, y, ...
        motions = true, -- adds help for motions
        text_objects = true, -- help for text objects triggered after entering an operator
        windows = true, -- default bindings on <c-w>
        nav = true, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = true, -- bindings for prefixed with g
      },
    },
    ---@type wk.Win.opts
    -- win = {
    --   -- don't allow the popup to overlap with the cursor
    --   no_overlap = true,
    --   -- width = 1,
    --   -- height = { min = 4, max = 25 },
    --   -- col = 0,
    --   -- row = math.huge,
    --   -- border = "none",
    --   padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
    --   title = true,
    --   title_pos = "center",
    --   zindex = 1000,
    --   -- Additional vim.wo and vim.bo options
    --   bo = {},
    --   wo = {
    --     -- winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
    --   },
    -- },
    -- layout = {
    --   width = { min = 20 }, -- min and max width of the columns
    --   spacing = 3, -- spacing between columns
    -- },
    keys = {
      scroll_down = "<c-d>", -- binding to scroll down inside the popup
      scroll_up = "<c-u>", -- binding to scroll up inside the popup
    },
    ---@type (string|wk.Sorter)[]
    --- Mappings are sorted using configured sorters and natural sort of the keys
    --- Available sorters:
    --- * local: buffer-local mappings first
    --- * order: order of the items (Used by plugins like marks / registers)
    --- * group: groups last
    --- * alphanum: alpha-numerical first
    --- * mod: special modifier keys last
    --- * manual: the order the mappings were added
    --- * case: lower-case first
    sort = { "local", "order", "group", "alphanum", "mod" },
    ---@type number|fun(node: wk.Node):boolean?
    expand = 0, -- expand groups when <= n mappings
    -- expand = function(node)
    --   return not node.desc -- expand all nodes without a description
    -- end,
    -- Functions/Lua Patterns for formatting the labels
    ---@type table<string, ({[1]:string, [2]:string}|fun(str:string):string)[]>
    replace = {
      key = {
        function(key) return require("which-key.view").format(key) end,
        -- { "<Space>", "SPC" },
      },
      desc = {
        { "<Plug>%(?(.*)%)?", "%1" },
        { "^%+", "" },
        { "<[cC]md>", "" },
        { "<[cC][rR]>", "" },
        { "<[sS]ilent>", "" },
        { "^lua%s+", "" },
        { "^call%s+", "" },
        { "^:%s*", "" },
      },
    },
  },
  show_help = true, -- show a help message in the command line for using WhichKey
  show_keys = true, -- show the currently pressed key and its label as a message in the command line
  -- disable WhichKey for certain buf type and file types.
  disable = {
    ft = {},
    bt = {},
  },
  debug = false, -- enable wk.log in the current directory
}
