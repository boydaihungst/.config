---@type LazySpec
return {
  "lambdalisue/suda.vim",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>W"] = { "<Cmd>SudaWrite<CR>", desc = "Suda Write" },
          },
        },
      },
    },
  },
  cmd = { "SudaRead", "SudaWrite" },
}
