-- This is a library plugin, so it shouldn't be lazy-loaded
-- So we don't have to add on_packchanged any where we require it
now(function()
  local function build_json5(path)
    vim
      .system(vim.fn.has "win32" == 1 and { "powershell", "./install.ps1" } or { "./install.sh" }, { cwd = path })
      :wait()
  end
  vim.pack.on_packchanged("lua-json5", { "update" }, function(data) build_json5(data.path) end, "Install json5")
  add {
    "https://github.com/Joakker/lua-json5",
  }
  if not pcall(require, "json5") then
    local _, pkgs = pcall(vim.pack.get, { "lua-json5" }, { info = false })
    if pkgs and pkgs[1] then
      local path = pkgs[1].path
      if path then build_json5(path) end
    end
  end
end)
