later(function()
  vim.g["suda#prompt"] = "Enter sudo password to save:"
  add {
    "https://github.com/lambdalisue/vim-suda",
  }

  local function smart_save()
    if vim.bo.buftype ~= "" then return end

    local success, err = pcall(function() vim.cmd "update" end)

    if not success then
      if err:match "E212" or err:match "permission denied" then
        if vim.fn.exists ":SudaWrite" > 0 then
          vim.cmd "SudaWrite"
        else
          vim.notify("Save failed and vim-suda is unavailable: " .. err, vim.log.levels.ERROR)
        end
      else
        vim.notify("Save failed: " .. err, vim.log.levels.ERROR)
      end
    end
  end
  vim.keymap.set({ "n" }, "<C-S>", smart_save, { desc = "Smart Save (Sudo if needed)" })
end)
