-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

local window_rules = {
  -- Enable tearing for certain gamess, apps
  {
    match = { class = "(cs2)" },
    immediate = true,
  },
  -- single app don't show border
  {
    match = {
      float = false,
      workspace = "w[tv1]",
    },
    border_color = "rgba(595959aa)",
    border_size = 0,
  },
  -- fullscreen app won't show border
  {
    border_color = "rgba(595959aa)",
    match = {
      float = 0,
      workspace = "f[1]",
    },
  },

  -- Keep window size persistent
  {
    persistent_size = true,
    match = {
      float = 1,
    },
  },

  -- fix ibus
  {
    no_focus = true,
    match = {
      class = "^(Ibus-ui-gtk2)$",
    },
  },
  {
    no_focus = true,
    match = {
      class = "^(Ibus-ui-gtk3)$",
    },
  },
  {
    no_focus = true,
    match = {
      class = "^(Ibus-ui-gtk5)$",
    },
  },
  {
    no_focus = true,
    match = {
      class = "^(Ibus-ui-gtk4)$",
    },
  },

  -- Assign applications to workspaces (updated syntax)
  {
    workspace = "1",
    match = {
      class = "^(btop|htop|kitty|lvim|vim|nvim|org.wezfurlong.wezterm|com.mitchellh.ghostty)$",
    },
  },
  {
    workspace = "2",
    match = {
      class = "^(?i)(waterfox-default|waterfox|firefox|firefox-default|vivaldi|vivaldi-stable)$",
    },
  },
  {
    workspace = "3",
    match = {
      class = "^(thunar|ranger|lfcd|lf|vifm|yazi)$",
    },
  },
  {
    workspace = "4",
    match = {
      class = "^thunderbird$",
    },
  },
  {
    workspace = "5",
    match = {
      class = "^(org.telegram.desktop|pidgin|discord|blender|gimp|org.inkscape.Inkscape)$",
    },
  },
  {
    workspace = "6",
    match = {
      class = "^(calibre-ebook-viewer|calibre)$",
    },
  },
  {
    workspace = "7",
    match = {
      class = "^(bottles|steam|lutris)$",
    },
  },

  -- Floating windows
  {
    tile = true,
    match = {
      class = "^yazi$",
    },
  },
  {
    float = true,
    size = "(monitor_w*0.8) (monitor_h*0.9)",
    match = {
      class = "^yazi-selector$",
    },
  },
  {
    float = true,
    match = {
      class = "^yad$",
    },
  },
  {
    float = true,
    size = "(monitor_w*0.3) (monitor_h*0.4)",
    match = {
      class = "^(galculator|org.speedcrunch.speedcrunch)$",
    },
  },
  {
    float = true,
    max_size = "(monitor_w*0.4) (monitor_h*0.3)",
    match = {
      class = "^blueman-manager$",
    },
  },
  {
    float = true,
    match = {
      class = "^xsane$",
    },
  },
  {
    float = true,
    match = {
      class = "^org.pulseaudio.pavucontrol$",
    },
  },
  {
    float = true,
    min_size = "(monitor_w*0.8) (monitor_h*0.8)",
    match = {
      class = "^bluetuith$",
    },
  },
  {
    float = true,
    match = {
      class = "^qt5ct$",
    },
  },
  {
    float = true,
    match = {
      class = "^qt6ct$",
    },
  },
  {
    float = true,
    match = {
      class = "^bluetooth-sendto$",
    },
  },
  {
    float = true,
    max_size = "(monitor_w*0.8) (monitor_h*0.7)",
    match = {
      class = "^pamac-manager$",
    },
  },
  {
    float = true,
    match = {
      class = "^Lxappearance$",
    },
  },
  {
    float = true,
    size = "(monitor_w*0.3) (monitor_h*0.7)",
    match = {
      class = "^nmtui$",
    },
  },
  {
    float = true,
    size = "(monitor_w*0.8) (monitor_h*0.9)",
    match = {
      class = "^btop$",
    },
  },
  {
    float = true,
    size = "576 1024",
    match = {
      class = "^(?i)waydroid.*$",
    },
  },

  -- Floating for window roles
  {
    float = true,
    match = {
      xwayland = 1,
      title = "^(pop-up|bubble|task_dialog|Preferences|About)$",
    },
  },
  {
    float = true,
    match = {
      title = "^File Operation Progress$",
    },
  },
  {
    float = true,
    pin = true,
    match = {
      title = "^Picture-in-Picture$",
    },
  },
  {
    float = true,
    pin = true,
    match = {
      title = "^Picture in picture$",
    },
  },
  {
    pin = true,
    float = true,
    match = {
      title = "^Floating Window - Show Me The Key$",
    },
  },
  {
    float = true,
    pin = true,
    match = {
      title = "^Save File$",
    },
  },
  {
    float = true,
    match = {
      class = "^it.catboy.ripdrag$",
    },
  },
  {
    float = true,
    pin = true,
    match = {
      class = "^dragon-drop$",
    },
  },
  {
    float = true,
    size = "1500 1000",
    match = {
      class = "^thunar$",
      title = "^Bulk Rename - Rename Multiple Files$",
    },
  },
  {
    float = true,
    move = "(1012) (576)",
    match = {
      class = "^aegisub$",
      title = "^Styling Assistant$",
    },
  },
  {
    float = true,
    move = "(1022) (376)",
    match = {
      class = "^aegisub$",
      title = "^Select Color$",
    },
  },
  {
    float = true,
    match = {
      class = "^aegisub$",
      title = "^Styles Manager$",
    },
  },
  {
    float = true,
    move = "(793) (727)",
    match = {
      class = "^aegisub$",
      title = "^Style Editor$",
    },
  },
  {
    float = true,
    match = {
      class = "^aegisub$",
      title = "^Open subtitles file|Automation Manager|Preferences$",
    },
  },
  {
    float = true,
    match = {
      class = "^org%.inkscape%.Inkscape$",
      title = "^Convert to ASS$",
    },
  },
  {
    float = true,
    match = {
      class = "^aegisub$",
      title = "^Choose font$",
    },
  },
  {
    tile = true,
    match = {
      xwayland = 1,
      title = "^Batch convert$",
    },
  },
  {
    tile = true,
    match = {
      xwayland = 1,
      title = "^Open subtitle...$",
    },
  },
  {
    float = true,
    size = "(monitor_w*0.6) (monitor_h*0.6)",
    match = {
      class = "^(waterfox-default|waterfox)$",
      title = "^Library$",
    },
  },
  {
    float = true,
    size = "(monitor_w*0.6) (monitor_h*0.6)",
    match = {
      title = ".*DownThemAll! Manager -.*$",
    },
  },
  {
    float = true,
    size = "(monitor_w*0.6) (monitor_h*0.6)",
    match = {
      class = "^floating_shell_portrait$",
    },
  },
  {
    float = true,
    size = "(monitor_w*0.6) (monitor_h*0.6)",
    match = {
      class = "^avda$",
    },
  },
  {
    float = true,
    size = "651 70",
    match = {
      class = "^showmethekey-gtk$",
    },
  },

  -- Prevent screen from sleeping when using certain apps
  {
    idle_inhibit = "fullscreen",
    match = {
      class = "^(.*)$",
    },
  },
  {
    idle_inhibit = "fullscreen",
    match = {
      title = "^(.*)$",
    },
  },
  {
    idle_inhibit = "fullscreen",
    match = {
      fullscreen_state_internal = 2,
      fullscreen_state_client = 2,
    },
  },
  {
    float = true,
    size = "(monitor_w*0.5) (monitor_h*0.7)",
    match = {
      title = "^Vivaldi Settings: General - Vivaldi$",
    },
  },

  -- Fix yazi ueberzugpp
  {
    no_initial_focus = true,
    persistent_size = false,
    no_max_size = true,
    stay_focused = false,
    decorate = false,
    float = true,
    no_anim = true,
    no_focus = true,
    no_follow_mouse = true,
    no_blur = true,
    no_dim = true,
    no_shadow = true,
    focus_on_activate = false,
    rounding = 0,
    border_size = 0,
    pseudo = true,
    match = {
      initial_title = "^ueberzugpp_.*",
    },
  },
  -- Fix pinentry losing focus
  {
    match = { class = "(pinentry-|gcr-prompter)(.*)" },
    pin = true,
    stay_focused = true,
  },
}

-- Workspace to monitor assignments (separate from window rules)
local workspace_rules = {
  { workspace = "1", monitor = "DP-1", default = true },
  { workspace = "2", monitor = "DP-1" },
  { workspace = "3", monitor = "DP-1" },
  { workspace = "4", monitor = "DP-1" },
  { workspace = "5", monitor = "DP-1" },
  { workspace = "6", monitor = "DP-1" },
  { workspace = "7", monitor = "DP-1" },
  { workspace = "8", monitor = "DP-1" },
  { workspace = "9", monitor = "DP-1" },
  {
    workspace = "10",
    monitor = "HDMI-A-1",
    default = true,
    no_border = true,
    no_shadow = true,
    no_rounding = true,
    decorate = false,
  },
}

for _, win_rule in ipairs(window_rules) do
  hl.window_rule(win_rule)
end

for _, ws_rule in ipairs(workspace_rules) do
  hl.workspace_rule(ws_rule)
end
