local prefix = "<leader>m"
---@type LazySpec
return {
  "mg979/vim-visual-multi",
  event = { "User AstroFile", "InsertEnter" },
  init = function()
    -- Prevent overlapping with astrocore horizontal split key
    vim.g.VM_leader = vim.g.VM_leader or prefix
    vim.g.VM_silent_exit = 1
    vim.g.VM_show_warnings = 0
    -- Remap <cr> to fix enter to select in blink
    -- Source: https://github.com/Saghen/blink.cmp/issues/406#issuecomment-2537184121
    -- Check this if you use VM_custom_motions: https://github.com/Saghen/blink.cmp/issues/406#issuecomment-3239199356
    vim.g.VM_maps = {
      ["I BS"] = "",
      ["Goto Next"] = "]v",
      ["Goto Prev"] = "[v",
      ["I CtrlB"] = "<M-b>",
      ["I CtrlF"] = "<M-f>",
      ["I Return"] = "<S-CR>",
      ["I Down Arrow"] = "",
      ["I Up Arrow"] = "",
    }
    vim.api.nvim_set_hl(0, "VM_Cursor", { link = "Cursor" })
    vim.api.nvim_set_hl(0, "VM_MONO", { link = "Cursor" })
  end,
  dependencies = {
    { "AstroNvim/astroui", opts = { icons = { VimVisualMulti = "󰗧" } } },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = {
        autocmds = {
          visual_multi_mappings = {
            {
              event = "User",
              pattern = "visual_multi_mappings",
              desc = "p and P to paste from system clipboard",
              callback = function()
                -- Remap p and P to paste (from + or * register) because `opt.clipboard = "unnamedplus"` in astrocore
                -- Source: https://github.com/mg979/vim-visual-multi/issues/116
                if vim.tbl_contains(vim.opt.clipboard:get(), "unnamedplus") then
                  vim.keymap.set("n", "p", '"+<Plug>(VM-p-Paste)', { buffer = true })
                  vim.keymap.set("n", "P", '"+<Plug>(VM-P-Paste)', { buffer = true })
                elseif vim.tbl_contains(vim.opt.clipboard:get(), "unnamed") then
                  vim.keymap.set("n", "p", '"*<Plug>(VM-p-Paste)', { buffer = true })
                  vim.keymap.set("n", "P", '"*<Plug>(VM-P-Paste)', { buffer = true })
                end
              end,
            },
          },
        },

        mappings = {
          n = {
            [prefix] = { desc = require("astroui").get_icon("VimVisualMulti", 1, true) .. "Multi cursors" },
            [prefix .. "A"] = { desc = "Select all occurrences word under cursor" },
            [prefix .. "/"] = { desc = "Start regex search" },
            [prefix .. "\\"] = { desc = "Add a single cursor at current position" },
            [prefix .. "gS"] = { desc = "Reselect last visual selection" },
            ["<C-up>"] = { "<C-u>call vm#commands#add_cursor_up(0, v:count1)<cr>", desc = "Add cursor above" },
            ["<C-down>"] = { "<C-u>call vm#commands#add_cursor_down(0, v:count1)<cr>", desc = "Add cursor below" },
          },
          v = {
            [prefix] = { desc = require("astroui").get_icon("VimVisualMulti", 1, true) .. "Multi cursors" },
            [prefix .. "a"] = { desc = "Convert a visual selection to a VM selection" },
            [prefix .. "a"] = { desc = "Convert a visual selection to a VM selection" },
            [prefix .. "A"] = { desc = "Select all occurrences of selection text" },
            [prefix .. "c"] = { desc = "Add cursors downwards from start of visual block" },
            [prefix .. "/"] = { desc = "Start regex search within selected text" },
          },
        },
      },
    },
  },
}
