---@type LazySpec
return {

  "pwntester/octo.nvim",
  optional = true,
  opts = {
    use_local_fs = false, -- use local files on right side of reviews
    enable_builtin = true, -- shows a list of builtin actions when no action is provided
    ssh_aliases = {},
    github_hostname = "", -- GitHub Enterprise host
    gh_cmd = "gh", -- Command to use when calling Github CLI
    gh_env = {}, -- extra environment variables to pass on to GitHub CLI, can be a table or function returning a table
    default_to_projects_v2 = false, -- use projects v2 for the `Octo card ...` command by default. Both legacy and v2 commands are available under `Octo cardlegacy ...` and `Octo cardv2 ...` respectively.
  },
}
