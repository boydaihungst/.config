later(function()
  add {
    "https://github.com/pwntester/octo.nvim",
  }
  local opts = {
    use_local_fs = false, -- use local files on right side of reviews
    enable_builtin = true, -- shows a list of builtin actions when no action is provided
    ssh_aliases = {},
    github_hostname = "", -- GitHub Enterprise host
    gh_cmd = "gh", -- Command to use when calling Github CLI
    gh_env = {}, -- extra environment variables to pass on to GitHub CLI, can be a table or function returning a table
    default_to_projects_v2 = false, -- use projects v2 for the `Octo card ...` command by default. Both legacy and v2 commands are available under `Octo cardlegacy ...` and `Octo cardv2 ...` respectively.
    use_diagnostic_signs = true,
    mappings = {},
    picker = (vim.pack.is_available "telescope" and "telescope")
      or (vim.pack.is_available "fzf-lua" and "fzf-lua")
      or (vim.pack.is_available "snacks" and "snacks")
      or "default",
  }

  if vim.fn.executable(opts.gh_cmd) == 0 then return end
  require("octo").setup(opts)
  local prefix = "<Leader>O"

  -- Assignee/Reviewer
  vim.keymap.set("n", prefix .. "aa", "<Cmd>Octo assignee add<CR>", { desc = "Assign a user" })
  vim.keymap.set("n", prefix .. "ap", "<Cmd>Octo reviewer add<CR>", { desc = "Assign a PR reviewer" })
  vim.keymap.set("n", prefix .. "ar", "<Cmd>Octo assignee remove<CR>", { desc = "Remove a user" })

  -- Comments
  vim.keymap.set("n", prefix .. "ca", "<Cmd>Octo comment add<CR>", { desc = "Add a new comment" })
  vim.keymap.set("n", prefix .. "cd", "<Cmd>Octo comment delete<CR>", { desc = "Delete a comment" })

  -- Reaction
  vim.keymap.set("n", prefix .. "e1", "<Cmd>Octo reaction thumbs_up<CR>", { desc = "Add 👍 reaction" })
  vim.keymap.set("n", prefix .. "e2", "<Cmd>Octo reaction thumbs_down<CR>", { desc = "Add 👎 reaction" })
  vim.keymap.set("n", prefix .. "e3", "<Cmd>Octo reaction eyes<CR>", { desc = "Add 👀 reaction" })
  vim.keymap.set("n", prefix .. "e4", "<Cmd>Octo reaction laugh<CR>", { desc = "Add 😄 reaction" })
  vim.keymap.set("n", prefix .. "e5", "<Cmd>Octo reaction confused<CR>", { desc = "Add 😕 reaction" })
  vim.keymap.set("n", prefix .. "e6", "<Cmd>Octo reaction rocket<CR>", { desc = "Add 🚀 reaction" })
  vim.keymap.set("n", prefix .. "e7", "<Cmd>Octo reaction heart<CR>", { desc = "Add ❤️ reaction" })
  vim.keymap.set("n", prefix .. "e8", "<Cmd>Octo reaction party<CR>", { desc = "Add 🎉 reaction" })

  -- sues
  vim.keymap.set("n", prefix .. "ic", "<Cmd>Octo issue close<CR>", { desc = "Close current issue" })
  vim.keymap.set("n", prefix .. "il", "<Cmd>Octo issue list<CR>", { desc = "List open issues" })
  vim.keymap.set("n", prefix .. "io", "<Cmd>Octo issue browser<CR>", { desc = "Open current issue in browser" })
  vim.keymap.set("n", prefix .. "ir", "<Cmd>Octo issue reopen<CR>", { desc = "Reopen current issue" })
  vim.keymap.set("n", prefix .. "iu", "<Cmd>Octo issue url<CR>", { desc = "Copies URL of current issue" })

  -- Label
  vim.keymap.set("n", prefix .. "la", "<Cmd>Octo label add<CR>", { desc = "Assign a label" })
  vim.keymap.set("n", prefix .. "lc", "<Cmd>Octo label create<CR>", { desc = "Create a label" })
  vim.keymap.set("n", prefix .. "lr", "<Cmd>Octo label remove<CR>", { desc = "Remove a label" })

  -- Pull requests
  vim.keymap.set("n", prefix .. "pc", "<Cmd>Octo pr close<CR>", { desc = "Close current PR" })
  vim.keymap.set("n", prefix .. "pd", "<Cmd>Octo pr diff<CR>", { desc = "Show PR diff" })
  vim.keymap.set("n", prefix .. "pl", "<Cmd>Octo pr changes<CR>", { desc = "List changed files in PR" })
  vim.keymap.set("n", prefix .. "pmd", "<Cmd>Octo pr merge delete<CR>", { desc = "Delete merge PR" })
  vim.keymap.set("n", prefix .. "pmm", "<Cmd>Octo pr merge commit<CR>", { desc = "Merge commit PR" })
  vim.keymap.set("n", prefix .. "pmr", "<Cmd>Octo pr merge rebase<CR>", { desc = "Rebase merge PR" })
  vim.keymap.set("n", prefix .. "pms", "<Cmd>Octo pr merge squash<CR>", { desc = "Squash merge PR" })
  vim.keymap.set("n", prefix .. "pn", "<Cmd>Octo pr create<CR>", { desc = "Create PR for current branch" })
  vim.keymap.set("n", prefix .. "po", "<Cmd>Octo pr browser<CR>", { desc = "Open current PR in browser" })
  vim.keymap.set("n", prefix .. "pp", "<Cmd>Octo pr checkout<CR>", { desc = "Checkout PR" })
  vim.keymap.set("n", prefix .. "pr", "<Cmd>Octo pr ready<CR>", { desc = "Mark draft as ready for review" })
  vim.keymap.set("n", prefix .. "ps", "<Cmd>Octo pr list<CR>", { desc = "List open PRs" })
  vim.keymap.set("n", prefix .. "pt", "<Cmd>Octo pr commits<CR>", { desc = "List PR commits" })
  vim.keymap.set("n", prefix .. "pu", "<Cmd>Octo pr url<CR>", { desc = "Copies URL of current PR" })

  -- Repo
  vim.keymap.set("n", prefix .. "rf", "<Cmd>Octo repo fork<CR>", { desc = "Fork repo" })
  vim.keymap.set("n", prefix .. "rl", "<Cmd>Octo repo list<CR>", { desc = "List repo user stats" })
  vim.keymap.set("n", prefix .. "ro", "<Cmd>Octo repo open<CR>", { desc = "Open current repo in browser" })
  vim.keymap.set("n", prefix .. "ru", "<Cmd>Octo repo url<CR>", { desc = "Copies URL of current repo" })

  -- Review
  vim.keymap.set("n", prefix .. "sc", "<Cmd>Octo review comments<CR>", { desc = "View pending comments" })
  vim.keymap.set("n", prefix .. "sd", "<Cmd>Octo review dcard<CR>", { desc = "Delete pending review" })
  vim.keymap.set("n", prefix .. "sf", "<Cmd>Octo review submit<CR>", { desc = "Submit review" })
  vim.keymap.set("n", prefix .. "sp", "<Cmd>Octo review commit<CR>", { desc = "Select commit to review" })
  vim.keymap.set("n", prefix .. "sr", "<Cmd>Octo review resume<CR>", { desc = "Resume review" })
  vim.keymap.set("n", prefix .. "ss", "<Cmd>Octo review start<CR>", { desc = "Start review" })

  -- Threads
  vim.keymap.set("n", prefix .. "ta", "<Cmd>Octo thread resolve<CR>", { desc = "Mark thread as resolved" })
  vim.keymap.set("n", prefix .. "td", "<Cmd>Octo thread unresolve<CR>", { desc = "Mark thread as unresolved" })

  -- Misc
  vim.keymap.set("n", prefix .. "x", "<Cmd>Octo actions<CR>", { desc = "Run an action" })

  --- Which-key Group
  if wk then
    wk.add {
      { prefix, group = Config.get_custom_icon("Octo", 1, true) .. "Octo" },
      { prefix .. "a", group = "Assignee/Reviewer" },
      { prefix .. "c", group = "Comments" },
      { prefix .. "e", group = "Reaction" },
      { prefix .. "i", group = "Issues" },
      { prefix .. "l", group = "Label" },
      { prefix .. "p", group = "Pull requests" },
      { prefix .. "pm", group = "Merge current PR" },
      { prefix .. "r", group = "Repo" },
      { prefix .. "s", group = "Review" },
      { prefix .. "t", group = "Threads" },
    }
  end
end)
