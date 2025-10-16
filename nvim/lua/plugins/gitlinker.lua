local function to_litteral(str) return str and str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") end

---@type LazySpec
return {
  "linrongbin16/gitlinker.nvim",
  optionals = true,
  opts = {
    router = {
      browse = {
        -- https://git.linuxholic.com/boydaihungst/AnimeSubtitles/src/commit/250145403bde3858562337528233b0707fdf6e86/typesetting_fonts.txt#L4-L10
        [to_litteral "ssh.linuxholic.com"] = "https://git.linuxholic.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/src/commit/"
          .. "{_A.REV}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}-L{_A.LEND}",
      },
      blame = {
        -- https://git.linuxholic.com/boydaihungst/AnimeSubtitles/blame/commit/250145403bde3858562337528233b0707fdf6e86/typesetting_fonts.txt#L4-L10
        [to_litteral "ssh.linuxholic.com"] = "https://git.linuxholic.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blame/commit/"
          .. "{_A.REV}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}-L{_A.LEND}",
      },
    },
  },
}
