-- autopairs
-- https://github.com/windwp/nvim-autopairs

---@module 'lazy'
---@type LazySpec
return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    check_ts = true,
    --enabled = function(bufnr) return require('astrocore.buffer').is_valid(bufnr) end,
    ts_config = { java = false },
    fast_wrap = {
      avoid_move_to_end = false,
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = ([[ [%'%"%)%>%]%)%}%,] ]]):gsub('%s+', ''),
      offset = 0,
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      highlight = 'PmenuSel',
      highlight_grey = 'LineNr',
    },
  },
}
