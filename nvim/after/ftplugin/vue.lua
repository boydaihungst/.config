-- Auto import missing imports after exit insert mode
-- vim.api.nvim_create_autocmd({ "InsertLeave" }, {
--   group = vim.api.nvim_create_augroup("js_auto_import", { clear = true }),
--   buffer = 0, -- restrict to current buffer only (which is typescript)
--   callback = function(event)
--     local file_name = event["file"]
--     local buffer = event["buf"]
--     if not file_name or not buffer then return end
--     require("vtsls").commands.add_missing_imports(buffer)
--   end,
-- })

if vim.fn.exists ":TSC" ~= 0 then
  vim.keymap.set({ "n", "v" }, "<Leader>lt", "<cmd>TSC<cr>", { desc = "TSC: Type checking", buf = 0 })
end

if vim.pack.is_available "nvim-vtsls" then
  vim.keymap.set(
    "n",
    "<Leader>lO",
    function() require("vtsls").commands.goto_source_definition() end,
    { desc = "Goto Source Definition (vtsls)", buf = 0 }
  )
end
