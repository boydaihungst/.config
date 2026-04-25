local M = {}

-- file names to execute in project root
M.config_files = { ".nvim.lua" }
-- Auto trust project-local files in config_files above on save
M.auto_trust_on_save = true
-- Store the cleanup function from the last loaded project
M._current_cleanup = nil

--- Core loading logic
function M.load_current_project_config()
  local cwd = vim.uv.cwd()

  for _, filename in ipairs(M.config_files) do
    local path = cwd .. "/" .. filename
    local stat = vim.uv.fs_stat(path)

    if stat and stat.type == "file" then
      if vim.secure.read(path) then
        -- Using dofile to ensure it reloads if we CD back and forth
        local success, result = pcall(dofile, path)
        if success then
          M._current_cleanup = result
          vim.notify("Project config loaded: " .. path, vim.log.levels.INFO)
        else
          vim.notify("Error in " .. path .. ": " .. result, vim.log.levels.ERROR)
        end
        -- Break after finding the first valid config file
        return
      else
        vim.notify("Error in " .. filename .. ": need to be trusted", vim.log.levels.ERROR)
      end
    end
  end
end

function M.unload_prev_project_config()
  if type(M._current_cleanup) == "function" then M._current_cleanup() end
end

function M.setup()
  -- 1. Create the user command for manual "on-demand" triggers
  vim.api.nvim_create_user_command("ProjectLoad", function() M.load_current_project_config() end, {})

  -- 2. The magic bit: Trigger whenever the directory changes
  vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("ProjectLoaderAuto", { clear = true }),
    pattern = "global", -- Tracks :cd calls
    callback = function()
      M.unload_prev_project_config()
      M.load_current_project_config()
    end,
  })

  if M.auto_trust_on_save then
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*",
      callback = function()
        local cur_file = vim.fn.expand "%:t"
        if vim.tbl_contains(M.config_files or {}, cur_file) then
          vim.notify("Auto trust project-local file: " .. cur_file)
          vim.cmd "silent! trust"
        end
      end,
    })
  end
  -- 3. Optional: Run once on startup if you want to mimic exrc behavior
  -- M.load_current_project_config()
end

M.setup()

return M
