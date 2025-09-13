---@type LazySpec
return {
  "kevinhwang91/nvim-hlslens",
  optional = true,
  opts = {
    override_lens = function(render, posList, nearest, idx, relIdx)
      local text, chunks

      local lnum, col = unpack(posList[idx])
      if nearest then
        local cnt = #posList
        text = ("[%d/%d]"):format(idx or 0, cnt or 0)
        chunks = { { " " }, { text, "NvimSurroundHighlight" } }
      else
        text = ("[%d]"):format(idx or 0)
        chunks = { { " " }, { text, "HlSearchLens" } }
      end
      render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
    end,
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
        -- Lua helper for vim-visual-multi "find under" with count support
        local maps = assert(opts.mappings)
        maps.n["n"] = {
          "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>",
          desc = "Open history",
          silent = true,
        }
        maps.n["N"] = {
          "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>",
          desc = "Browse summaries",
          silent = true,
        }
        maps.n["*"] = {
          "*<Cmd>lua require('hlslens').start()<CR>",
          desc = "Browse summaries",
          silent = true,
        }
        maps.n["#"] = {
          "#<Cmd>lua require('hlslens').start()<CR>",
          desc = "Browse summaries",
          silent = true,
        }
        maps.n["g*"] = {
          "#<Cmd>lua require('hlslens').start()<CR>",
          desc = "Browse summaries",
          silent = true,
        }
        maps.n["g#"] = {
          "#<Cmd>lua require('hlslens').start()<CR>",
          desc = "Browse summaries",
          silent = true,
        }
      end,
    },
  },
}
