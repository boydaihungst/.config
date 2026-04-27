-- Language-based supported plugins should add to this file
-- Or 10_lang-plugins.lua file (lang is filetype/language)
later(function()
  local uname = (vim.uv or vim.loop).os_uname()
  local is_linux_arm = uname.sysname == "Linux" and (uname.machine == "aarch64" or vim.startswith(uname.machine, "arm"))

  Config.new_autocmd("LspAttach", nil, function(args)
    if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
      add { "https://github.com/p00f/clangd_extensions.nvim" }
      require "clangd_extensions"
      vim.keymap.set(
        "n",
        "<Leader>lw",
        "<Cmd>ClangdSwitchSourceHeader<CR>",
        { desc = "Switch source/header file", buf = args.buf }
      )
      vim.api.nvim_del_augroup_by_name "clangd_extensions"
    end
  end, "Load clangd_extensions and add keymaps with clangd", "clangd_extensions")

  if is_linux_arm then
    -- Force enable clangd for arm arch. Because we don't install clangd from mason
    -- We use built-in clangd arm instead
    vim.lsp.enable "clangd"
  end
end)

on_filetype({ "c", "cpp", "objc", "objcpp", "cuda", "proto" }, function()
  add {
    "https://github.com/Civitasv/cmake-tools.nvim",
  }
  require("cmake-tools").setup {}
end)
