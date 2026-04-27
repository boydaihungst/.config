-- This is a library plugin, so it shouldn't be lazy-loaded
-- So we don't have to add on_packchanged any where we require it
now(function()
  vim.pack.on_packchanged(
    "lua-json5",
    { "install", "update" },
    function(data)
      vim
        .system(vim.fn.has "win32" == 1 and { "powershell", "./install.ps1" } or { "./install.sh" }, { cwd = data.path })
        :wait()
    end,
    "Install json5"
  )
  add {
    "https://github.com/Joakker/lua-json5",
  }
end)
