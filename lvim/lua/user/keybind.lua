lvim.leader = "space"
local which_key_mappings = {
  ["n"] = {
    "<CMD>enew<CR>", "New buffer"
  },
  ['r'] = {
    name = "Search and Replace",

    ["o"] = { "<CMD>SearchReplaceSingleBufferOpen<CR>", "[o]pen" },
    ["w"] = { "<CMD>SearchReplaceSingleBufferCWord<CR>", "[w]ord" },
    ["W"] = { "<CMD>SearchReplaceSingleBufferCWORD<CR>", "[W]ORD" },
    ["p"] = { "<CMD>SearchReplaceSingleBufferCFile<CR>", "[p]ath file" },
    ["m"] = {
      name = "Multiple Buffer",
      ["o"] = { "<CMD>SearchReplaceMultiBufferOpen<CR>", "[o]pen" },
      ["w"] = { "<CMD>SearchReplaceMultiBufferCWord<CR>", "[w]ord" },
      ["W"] = { "<CMD>SearchReplaceMultiBufferCWORD<CR>", "[W]ORD" },
      ["p"] = { "<CMD>SearchReplaceMultiBufferCFile<CR>", "[p]ath file" },
    }
  },
  ["S"] = {
    name = "Session",
    s = { "<CMD>SearchSession<CR>", " Find Session" },
    r = { "<CMD>RestoreSession<CR>", " Restore Last Session" },
  },
  ["s"] = {
    s = { "<CMD>SearchSession<CR>", " Find Session" },
    l = { "<CMD>Telescope filetypes<CR>", "Change file language (type)" }
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
  ['T'] = {
    ['t'] = {
      "<cmd>TSPlaygroundToggle<CR>",
      "Toggle playground"
    },
    ['c'] = {
      "<cmd>TSHighlightCapturesUnderCursor<CR>",
      "Highlight Under Cursor"
    },
  },
  ["l"] = {
    name = "LSP",
    a = { "<cmd>Lspsaga code_action<cr>", "Code Action" },
    d = { "<cmd>Lspsaga show_line_diagnostics ++unfocus<cr>", "Diagnostics in line" },
    w = { "<cmd>Lspsaga show_buf_diagnostics<cr>", "Diagnostics in buffer" },
    f = { "<cmd>lua require('lvim.lsp.utils').format()<cr>", "Format" },
    i = { "<cmd>LspInfo<cr>", "Info" },
    I = { "<cmd>Mason<cr>", "Mason Info" },
    j = {
      "<cmd>Lspsaga diagnostic_jump_next<cr>",
      "Next Diagnostic",
    },
    k = {
      "<cmd>Lspsaga diagnostic_jump_prev<cr>",
      "Prev Diagnostic",
    },
    l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
    r = { "<cmd>Lspsaga rename<cr>", "Rename" },
    o = { "<cmd>Lspsaga outline<cr>", "Document Outline" },
    S = {},
    e = {},
  },
  [";"] = {}
}
local which_key_vmappings = {
  ["S"] = {
    name = "Session",
    s = { "<ESC><CMD>SearchSession<CR>", " Find Session" },
    r = { "<ESC><CMD>RestoreSession<CR>", " Restore Last Session" },
  },
  ["s"] = {
    s = { "<ESC><CMD>SearchSession<CR>", " Find Session" },
    l = { "<CMD>Telescope filetypes<CR>", "Change file language (type)" }
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
  ['T'] = {
    ['t'] = {
      "<ESC><cmd>TSPlaygroundToggle<CR>",
      "Toggle playground"
    },
    ['c'] = {
      "<ESC><cmd>TSHighlightCapturesUnderCursor<CR>",
      "Highlight Under Cursor"
    },
  }
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
    ["gbf"] = {
      ":Neogen func<CR>", { silent = true, desc = "Comment Function" }
    },
    ["gbC"] = {
      ":Neogen class<CR>", { silent = true, desc = "Comment Class" }
    },
    ["<F2>"] = { ":Alpha<CR>", { silent = true, desc = "Dashboard" } }
  },
  insert_mode = {
    -- imap
  },
  visual_mode = {
    -- vmap
    ["gbf"] = {
      "<ESC>:Neogen func<CR>", { silent = true, desc = "Comment Function" }
    },
    ["gbC"] = {
      "<ESC>:Neogen class<CR>", { silent = true, desc = "Comment Class" }
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
    ["gbf"] = {
      "<ESC>:Neogen func<CR>", { silent = true, desc = "Comment Function" }
    },
    ["gbC"] = {
      "<ESC>:Neogen class<CR>", { silent = true, desc = "Comment Class" }
    },
    -- replace selected text
    ["<C-r>"] = { [[<CMD>SearchReplaceSingleBufferVisualSelection<CR>]] },
    -- replace in selected block
    ["<C-s>"] = { [[<CMD>SearchReplaceWithinVisualSelection<CR>]] },
    -- replace in selected block with word under cursor
    ["<C-b>"] = { [[<CMD>SearchReplaceWithinVisualSelectionCWord<CR>]] },
  },
  command_mode = {
    --cmap
  },
}
lvim.keys = vim.tbl_deep_extend("force", lvim.keys, keymappings)
-- lvim.lsp.buffer_mappings.normal_mode["gr"] = { "<cmd>Telescope lsp_references<cr>", "Go to Definiton" }
-- lvim.lsp.buffer_mappings.normal_mode["gr"] = { "<cmd>Telescope lsp_references<cr>", "Go to Definiton" }
-- lvim.lsp.buffer_mappings.normal_mode["gr"] = { "<cmd>Telescope lsp_references<cr>", "Go to Definiton" }
lvim.lsp.buffer_mappings = {
  normal_mode = {
    ["K"] = { "<cmd>Lspsaga hover_doc ++quiet<cr>", "Show hover" },
    ["gd"] = { "<cmd>Lspsaga peek_definition<cr>", "Peak Definition" },
    ["gD"] = { "<cmd>Lspsaga goto_definition<cr>", "Goto Definition" },
    ["gr"] = { "<cmd>Lspsaga lsp_finder<cr>", "Goto References" },
    ["gI"] = { "<cmd>Lspsaga lsp_finder<cr>", "Goto Implementation" },
    ["gs"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "show signature help" },
    ["gl"] = { "<cmd>Lspsaga show_line_diagnostics<cr>", "Show line diagnostics" },
  },
  insert_mode = {},
  visual_mode = {},
}
local function telescope_find_files(_)
  require("lvim.core.nvimtree").start_telescope "find_files"
end

local function telescope_live_grep(_)
  require("lvim.core.nvimtree").start_telescope "live_grep"
end

lvim.builtin.nvimtree.setup.view.mappings.list = {
  { key = { "l", "<CR>", "o" }, action = "edit",                 mode = "n" },
  { key = "h",                  action = "close_node" },
  { key = "v",                  action = "vsplit" },
  { key = "C",                  action = "cd" },
  { key = "gtf",                action = "telescope_find_files", action_cb = telescope_find_files },
  { key = "gtg",                action = "telescope_live_grep",  action_cb = telescope_live_grep },
  -- Use d as trash, use D as remove permanently
  { key = 'd',                  action = 'trash' }
}
