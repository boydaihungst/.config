---@type LazySpec
return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  optional = true,
  dependencies = {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      local astroui = require "astroui"
      if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
      local maps = opts.mappings

      maps.n["<Leader>fu"] = { "<cmd>UndotreeToggle<CR>", desc = "Find undotree" }
      opts.options = opts.options or {}
      opts.g = opts.g or {}
      local g = opts.options.g
      g.undotree_WindowLayout = 3
      g.undotree_SplitWidth = 50
      g.undotree_DiffpanelHeight = 25
      g.undotree_DiffAutoOpen = 0
      g.undotree_SetFocusWhenToggle = 1
      g.undotree_HighlightChangedText = 1
      g.undotree_ShortIndicators = 0
      g.undotree_SignAdded = astroui.get_icon("GitAdd", 1, true)
      g.undotree_SignModified = astroui.get_icon("GitChange", 1, true)
      g.undotree_SignDeleted = astroui.get_icon("GitDelete", 1, true)
    end,
  },
}
