local function check_cli_app(app_name)
  local command, null_device
  command = "which " .. app_name
  null_device = "2>/dev/null"
  local handle = io.popen(command .. " " .. null_device)
  if not handle then
    return false
  end
  local result = handle:read("*a")
  local success = handle:close()
  return result ~= nil and result ~= ""
end

-- Execute your favorite apps at launch
hl.on("hyprland.start", function()
  -- Auto switch monitors profiles
  if check_cli_app("shikane") then
    hl.exec_cmd("shikane --config ~/.config/shikane/config_hyprland.toml")
  end
  -- status bar
  if check_cli_app("waybar") then
    hl.exec_cmd("waybar --config ~/.config/waybar/config_hypr --style ~/.config/waybar/style_hypr.css")
  end
  -- reload hypr plugins
  if check_cli_app("hyprpm") then
    hl.exec_cmd("hyprpm reload -n")
  end
  -- Mod+c -> copy histories
  if check_cli_app("wl-paste") then
    hl.exec_cmd("wl-paste --watch cliphist store")
  end
  -- change font to Hack Nerd Font for gtk apps
  if check_cli_app("gsettings") then
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'Hack Nerd Font 16'")
  end
  -- Need this for xdg portal to works
  if check_cli_app("dbus-update-activation-environment") then
    hl.exec_cmd("dbus-update-activation-environment --all")
  end
  -- polkit agent
  if check_cli_app("/usr/libexec/hyprpolkitagent") then
    hl.exec_cmd("/usr/libexec/hyprpolkitagent")
  end
  -- wallpaper
  if check_cli_app("hyprpaper") then
    hl.exec_cmd("hyprpaper")
  end
  -- Auto start .desktop apps in autostart dir (~/.config and /etc)
  if check_cli_app("dex") then
    hl.exec_cmd("dex -a")
  end
  -- keyring
  -- if check_cli_app("gnome-keyring-daemon") then
  --   hl.exec_cmd("export $(gnome-keyring-daemon)")
  --   hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
  -- end
  -- open file manager and hover corect file from browser
  if check_cli_app("/usr/local/libexec/file_manager_dbus") then
    hl.exec_cmd("/usr/local/libexec/file_manager_dbus")
  end
  -- mpd music player daemon
  if check_cli_app("mpd") then
    hl.exec_cmd("mpd --no-daemon ~/.config/mpd/mpd.conf")
  end
  -- mpd music player daemon with mpris support
  if check_cli_app("mpd-mpris") then
    hl.exec_cmd("mpd-mpris -network unix  --host ~/.config/mpd/socket")
  end
  -- hypridle + hyprlock. Auto lock, sleep
  if check_cli_app("hypridle") then
    hl.exec_cmd("hypridle -q")
  end
  if check_cli_app("go") then
    hl.exec_cmd("~/.config/hypr/scripts/flydigi_bs2_pro_auto_fan_speed.sh > /dev/null 2>&1")
  end
  -- Disale touchpad at startup if there is mouse connected
  hl.exec_cmd("~/.config/hypr/scripts/disable-touchpad-startup.sh")
  -- start xdg-portal
  hl.exec_cmd("~/.config/hypr/scripts/xdg-portal-hyprland.sh")
  -- watch laptop battery and show notification when battery is low. hibernate if battery is critical
  hl.exec_cmd("~/.config/sway/scripts/battery-watch.sh")
end)

-- exec-once = waypaper-engine daemon
-- exec-once = ibus start --type wayland
-- exec-once = socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock EXEC:"shellevents ~/.config/ibus-bamboo/sway-watch-window-change.sh",nofork
