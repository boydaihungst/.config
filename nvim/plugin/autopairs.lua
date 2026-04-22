on_event("InsertEnter", function()
  add { "https://github.com/windwp/nvim-autopairs" }
  require("nvim-autopairs").setup {
    check_ts = true,
    enabled = function(bufnr) return Config.is_valid_buf(bufnr) end,
    ts_config = { java = false },
    fast_wrap = {
      avoid_move_to_end = false,
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = ([[ [%'%"%)%>%]%)%}%,] ]]):gsub("%s+", ""),
      offset = 0,
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "PmenuSel",
      highlight_grey = "LineNr",
    },
  }

  vim.keymap.set("n", "\\a", function()
    local ok, autopairs = pcall(require, "nvim-autopairs")
    if ok then
      if autopairs.state.disabled then
        autopairs.enable()
      else
        autopairs.disable()
      end
    end
  end, { desc = "Toggle autopair" })
end)
