---@type LazySpec
return {
  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      local cowsay = function()
        local max_width = 80
        local fortune_result = require "alpha.fortune" { max_width = max_width }
        local text = table.concat({ unpack(fortune_result, 2, #fortune_result) }, "\n")
        local result = vim.fn.system(string.format('cowsay -W %s "%s"', max_width, text))
        return result
      end

      opts.section.header.val = cowsay()
      -- customize the dashboard header
      -- opts.section.header.val = {
      --   " █████  ███████ ████████ ██████   ██████",
      --   "██   ██ ██         ██    ██   ██ ██    ██",
      --   "███████ ███████    ██    ██████  ██    ██",
      --   "██   ██      ██    ██    ██   ██ ██    ██",
      --   "██   ██ ███████    ██    ██   ██  ██████",
      --   " ",
      --   "    ███    ██ ██    ██ ██ ███    ███",
      --   "    ████   ██ ██    ██ ██ ████  ████",
      --   "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
      --   "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
      --   "    ██   ████   ████   ██ ██      ██",
      -- }
      return opts
    end,
  },
}
