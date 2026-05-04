-- See https://wiki.hyprland.org/Configuring/Monitors/
hl.monitor({
  output = "eDP-1",
  mode = "2560x1600@240",
  scale = 1.25,
  position = "auto-right",
  bitdepth = 8,
  vrr = 1,
  icc = "/home/huyhoang/.config/sway/scripts/color_profiles/TPLCD_2039_Default.icm",
})

hl.monitor({
  output = "DP-1",
  mode = "2560x1440@240",
  scale = 1,
  position = "0x0",
  bitdepth = 8,
  vrr = 1,
  icc = "/home/huyhoang/.config/sway/scripts/color_profiles/Q27G42ZE.icm",
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "640x480@59.94Hz",
  position = "0x4920",
})

-- unscale XWayland
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})
