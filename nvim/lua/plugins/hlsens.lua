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
        chunks = { { " " }, { text, "StatusVisual" } }
      else
        text = ("[%d]"):format(idx or 0)
        chunks = { { " " }, { text, "HlSearchLens" } }
      end
      render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
    end,
  },
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        on_keys = { auto_hlsearch = false },
        mappings = {
          n = {
            ["n"] = {
              "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>",
              desc = "Open history",
              silent = true,
            },
            ["N"] = {
              "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>",
              desc = "Browse summaries",
              silent = true,
            },
            ["*"] = {
              "*<Cmd>lua require('hlslens').start()<CR>",
              desc = "Browse summaries",
              silent = true,
            },
            ["#"] = {
              "#<Cmd>lua require('hlslens').start()<CR>",
              desc = "Browse summaries",
              silent = true,
            },
            ["g*"] = {
              "#<Cmd>lua require('hlslens').start()<CR>",
              desc = "Browse summaries",
              silent = true,
            },
            ["g#"] = {
              "#<Cmd>lua require('hlslens').start()<CR>",
              desc = "Browse summaries",
              silent = true,
            },
          },
        },
      },
    },
  },
}
