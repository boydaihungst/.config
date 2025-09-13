-- Set up custom filetypes
vim.filetype.add {
  extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
  filename = {
    ["vifmrc"] = "vim",
  },
  pattern = {
    [".*/waybar/config.*"] = "jsonc",
    [".*/mako/config"] = "dosini",
    [".*/dunst/dunstrc"] = "dosini",
    [".*/kitty/.+%.conf"] = "kitty",
    -- [".*/hypr/.+%.conf"] = "hyprlang",
    [".*/sway/.+%.conf"] = "swayconfig",
    ["%.env%.[%w_.-]+"] = "sh",
  },
}
