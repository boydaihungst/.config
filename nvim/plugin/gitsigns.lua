now_if_args(function()
  if not vim.fn.executable "git" == 1 then return end
  add { "https://github.com/lewis6991/gitsigns.nvim" }

  local get_icon = Config.get_custom_icon
  local gitsigns = require "gitsigns"
  local opts = {
    max_file_length = require("largefile").default_large_buf_opts.lines,
    gh = true,
    signs = {
      add = { text = get_icon "GitSign" },
      change = { text = get_icon "GitSign" },
      delete = { text = get_icon "GitSign" },
      topdelete = { text = get_icon "GitSign" },
      changedelete = { text = get_icon "GitSign" },
      untracked = { text = get_icon "GitSign" },
    },
    signs_staged = {
      add = { text = get_icon "GitSign" },
      change = { text = get_icon "GitSign" },
      delete = { text = get_icon "GitSign" },
      topdelete = { text = get_icon "GitSign" },
      changedelete = { text = get_icon "GitSign" },
      untracked = { text = get_icon "GitSign" },
    },
    on_attach = function(bufnr)
      if require("largefile").is_large(bufnr) then return end
      local prefix = "<Leader>g"
      -- Normal Mode Mappings
      vim.keymap.set("n", prefix .. "l", function() gitsigns.blame_line() end, { buf = bufnr, desc = "View Git blame" })
      vim.keymap.set(
        "n",
        prefix .. "L",
        function() gitsigns.blame_line { full = true } end,
        { buf = bufnr, desc = "View full Git blame" }
      )
      vim.keymap.set(
        "n",
        prefix .. "p",
        function() gitsigns.preview_hunk_inline() end,
        { buf = bufnr, desc = "Preview Git hunk" }
      )
      vim.keymap.set("n", prefix .. "r", function() gitsigns.reset_hunk() end, { buf = bufnr, desc = "Reset Git hunk" })
      vim.keymap.set(
        "n",
        prefix .. "R",
        function() gitsigns.reset_buffer() end,
        { buf = bufnr, desc = "Reset Git buffer" }
      )
      vim.keymap.set(
        "n",
        prefix .. "s",
        function() gitsigns.stage_hunk() end,
        { buf = bufnr, desc = "Stage/Unstage Git hunk" }
      )
      vim.keymap.set(
        "n",
        prefix .. "S",
        function() gitsigns.stage_buffer() end,
        { buf = bufnr, desc = "Stage Git buffer" }
      )
      vim.keymap.set("n", prefix .. "d", function() gitsigns.diffthis() end, { buf = bufnr, desc = "View Git diff" })

      -- Visual Mode Mappings (Range specific)
      vim.keymap.set(
        "v",
        prefix .. "r",
        function() gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        { buf = bufnr, desc = "Reset Git hunk" }
      )

      vim.keymap.set(
        "v",
        prefix .. "s",
        function() gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        { buf = bufnr, desc = "Stage Git hunk" }
      )

      -- Navigation Mappings
      vim.keymap.set("n", "[G", function() gitsigns.nav_hunk "first" end, { buf = bufnr, desc = "First Git hunk" })
      vim.keymap.set("n", "]G", function() gitsigns.nav_hunk "last" end, { buf = bufnr, desc = "Last Git hunk" })
      vim.keymap.set("n", "]g", function() gitsigns.nav_hunk "next" end, { buf = bufnr, desc = "Next Git hunk" })
      vim.keymap.set("n", "[g", function() gitsigns.nav_hunk "prev" end, { buf = bufnr, desc = "Previous Git hunk" })

      vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { buf = bufnr, desc = "inside Git hunk" })
    end,
    worktrees = nil,
  }
  gitsigns.setup(opts)
end)
