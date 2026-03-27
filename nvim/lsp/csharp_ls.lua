return {
  filetypes = { "cs", "razor" },
  get_language_id = function(_, ft)
    vim.notify(ft)
    if ft == "cs" then return "csharp" end
    if ft == "razor" then return "razor-csharp" end
    return ft
  end,
  settings = {
    csharp = {
      razorSupport = true,
    },
  },
  on_attach = function(client, bufnr) require("csharpls_extended").buf_read_cmd_bind() end,
}
