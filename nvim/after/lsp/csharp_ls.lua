return {
  filetypes = { "cs", "razor" },
  get_language_id = function(_, ft)
    if ft == "cs" then return "csharp" end
    if ft == "razor" then return "razor-csharp" end
    return ft
  end,
  settings = {
    csharp = {
      razorSupport = true,
    },
  },
  on_attach = function(client, bufnr)
    if vim.pack.is_available "csharpls_extended" then require("csharpls_extended").buf_read_cmd_bind() end
  end,
}
