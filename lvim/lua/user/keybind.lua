lvim.leader = "space"
local which_key_mappings = {
  ["S"] = {
    name = "Session",
    s = { "<CMD>SearchSession<CR>", " Find Session" },
    r = { "<CMD>RestoreSession<CR>", " Restore Last Session" },
  },
  ["s"] = {
    s = { "<CMD>SearchSession<CR>", " Find Session" },
  },
  ["t"] = {
    name = "Testing",
    t = {
      '<cmd>lua require("neotest").summary.toggle()<CR>',
      "Toggle Summary",
    },
    r = {
      '<cmd>lua require("neotest").run.run()<CR>',
      "Run test: Nearest",
    },
    f = {
      '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>',
      "Run test: current file",
    },
    d = {
      '<cmd>lua require("neotest").run.run({strategy = "dap"})<CR>',
      "Debug test",
    },
    o = {
      "<cmd>lua require('neotest').output.open({ enter = true })<cr>",
      "Output",
    },
    s = {
      '<cmd>lua require("neotest").run.stop()<CR>',
      "Stop test",
    },
  },
}
local which_key_vmappings = {
  ["S"] = {
    name = "Session",
    s = { "<ESC><CMD>SearchSession<CR>", " Find Session" },
    r = { "<ESC><CMD>RestoreSession<CR>", " Restore Last Session" },
  },
  ["s"] = {
    s = { "<ESC><CMD>SearchSession<CR>", " Find Session" },
  },
  ["t"] = {
    name = "Testing",
    t = {
      '<ESC><cmd>lua require("neotest").summary.toggle()<CR>',
      "Toggle Summary",
    },
    r = {
      '<ESC><cmd>lua require("neotest").run.run()<CR>',
      "Run test",
    },
    f = {
      '<ESC><cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>',
      "Run test: current file",
    },
    d = {
      '<ESC><cmd>lua require("neotest").run.run({strategy = "dap"})<CR>',
      "Debug test",
    },
    o = {
      "<ESC><cmd>lua require('neotest').output.open({ enter = true })<cr>",
      "Output",
    },
    s = {
      '<ESC><cmd>lua require("neotest").run.stop()<CR>',
      "Stop test",
    },
  },
}
lvim.builtin.which_key.opts.silent = false
lvim.builtin.which_key.vopts.silent = false
lvim.builtin.which_key.mappings = vim.tbl_deep_extend("force", lvim.builtin.which_key.mappings, which_key_mappings)
lvim.builtin.which_key.vmappings = vim.tbl_deep_extend("force", lvim.builtin.which_key.vmappings, which_key_vmappings)
local keymappings = {
  normal_mode = {
    -- nmap
    ["<C-s>"] = { ":w<CR>" },
    ["f"] = { ":HopChar2<CR>", { silent = true } },
    ["F"] = { ":HopWord<CR>", { silent = true } },
    -- ["gbb"] = {
    --   "<Plug>comment_toggle_blockwise_current", { silent = true, desc = "Comment toggle blockwise" }
    -- },
    -- ["gbc"] = {
    --   ":Neogen class<CR>", { silent = true, desc = "Comment Class" }
    -- },
    ["gbf"] = {
      ":Neogen func<CR>", { silent = true, desc = "Comment Function" }
    },

  },
  insert_mode = {
    -- imap
  },
  visual_mode = {
    -- vmap
    -- ["gbb"] = {
    --   "<Plug>comment_toggle_blockwise_current", { silent = true, desc = "Comment toggle blockwise" }
    -- },
    -- ["gbc"] = {
    --   "<ESC>:Neogen class<CR>", { silent = true, desc = "Comment Class" }
    -- },
    ["gbf"] = {
      "<ESC>:Neogen func<CR>", { silent = true, desc = "Comment Function" }
    },
  },
  term_mode = {
    -- for termial window
    ["esc"] = {
      [[<C-\><C-n>]],
      { buffer = 0 },
    },
  },
  visual_block_mode = {
    -- vmap block
    -- ["gbb"] = {
    --   "<Plug>comment_toggle_blockwise_current", { silent = true, desc = "Comment toggle blockwise" }
    -- },
    -- ["gbc"] = {
    --   "<ESC>:Neogen class<CR>", { silent = true, desc = "Comment Class" }
    -- },
    ["gbf"] = {
      "<ESC>:Neogen func<CR>", { silent = true, desc = "Comment Function" }
    },
  },
  command_mode = {
    --cmap
  },
}
lvim.keys = vim.tbl_deep_extend("force", lvim.keys, keymappings)
