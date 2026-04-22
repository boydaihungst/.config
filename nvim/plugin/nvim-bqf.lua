on_filetype("qf", function()
  add { "https://github.com/kevinhwang91/nvim-bqf" }

  vim.fn.sign_define("BqfSign", {
    text = " " .. Config.get_custom_icon "Selected",
    texthl = "BqfSign",
  })
  require("bqf").setup {}
end)
