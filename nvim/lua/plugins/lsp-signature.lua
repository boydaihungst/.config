return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "ray-x/lsp_signature.nvim",
    opts = {
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      hint_prefix = " ",
      -- floating_window = false,
      hint_enable = false,
      hi_parameter = "@text.underline",
      handler_opts = {
        border = "rounded",
      },
      max_width = 80,
      select_signature_key = "<C-Tab>",
    },
  },
}
