later(function()
  add { "https://github.com/akinsho/toggleterm.nvim" }
  require("toggleterm").setup {
    float_opts = {
      border = vim.o.winborder,
    },
    highlights = {
      Normal = { link = "Normal" },
      NormalNC = { link = "NormalNC" },
      NormalFloat = { link = "NormalFloat" },
      FloatBorder = { link = "FloatBorder" },
      StatusLine = { link = "StatusLine" },
      StatusLineNC = { link = "StatusLineNC" },
      WinBar = { link = "WinBar" },
      WinBarNC = { link = "WinBarNC" },
    },
    size = function(term)
      if term.direction == "horizontal" then
        return 10
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.3
      end
    end,
    ---@param t Terminal
    on_create = function(t)
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.signcolumn = "no"
      if t.hidden then
        local function toggle() t:toggle() end
        vim.keymap.set({ "n", "t", "i" }, "<C-'>", toggle, { desc = "Toggle terminal", buf = t.bufnr })
        vim.keymap.set({ "n", "t", "i" }, "<F7>", toggle, { desc = "Toggle terminal", buf = t.bufnr })
      end
      vim.keymap.set({ "n", "t", "i" }, "<C-q>", "<cmd>close<CR>", { desc = "Close terminal", buf = t.bufnr })

      vim.keymap.set({ "n", "t", "i" }, "<C-n>", function()
        vim.cmd "TermNew" -- or your custom toggle logic
      end, { desc = "Split terminal window", buf = t.bufnr })
    end,
    shading_factor = 2,
  }

  --- A table to manage ToggleTerm terminals created by the user, indexed by the command run and then the instance number
  ---@type table<string,table<integer,table>>
  local user_terminals = {}

  --- Toggle a user terminal if it exists, if not then create a new one and save it
  ---@param opts string|table A terminal command string or a table of options for Terminal:new() (Check toggleterm.nvim documentation for table format)
  _G.toggleterm = {}
  _G.toggleterm.toggle_term_cmd = function(opts)
    local terms = user_terminals
    -- if a command string  provided, create a basic table for Terminal:new() options
    if type(opts) == "string" then opts = { cmd = opts } end
    opts = vim.tbl_deep_extend("force", { hidden = true }, opts)
    local num = vim.v.count > 0 and vim.v.count or 1
    -- if terminal doesn't exist yet, create it
    if not terms[opts.cmd] then terms[opts.cmd] = {} end
    if not terms[opts.cmd][num] then
      if not opts.count then opts.count = vim.tbl_count(terms) * 100 + num end
      local on_exit = opts.on_exit
      opts.on_exit = function(...)
        terms[opts.cmd][num] = nil
        if on_exit then on_exit(...) end
      end
      terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
    end
    -- toggle the terminal
    terms[opts.cmd][num]:toggle()
  end

  local prefix = "<leader>t"
  if vim.fn.executable "git" == 1 and vim.fn.executable "lazygit" == 1 then
    local lazygit = {
      callback = function()
        local git_data = MiniGit and MiniGit.get_buf_data()
        local root = ""
        local git_dir = ""
        if git_data then
          root = git_data.root or ""
          git_dir = git_data.repo or ""
        end
        local flags = root ~= "" and (" --work-tree=%s --git-dir=%s"):format(root, git_dir) or ""
        _G.toggleterm.toggle_term_cmd { cmd = "lazygit " .. flags, direction = "float" }
      end,
      desc = "ToggleTerm lazygit",
    }
    vim.keymap.set({ "n" }, "<Leader>gg", lazygit.callback, { desc = lazygit.desc })
    vim.keymap.set({ "n" }, prefix .. "l", lazygit.callback, { desc = lazygit.desc })
  end

  if vim.fn.executable "lazydocker" == 1 then
    vim.keymap.set(
      { "n" },
      prefix .. "d",
      function() _G.toggleterm.toggle_term_cmd { cmd = "lazydocker", direction = "float" } end,
      { desc = "ToggleTerm lazydocker" }
    )
  end

  if vim.fn.executable "node" == 1 then
    vim.keymap.set(
      { "n" },
      prefix .. "n",
      function() _G.toggleterm.toggle_term_cmd "node" end,
      { desc = "ToggleTerm node" }
    )
  end

  local python = vim.fn.executable "python" == 1 and "python" or vim.fn.executable "python3" == 1 and "python3"
  if python then
    vim.keymap.set(
      { "n" },
      prefix .. "p",
      function() _G.toggleterm.toggle_term_cmd(python) end,
      { desc = "ToggleTerm python" }
    )
  end

  -- ToggleTerm Layouts
  vim.keymap.set("n", prefix .. "f", "<Cmd>ToggleTerm direction=float<CR>", { desc = "ToggleTerm float" })
  vim.keymap.set(
    "n",
    prefix .. "h",
    "<Cmd>ToggleTerm direction=horizontal<CR>",
    { desc = "ToggleTerm horizontal split" }
  )
  vim.keymap.set("n", prefix .. "v", "<Cmd>ToggleTerm direction=vertical<CR>", { desc = "ToggleTerm vertical split" })

  -- F7 Toggle (Normal, Terminal, Insert)
  vim.keymap.set("n", "<F7>", '<Cmd>execute v:count . "ToggleTerm"<CR>', { desc = "Toggle terminal" })
  vim.keymap.set("t", "<F7>", "<Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
  vim.keymap.set("i", "<F7>", "<Esc><Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

  -- Ctrl + ' Toggle (Normal, Terminal, Insert)
  -- Note: Terminal emulator support for <C-'> varies
  vim.keymap.set("n", "<C-'>", '<Cmd>execute v:count . "ToggleTerm"<CR>', { desc = "Toggle terminal" })
  vim.keymap.set("t", "<C-'>", "<Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
  vim.keymap.set("i", "<C-'>", "<Esc><Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

  -- F8 toggle visual mode in terminal buffer
  vim.keymap.set("t", "<F8>", "<C-\\><C-n>", { desc = "Toggle visual mode" })
  vim.keymap.set("n", "<F8>", "i", { desc = "Exit terminal visual mode" })

  -- F19  = Shift + F7 (Shift == 12 -> F12 + F7)
  vim.keymap.set("n", "<F19>", "<Cmd>TermNew<CR>", { desc = "Split terminal window" })

  if wk then wk.add {
    { prefix, group = Config.get_custom_icon("Terminal", 1, true) .. "Terminal" },
  } end

  -- MiniFiles mappings
  if MiniFiles then
    local function toggleterm_in_direction(fs_entry, direction)
      local path = fs_entry.fs_type == "file" and vim.fs.dirname(fs_entry.path) or fs_entry.path
      local term = require("toggleterm.terminal").Terminal:new { dir = path, direction = direction }
      term:open()
      term:focus()
      -- Auto type cursor file name to terminal
      if fs_entry.fs_type == "file" then
        vim.api.nvim_feedkeys(fs_entry.name, "t", true)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Home>", true, false, true), "t", true)
      end
    end

    Config.new_autocmd("User", "MiniFilesBufferCreate", function(args)
      local buf_id = args.data.buf_id
      for suffix, direction in pairs { f = "float", h = "horizontal", v = "vertical" } do
        vim.keymap.set("n", prefix .. suffix, function()
          local cur_fs_entry = MiniFiles.get_fs_entry(buf_id)
          if cur_fs_entry == nil then return vim.notify "Cursor not on valid entry" end
          MiniFiles.close()
          toggleterm_in_direction(cur_fs_entry, direction)
        end, { buf = buf_id, desc = "Open terminal (" .. direction .. ")" })
      end
    end, "Toggle terminal in MiniFiles buffer")
  end
end)
