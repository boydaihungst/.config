now(function()
  add { "https://github.com/NMAC427/guess-indent.nvim" }
  local guess_indent = require "guess-indent"
  Config.new_autocmd(
    { "BufReadPost", "BufWritePre" },
    "*",
    function(args) guess_indent.set_from_buffer(args.buf, true, true) end,
    "Guess indentation when loading/saving a file"
  )
end)
