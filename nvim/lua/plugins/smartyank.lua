---@type LazySpec
return {
  "ibhagwan/smartyank.nvim",
  enabled = true,
  lazy = true,
  event = "VeryLazy",
  config = function()
    require("smartyank").setup {
      highlight = {
        enabled = false, -- highlight yanked text
        higroup = "IncSearch", -- highlight group of yanked text
        timeout = 2000, -- timeout for clearing the highlight
      },
      clipboard = {
        enabled = true,
      },
      tmux = {
        enabled = vim.env.TMUX ~= nil,
        -- remove `-w` to disable copy to host client's clipboard
        cmd = { "tmux", "set-buffer", "-w" },
      },
      osc52 = {
        enabled = true,
        escseq = vim.env.TMUX ~= nil and "tmux" or nil, -- use tmux escape sequence, only enable if
        -- you're using tmux and have issues (see #4)
        ssh_only = true, -- false to OSC52 yank also in local sessions
        silent = true, -- true to disable the "n chars copied" echo
        echo_hl = "Directory", -- highlight group of the OSC52 echo message
      },
      -- By default copy is only triggered by "intentional yanks" where the
      -- user initiated a `y` motion (e.g. `yy`, `yiw`, etc). Set to `false`
      -- if you wish to copy indiscriminately:
      -- validate_yank = false,
      --
      -- For advanced customization set to a lua function returning a boolean
      -- for example, the default condition is:
      -- validate_yank = function() return vim.v.operator == "y" end,
    }
  end,
  dependencies = {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      options = {
        opt = { -- vim.opt.<key>
          -- Set this to prevent yank from overwriting the system clipboard
          -- clipboard = "",
        },
      },
    },
  },
}
