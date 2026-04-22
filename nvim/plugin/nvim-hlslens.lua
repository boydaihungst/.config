later(function()
  add { "https://github.com/kevinhwang91/nvim-hlslens" }

  local hlslens = require "hlslens"
  hlslens.setup {
    -- NOTE: disable this because it makes mini.files incremental search error
    enable_incsearch = false,
    override_lens = function(render, posList, nearest, idx, _)
      local text, chunks

      local lnum, col = unpack(posList[idx])
      if nearest then
        local cnt = #posList
        text = ("[%d/%d]"):format(idx or 0, cnt or 0)
        chunks = { { " " }, { text, "HlSearchLensNear" } }
      else
        text = ("[%d]"):format(idx or 0)
        chunks = { { " " }, { text, "HlSearchLens" } }
      end
      if idx >= 0 then render.setVirt(0, lnum - 1, col - 1, chunks, nearest) end
    end,
  }

  vim.api.nvim_set_hl(0, "HlSearchLens", { link = "CurSearch" })
  vim.api.nvim_set_hl(0, "HlSearchLensNear", { link = "Search" })

  local function n_with_hlslens(char)
    local count = vim.v.count1
    local ok, _ = pcall(function() vim.cmd(("normal! %d%s"):format(count, char)) end)
    if ok then hlslens.start() end
  end

  -- n and N
  vim.keymap.set("n", "n", function() n_with_hlslens "n" end, { silent = true, desc = "Next search result" })
  vim.keymap.set("n", "N", function() n_with_hlslens "N" end, { silent = true, desc = "Prev search result" })

  -- * and # (Directly trigger the command then start hlslens)
  vim.keymap.set("n", "*", '*<Cmd>lua require("hlslens").start()<CR>', { silent = true, desc = "Search word forward" })
  vim.keymap.set("n", "#", '#<Cmd>lua require("hlslens").start()<CR>', { silent = true, desc = "Search word backward" })

  -- g* and g#
  vim.keymap.set(
    "n",
    "g*",
    'g*<Cmd>lua require("hlslens").start()<CR>',
    { silent = true, desc = "Search word forward (partial)" }
  )
  vim.keymap.set(
    "n",
    "g#",
    'g#<Cmd>lua require("hlslens").start()<CR>',
    { silent = true, desc = "Search word backward (partial)" }
  )
end)
