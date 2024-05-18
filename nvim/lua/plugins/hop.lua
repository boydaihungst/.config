return {
  {
    "smoka7/hop.nvim",
    opts = {},
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["f"] = { function() require("hop").hint_words {} end, desc = "Hop hint words" },
            ["<S-f>"] = { function() require("hop").hint_lines {} end, desc = "Hop hint lines" },
          },
          v = {
            ["f"] = { function() require("hop").hint_words { extend_visual = true } end, desc = "Hop hint words" },
            ["<S-f>"] = {
              function() require("hop").hint_lines { extend_visual = true } end,
              desc = "Hop hint lines",
            },
          },
        },
      },
    },
  },
}
