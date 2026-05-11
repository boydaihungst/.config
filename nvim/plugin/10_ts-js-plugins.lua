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

  local function add_keymaps(buf)
    -- Toggle dependency versions
    vim.keymap.set(
      { "n" },
      "\\p",
      require("package-info").toggle,
      { buf = buf, silent = true, noremap = true, desc = "Toggle dependencies version" }
    )
    -- Update dependency on the line
    vim.keymap.set(
      { "n" },
      "<leader>lpu",
      require("package-info").update,
      { buf = buf, silent = true, noremap = true, desc = "Update dependency current line" }
    )
    -- Delete dependency on the line
    vim.keymap.set(
      { "n" },
      "<leader>lpd",
      require("package-info").delete,
      { buf = buf, silent = true, noremap = true, desc = "Delete dependency current line" }
    )
    -- Install a new dependency
    vim.keymap.set(
      { "n" },
      "<leader>lpa",
      require("package-info").install,
      { buf = buf, silent = true, noremap = true, desc = "Add new dependency" }
    )
    -- Install a different dependency version
    vim.keymap.set(
      { "n" },
      "<leader>lpi",
      require("package-info").change_version,
      { buf = buf, silent = true, noremap = true, desc = "Install a different dependency version" }
    )
    if wk then wk.add {
      { "<Leader>lp", mode = "n", group = " Package info", buffer = buf },
    } end
  end

  Config.new_autocmd(
    "BufRead",
    "package.json",
    function(args) add_keymaps(args.buf) end,
    "add keymaps for package-info",
    "package_info"
  )
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match "package%.json$" then add_keymaps(buf) end
  end
end)

-- Extra command for vtsls
now_if_args(function()
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
