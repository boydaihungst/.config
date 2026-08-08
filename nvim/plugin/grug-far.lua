later(function()
  add { "https://github.com/MagicDuck/grug-far.nvim" }
  require("grug-far").setup {
    transient = true,
  }
  vim.api.nvim_set_hl(0, "GrugFarResultsMatch", { link = "Search" })
  local default_opts = { instanceName = "main" }
  local function grug_far_open(opts, with_visual)
    local grug_far = require "grug-far"
    opts = vim.tbl_extend("force", default_opts, opts or {})
    if not grug_far.has_instance(opts.instanceName) then
      grug_far.open(opts)
    else
      if with_visual then
        if not opts.prefills then opts.prefills = {} end
        opts.prefills.search = grug_far.get_current_visual_selection()
      end
      grug_far.get_instance(opts.instanceName):open()
      if opts.prefills then grug_far.get_instance(opts.instanceName):update_input_values(opts.prefills, false) end
    end
  end
  if MiniFiles then
    Config.new_autocmd("User", "MiniFilesBufferCreate", function(args)
      vim.keymap.set(
        "n",
        "?",
        function() grug_far_open { prefills = { paths = vim.fs.dirname(require("mini.files").get_fs_entry().path) } } end,
        { buf = args.data.buf_id, desc = "Search/Replace in directory" }
      )
    end, "Create mapping `mini.files` for searching in directory")
  end
  local key_prefix = "<Leader>s"
  if wk then
    wk.add { { key_prefix, group = Config.get_custom_icon("GrugFar", 1, true) .. "Search/Replace", mode = { "n", "x" } } }
  end
  -- Workspace Search
  vim.keymap.set("n", key_prefix .. "s", function() grug_far_open() end, { desc = "Search/Replace workspace" })

  -- Filetype Search
  vim.keymap.set("n", key_prefix .. "e", function()
    local ext = vim.api.nvim_buf_is_valid(0) and vim.bo.buflisted and vim.fn.expand "%:e" or ""
    grug_far_open {
      prefills = { filesFilter = ext ~= "" and "*." .. ext or nil },
    }
  end, { desc = "Search/Replace filetype" })

  -- Current File Search
  vim.keymap.set("n", key_prefix .. "f", function()
    local filter = vim.api.nvim_buf_is_valid(0) and vim.bo.buflisted and vim.fn.fnameescape(vim.fn.expand "%") or nil
    grug_far_open { prefills = { paths = filter } }
  end, { desc = "Search/Replace file" })

  -- Word under cursor (Normal mode)
  vim.keymap.set("n", key_prefix .. "w", function()
    local current_word = vim.fn.expand "<cword>"
    if current_word ~= "" then
      grug_far_open {
        startCursorRow = 4,
        prefills = { search = current_word },
      }
    else
      vim.notify("No word under cursor", vim.log.levels.WARN, { title = "Grug-far" })
    end
  end, { desc = "Search/Replace word" })

  -- Selection Search (visual mode)
  vim.keymap.set("x", key_prefix .. "w", function() grug_far_open(nil, true) end, { desc = "Replace selection" })
end)
