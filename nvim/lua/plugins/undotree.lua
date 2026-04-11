---@type LazySpec
return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  optional = true,
  init = function()
    vim.g.undotree_WindowLayout = 3
    vim.g.undotree_SplitWidth = 50
    vim.g.undotree_DiffpanelHeight = 25
    vim.g.undotree_DiffAutoOpen = 0
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_HighlightChangedText = 1
    vim.g.undotree_ShortIndicators = 0
    vim.g.undotree_SignAdded = require("astroui").get_icon("GitAdd", 1, true)
    vim.g.undotree_SignModified = require("astroui").get_icon("GitChange", 1, true)
    vim.g.undotree_SignDeleted = require("astroui").get_icon("GitDelete", 1, true)
  end,
  specs = {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = {
      mappings = {

        n = { ["<Leader>fu"] = { "<cmd>UndotreeToggle<CR>", desc = "Find undotree" } },
      },
    },
  },
}
