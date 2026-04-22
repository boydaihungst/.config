on_event("BufEnter", function()
  local prefix = "<leader>m"
  vim.g.VM_leader = vim.g.VM_leader or prefix
  vim.g.VM_silent_exit = 1
  vim.g.VM_show_warnings = 0

  -- Remap <cr> to fix enter to select in blink
  -- Source: https://github.com/Saghen/blink.cmp/sues/406#issuecomment-2537184121
  -- Check th if you use VM_custom_motions: https://github.com/Saghen/blink.cmp/issues/406#issuecomment-3239199356
  vim.g.VM_maps = {
    ["I BS"] = "",
    ["Goto Next"] = "]v",
    ["Goto Prev"] = "[v",
    ["I CtrlB"] = "<M-b>",
    ["I CtrlF"] = "<M-f>",
    ["I Return"] = "<S-CR>",
    ["I Down Arrow"] = "",
    ["I Up Arrow"] = "",

    ["Add Cursor Down"] = "<M-Down>",
    ["Add Cursor Up"] = "<M-Up>",
  }
  -- To use the same highlight as search
  vim.g.VM_highlight_matches = ""

  add { "https://github.com/mg979/vim-visual-multi" }
  vim.api.nvim_set_hl(0, "VM_Cursor", { link = "Cursor" })
  vim.api.nvim_set_hl(0, "VM_mono", { link = "Cursor" })
  Config.new_autocmd("User", "visual_multi_mappings", function()
    -- Remap p and P to paste (from + or * register) because `opt.clipboard = "unnamedplus"`
    -- Source: https://github.com/mg979/vim-visual-multi/issues/116
    if vim.tbl_contains(vim.opt.clipboard:get(), "unnamedplus") then
      vim.keymap.set("n", "p", '"+<Plug>(VM-p-Paste)', { buf = 0 })
      vim.keymap.set("n", "P", '"+<Plug>(VM-P-Paste)', { buf = 0 })
    elseif vim.tbl_contains(vim.opt.clipboard:get(), "unnamed") then
      vim.keymap.set("n", "p", '"*<Plug>(VM-p-Paste)', { buf = 0 })
      vim.keymap.set("n", "P", '"*<Plug>(VM-P-Paste)', { buf = 0 })
    end
  end, "p and P to paste from system clipboard")

  if wk then
    wk.add {
      {
        prefix,
        group = Config.get_custom_icon("VimVisualMulti", 1, true) .. "Multi Cursors",
        mode = { "n", "v" },
      },
      { prefix .. "A", desc = "Select all occurrences word under cursor", mode = "n" },
      { prefix .. "/", desc = "Start regex search", mode = "n" },
      { prefix .. "\\", desc = "Add a single cursor at current position", mode = "n" },
      { prefix .. "gS", desc = "Reselect last visual selection", mode = "n" },

      -- visual mode groups
      { prefix, group = "Multi Cursors", mode = "v" },
      { prefix .. "a", desc = "Convert a visual selection to a VM selection", mode = "v" },
      { prefix .. "A", desc = "Select all occurrences of selection text", mode = "v" },
      { prefix .. "c", desc = "Add cursors downwards from start of visual block", mode = "v" },
      { prefix .. "/", desc = "Start regex search within selected text", mode = "v" },
    }
  end
end)
