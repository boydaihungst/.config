---@type LazySpec
return {
  { "AstroNvim/astroui", opts = { icons = { Diff = "" } } },
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      local mappings = assert(opts.mappings)

      local prefix = "<Leader>D"
      mappings.n[prefix] = { desc = require("astroui").get_icon("Diff", 1, true) .. "Diff" }
      mappings.n[prefix .. "h"] = { "<cmd>DiffviewFileHistory<cr>", desc = "Diff file history" }
      mappings.n[prefix .. "o"] = { "<cmd>DiffviewOpen<cr>", desc = "Diff open" }
      mappings.n[prefix .. "c"] = { "<cmd>DiffviewClose<cr>", desc = "Diff close" }
      -- mappings.n[prefix .. "p"] = { "<cmd>DiffviewToggleFiles<cr>", desc = "Diff toggle files" }
      -- mappings.n[prefix .. "u"] = { "<cmd>DiffviewFocusFiles<cr>", desc = "Diff focus files" }
      -- mappings.n[prefix .. "r"] = { "<cmd>DiffviewRefresh<cr>", desc = "Diff refresh" }
    end,
  },
  {
    "sindrets/diffview.nvim",
    event = "User AstroGitFile",
    cmd = {
      "DiffviewOpen",
      -- "DiffviewClose",
      -- "DiffviewToggleFiles",
      -- "DiffviewFocusFiles",
      -- "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = function(_, opts)
      local astroui = require "astroui"
      opts.enhanced_diff_hl = true
      opts.view = {
        default = { winbar_info = true },
        file_history = { winbar_info = true },
      }
      opts.icons = { -- Only applies when use_icons is true.
        folder_closed = astroui.get_icon "FolderClosed" or "",
        folder_open = astroui.get_icon "FolderOpen" or "",
      }
      opts.signs = {
        fold_closed = astroui.get_icon "FoldClosed" or "",
        fold_open = astroui.get_icon "FoldOpened" or "",
        done = "✓",
      }
      opts.hooks = {
        diff_buf_read = function(bufnr) vim.b[bufnr].view_activated = false end,
        -- view_opened = function(_) vim.cmd "DiffviewFileHistory" end,
      }
    end,
    specs = {
      {
        "NeogitOrg/neogit",
        optional = true,
        opts = { integrations = { diffview = true } },
      },
    },
  },
}
