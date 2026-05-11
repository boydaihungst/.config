---@type LazySpec
return {
  "rcarriga/nvim-dap-ui",
  optional = true,
  {
    -- virtual text for the debugger
    "theHamsta/nvim-dap-virtual-text",
    optional = true,
    opts = {
      virt_text_pos = "eol",
      virt_text_win_col = 70,
      commented = false,
      all_references = true,
    },
  },
}
