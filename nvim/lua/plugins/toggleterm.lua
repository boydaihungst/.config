---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  optional = true,
  cmd = { "ToggleTerm", "TermExec", "TermNew", "TermSelect", "ToggleTermSetName" },
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
        maps.n["<F19>"] = {
          "<Cmd>TermNew<CR>",
          desc = "Split terminal window",
        }
      end,
    },
  },
  opts = {
    ---@param t Terminal
    on_create = function(t)
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.signcolumn = "no"
      if t.hidden then
        local function toggle() t:toggle() end
        vim.keymap.set({ "n", "t", "i" }, "<C-'>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
        vim.keymap.set({ "n", "t", "i" }, "<F7>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
      end

      vim.keymap.set({ "n", "t", "i" }, "<C-q>", "<cmd>close<CR>", { desc = "Close terminal", buffer = t.bufnr })

      vim.keymap.set({ "n", "t", "i" }, "<C-n>", function()
        vim.cmd "TermNew" -- or your custom toggle logic
      end, { desc = "Split terminal window", buffer = t.bufnr })

      vim.keymap.set({ "n", "t", "i" }, "<C-n>", function()
        vim.cmd "TermNew" -- or your custom toggle logic
      end, { desc = "Split terminal window", buffer = t.bufnr })
    end,
  },
}
