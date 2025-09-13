---@type LazySpec
return {
  "LudoPinelli/comment-box.nvim",
  optional = true,
  event = "User AstroFile",
  opts = {},
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>B"] = { desc = "󱋄" .. " Comment box/line" }
        maps.n["<Leader>Bc"] = { "<CMD>CBcatalog<CR>", desc = "List Catalog" }
        maps.n["<Leader>Bbl"] = { "<CMD>CBllbox<CR>", desc = "Comment Box (Left)" }
        maps.n["<Leader>Bbc"] = { "<CMD>CBlcbox<CR>", desc = "Comment Box (Center)" }
        maps.n["<Leader>Bbr"] = { "<CMD>CBlrbox<CR>", desc = "Comment Box (Right)" }
        maps.n["<Leader>Bll"] = { "<CMD>CBllline<CR>", desc = "Comment Line (Left)" }
        maps.n["<Leader>Blc"] = { "<CMD>CBlcline<CR>", desc = "Comment Line (Center)" }
        maps.n["<Leader>Blr"] = { "<CMD>CBlrline<CR>", desc = "Comment Line (Right)" }
      end,
    },
  },
}
