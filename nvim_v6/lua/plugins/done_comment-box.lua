---@type LazySpec
return {
  "LudoPinelli/comment-box.nvim",
  event = "User AstroFile",
  opts = {},
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>B"] = { desc = "󱋄" .. " Comment box/line" },
            ["<Leader>Bb"] = { desc = "Comment Box" },
            ["<Leader>Bl"] = { desc = "Comment Line" },
            ["<Leader>Bc"] = { "<CMD>CBcatalog<CR>", desc = "List Catalog" },
            ["<Leader>Bbl"] = { "<CMD>CBllbox<CR>", desc = "Comment Box (Left)" },
            ["<Leader>Bbc"] = { "<CMD>CBlcbox<CR>", desc = "Comment Box (Center)" },
            ["<Leader>Bbr"] = { "<CMD>CBlrbox<CR>", desc = "Comment Box (Right)" },
            ["<Leader>Bll"] = { "<CMD>CBllline<CR>", desc = "Comment Line (Left)" },
            ["<Leader>Blc"] = { "<CMD>CBlcline<CR>", desc = "Comment Line (Center)" },
            ["<Leader>Blr"] = { "<CMD>CBlrline<CR>", desc = "Comment Line (Right)" },
          },
        },
      },
    },
  },
}
