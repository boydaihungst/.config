---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  optional = true,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        local astro = require "astrocore"
        maps.t["<F8>"] = { "<C-\\><C-n>", desc = "Toggle visual mode" } -- requires terminal that supports binding <C-'>

        if vim.fn.executable "lazydocker" == 1 then
          maps.n["<Leader>td"] = {
            function() astro.toggle_term_cmd { cmd = "lazydocker", direction = "float" } end,
            desc = "ToggleTerm lazydocker",
          }
        end
      end,
    },
  },
}
