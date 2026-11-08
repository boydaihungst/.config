local linters_cfg = {
  linters_by_ft = {
    -- sh = { "shellcheck" },
    zsh = { "shellcheck" },
    ansible = { "ansible_lint" },
    dockerfile = { "hadolint" },
    fish = { "fish" },
    kotlin = { "ktlint" },
    -- lua = { "selene" }, -- prefer lsp server instead
    proto = { "buf_lint" },
    sql = { "sqlfluff" },
    -- toml = { "tombi" }, -- prefer lsp server instead
  },
  linters = {
    -- selenne = {
    --   condition = function(ctx)
    --     return #vim.fs.find("selene.toml", { path = ctx.filename, upward = true, type = "file" }) > 0
    --   end,
    -- },
    shellcheck = {
      -- Ignore ebuild files
      condition = function(ctx) return not ctx.filename:match "%.ebuild$" end,
    },
  },
}

later(function()
  add {
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mfussenegger/nvim-lint",
  }
  local lint = require "lint"
  local opts = linters_cfg

  lint.linters_by_ft = opts.linters_by_ft or {}
  for name, linter in pairs(opts.linters or {}) do
    local base = lint.linters[name]
    lint.linters[name] = (type(linter) == "table" and type(base) == "table")
        and vim.tbl_deep_extend("force", base, linter)
      or linter
  end

  local valid_linters = function(ctx, linters)
    if not linters then return {} end
    return vim.tbl_filter(function(name)
      local linter = lint.linters[name]
      return linter
        and vim.fn.executable(linter.cmd) == 1
        and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
    end, linters)
  end

  ---@param orig? function the original function to override, if `nil`  provided then an empty function is passed
  ---@param override fun(orig:function, ...):... the override function
  ---@return function patched the new function with the patch applied
  local function patch_func(orig, override)
    if not orig then orig = function() end end
    return function(...) return override(orig, ...) end
  end
  lint._resolve_linter_by_ft = patch_func(lint._resolve_linter_by_ft, function(orig, ...)
    local ctx = { filename = vim.api.nvim_buf_get_name(0) }
    ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")

    local linters = valid_linters(ctx, orig(...))
    if not linters[1] then linters = valid_linters(ctx, lint.linters_by_ft["_"]) end -- fallback

    linters = vim.tbl_unique_extend(linters, valid_linters(ctx, lint.linters_by_ft["*"])) -- global

    return linters
  end)

  lint.try_lint()

  local timer = (vim.uv or vim.loop).new_timer()
  Config.new_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, nil, function()
    -- only run autocommand when nvim-lint  loaded
    if lint and timer then
      timer:start(100, 0, function()
        timer:stop()
        vim.schedule(lint.try_lint)
      end)
    end
  end)
end)
