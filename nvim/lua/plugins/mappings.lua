---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- second key is the lefthand side of the map
          -- navigate buffer tabs with `H` and `L`
          L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

          ["<Leader>fl"] = { "<CMD>Telescope filetypes<CR>", desc = "Change file language (type)" },
          -- toggle highlighting
          ["<Leader>h"] = {
            "<cmd>nohlsearch<CR>",
            desc = "No Highlight",
          },
          -- Alpha dashboard
          ["<F2>"] = {
            function()
              local wins = vim.api.nvim_tabpage_list_wins(0)
              if #wins > 1 and vim.bo[vim.api.nvim_win_get_buf(wins[1])].filetype == "neo-tree" then
                vim.fn.win_gotoid(wins[2]) -- go to non-neo-tree window to toggle alpha
              end
              require("alpha").start(false)
            end,
            desc = "Home Screen",
          },
          ["<C-Q>"] = {
            function()
              local qf_exists = false
              for _, win in pairs(vim.fn.getwininfo()) do
                if win["quickfix"] == 1 then qf_exists = true end
              end
              if qf_exists == true then
                vim.cmd "cclose"
                return
              end
              if not vim.tbl_isempty(vim.fn.getqflist()) then vim.cmd "copen" end
            end,
            desc = "Toggle Quickfix",
          },
          -- tables with just a `desc` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          ["<Leader>fd"] = { desc = "Find Dev Docs" },
        },
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {
          -- this mapping will only be set in buffers with an LSP attached
          K = {
            function() vim.lsp.buf.hover() end,
            desc = "Hover symbol details",
          },
          -- condition for only server with declaration capabilities
          gD = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration of current symbol",
            cond = "textDocument/declaration",
          },
        },
      },
    },
  },
}
