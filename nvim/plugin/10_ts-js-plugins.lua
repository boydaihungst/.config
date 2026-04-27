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
    "https://github.com/marilari88/neotest-vitest",
    "https://github.com/nvim-neotest/neotest-jest",
  }
  ---@diagnostic disable-next-line: missing-fields
  require("ts-error-translator").setup {}
  if vim.pack.is_available "neotest" then
    table.insert(require("neotest.config").adapters, require "neotest-jest" {})
    table.insert(require("neotest.config").adapters, require "neotest-vitest" {})
  end
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
