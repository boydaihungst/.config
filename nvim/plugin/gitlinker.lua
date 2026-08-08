later(function()
  add { "https://github.com/linrongbin16/gitlinker.nvim" }
  local function to_litteral(str) return str and str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") end
  require("gitlinker").setup {
    router = {
      browse = {
        -- My gitea server
        -- https://git.linuxholic.com/boydaihungst/AnimeSubtitles/src/commit/250145403bde3858562337528233b0707fdf6e86/typesetting_fonts.txt#L4-L10
        [to_litteral "ssh.linuxholic.com"] = "https://git.linuxholic.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/src/commit/"
          .. "{_A.REV}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}-L{_A.LEND}",
      },
      blame = {
        -- My gitea server
        -- https://git.linuxholic.com/boydaihungst/AnimeSubtitles/blame/commit/250145403bde3858562337528233b0707fdf6e86/typesetting_fonts.txt#L4-L10
        [to_litteral "ssh.linuxholic.com"] = "https://git.linuxholic.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blame/commit/"
          .. "{_A.REV}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}-L{_A.LEND}",
      },
    },
  }
  local prefix = "<leader>g"

  vim.keymap.set({ "n", "x" }, prefix .. "y", "<cmd>GitLink<cr>", { desc = "Copy Git link" })
  vim.keymap.set({ "n", "x" }, prefix .. "z", "<cmd>GitLink!<cr>", { desc = "Open Git link" })
end)
