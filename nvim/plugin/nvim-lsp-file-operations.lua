now(function()
  add { "https://github.com/antosha417/nvim-lsp-file-operations" }
  vim.lsp.config("*", {
    capabilities = require("lsp-file-operations").default_capabilities(),
  })
end)

later(function()
  require("lsp-file-operations").setup {}
  local ok_mini_files, _ = pcall(require, "mini.files")
  local log = require "lsp-file-operations.log"
  if ok_mini_files then
    log.debug "Setting up mini.files integration"

    Config.new_autocmd(
      "User",
      "MiniFilesActionCreate",
      function(args) require("lsp-file-operations.did-create").callback { fname = args.data.to } end,
      "execute `didCreateFiles` operation when creating files"
    )

    Config.new_autocmd("User", "MiniFilesActionDelete", function(args)
      vim.schedule(function() vim.notify("Deleted: " .. args.data.from) end)
      require("lsp-file-operations.did-delete").callback { fname = args.data.from }
      -- Auto close deleted buffers under deleted path
      local closed_buffers = vim.api.nvim_get_buffers_rel_path(args.data.from)
      if #closed_buffers > 0 then
        for _, closed_buf in ipairs(closed_buffers) do
          Config.close_buffer(closed_buf, true)
        end
      end
    end, "execute `didDeleteFiles` operation when creating files")

    Config.new_autocmd(
      "User",
      "MiniFilesActionRename",
      function(args)
        require("lsp-file-operations.did-rename").callback { old_name = args.data.from, new_name = args.data.to }
      end,
      "execute `didRenameFiles` operation when creating files"
    )
  end
end)
