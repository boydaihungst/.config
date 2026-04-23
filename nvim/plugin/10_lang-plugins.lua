-- Language-based supported plugins should add to this file
-- Or 10_lang-plugins.lua file (lang is filetype/language)

-- Add keymaps for any lsp server that support inline completion
later(function()
  if vim.lsp.inline_completion.is_enabled() then
    Config.new_autocmd("LspAttach", nil, function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client:supports_method "textDocument/inlineCompletion" then
        vim.keymap.set(
          "i",
          "<C-l>",
          function() vim.lsp.inline_completion.get() end,
          { desc = "Accept inline completion" }
        )

        -- Switch to previous inline completion
        vim.keymap.set(
          "i",
          "<C-[>",
          function() vim.lsp.inline_completion.select { wrap = true, count = -1 } end,
          { desc = "Switch to previous inline completion" }
        )

        -- Switch to next inline completion
        vim.keymap.set(
          "i",
          "<C-]>",
          function() vim.lsp.inline_completion.select { wrap = true, count = 1 } end,
          { desc = "Switch to next inline completion" }
        )
        vim.api.nvim_del_augroup_by_name "nvim-inline-completion"
      end
    end, "Set keymaps for when a lsp support ", "nvim-inline-completion")
  end
end)

on_filetype({ "sql", "mysql" }, function()
  add { "https://github.com/nanotee/sqls.nvim" }

  --Remember to disable sqls lsp auto start in 05_lsp-servers.lua
  vim.lsp.config("sqls", {})
  vim.lsp.enable "sqls"
end)

on_filetype({
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
  "tsx",
  "vue",
  "svelte",
  "astro",
}, function()
  add {
    "https://github.com/dmmulroy/ts-error-translator.nvim",
  }
  require("ts-error-translator").setup {}
end)

-- Schema for json, yaml, etc.
on_event(
  { "BufReadPre" },
  { "*.yaml", "*.yml", ",*.json", "*.jsonc" },
  function()
    add {
      "https://github.com/b0o/schemastore.nvim",
    }
  end
)

on_filetype("yaml.ansible", function()
  add {
    "https://github.com/pearofducks/ansible-vim",
  }
end)

on_event("BufRead~package.json", function()
  add {
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/vuki656/package-info.nvim",
  }
  require("package-info").setup {
    highlights = {
      up_to_date = {
        fg = "#3C4048",
        ctermfg = 237,
      },
      outdated = {
        fg = "#d19a66",
        bold = true,
      },
      invalid = {
        fg = "#ee4b2b",
        bold = true,
      },
    },
    icons = {
      enable = true,
      style = {
        up_to_date = " ", -- Icon for up to date dependencies
        outdated = " ", -- Icon for outdated dependencies
        invalid = " ", -- Icon for invalid dependencies
      },
    },
    notifications = false, -- Whether to display notifications when running commands
    autostart = true, -- Whether to autostart when `package.json`  opened
    hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
    hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
    -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
    -- The plugin will try to auto-detect the package manager based on
    -- `yarn.lock` or `package-lock.json`. If none are found it will use the
    -- provided one, if nothing  provided it will use `yarn`
    package_manager = "npm",
  }
end)

-- Extra command for vtsls
later(function()
  Config.new_autocmd("LspAttach", nil, function(args)
    if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "vtsls" then
      add { "https://github.com/yioneko/nvim-vtsls" }
      require("vtsls")._on_attach(args.data.client_id, args.buf)
      vim.api.nvim_del_augroup_by_name "nvim_vtsls"
    end
  end, "Load nvim-vtsls with vtsls", "nvim_vtsls")
end)

-- :TSC command to check type for typescript
on_filetype(
  { "typescript", "javascript", "typescriptreact", "javascriptreact", "tsx", "vue", "svelte", "astro" },
  function()
    add { "https://github.com/dmmulroy/tsc.nvim" }
    require("tsc").setup {}
  end
)

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

on_filetype("python", function()
  if not (vim.fn.executable "fd" == 1 or vim.fn.executable "fdfind" == 1 or vim.fn.executable "fd-find" == 1) then
    add {
      "https://github.com/linux-cultist/venv-selector.nvim",
    }
    require("venv-selector").setup {}
  end

  add {
    "https://github.com/mfussenegger/nvim-dap-python",
  }
  local path = vim.fn.exepath "debugpy-adapter"
  if path == "" then path = vim.fn.exepath "uv" end
  if path == "" then path = vim.fn.exepath "python" end
  require("dap-python").setup(path, {})
end)
