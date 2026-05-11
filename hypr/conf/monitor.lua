-- See https://wiki.hyprland.org/Configuring/Monitors/
hl.monitor({
  output = "DP-2",
  mode = "2560x1440@240",
  scale = 1,
  position = "2560x0",
  bitdepth = 8,
  cm = "auto",
  vrr = 1,
  icc = "/home/huyhoang/.config/sway/scripts/color_profiles/Q27G42ZE.icm",
})

hl.monitor({
  output = "DP-1",
  mode = "2560x1440@280",
  scale = 1,
  position = "0x0",
  bitdepth = 10,
  cm = "auto",
  vrr = 1,
  sdr_min_luminance = 0.005,
  sdr_max_luminance = 250,
  -- min_luminance = 0.005,
  -- max_luminance = 1000,
  -- max_avg_luminance = 450,
  sdrsaturation = 1.15,
  -- icc = "/home/huyhoang/.config/sway/scripts/color_profiles/Q27G4ZD.icm",
})

hl.monitor({
  output = "eDP-1",
  mode = "2560x1600@240",
  scale = 1.33,
  position = "5120x0",
  bitdepth = 8,
  vrr = 1,
  icc = "/home/huyhoang/.config/sway/scripts/color_profiles/TPLCD_2039_Default.icm",
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "preferred",
  position = "5120x1440",
  scale = 1,
  bitdepth = 8,
  vrr = 0,
})

-- unscale XWayland
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})
