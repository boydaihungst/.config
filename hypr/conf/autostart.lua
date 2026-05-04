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
  if check_cli_app("gnome-keyring-daemon") then
    hl.exec_cmd("export $(gnome-keyring-daemon)")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
  end
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
  -- Disale touchpad at startup if there is mouse connected
  hl.exec_cmd("~/.config/hypr/scripts/disable-touchpad-startup.sh")
  -- start xdg-portal
  hl.exec_cmd("~/.config/hypr/scripts/xdg-portal-hyprland.sh")
  -- watch laptop battery and show notification when battery is low. hibernate if battery is critical
  hl.exec_cmd("~/.config/sway/scripts/battery-watch.sh")
end)
local function inspect(value, options)
  -- Default options
  local opts = options or {}
  local indent = opts.indent or "  "
  local level = opts.level or 0
  local max_level = opts.max_level or 8
  local seen = opts.seen or {}
  local newline = opts.newline or "\n"

  -- Helper to create indentation
  local function get_indent(lvl)
    return string.rep(indent, lvl)
  end

  -- Helper to check if a table is empty
  local function is_empty(t)
    if type(t) ~= "table" then
      return false
    end
    for _ in pairs(t) do
      return false
    end
    return true
  end

  -- Helper to check if a table is array-like (sequential)
  local function is_array_like(t)
    local count = 0
    for k, v in pairs(t) do
      if type(k) ~= "number" or k <= 0 then
        return false
      end
      count = count + 1
    end
    -- Check if keys are sequential from 1 to count
    for i = 1, count do
      if t[i] == nil then
        return false
      end
    end
    return true
  end

  -- Convert single value
  local function value_to_string(val)
    local t = type(val)

    if t == "nil" then
      return "nil"
    elseif t == "string" then
      return string.format("%q", val)
    elseif t == "number" then
      return tostring(val)
    elseif t == "boolean" then
      return tostring(val)
    elseif t == "function" then
      local name = debug and debug.getinfo and debug.getinfo(val, "n").name
      if name then
        return string.format("function: %s", name)
      end
      return "function"
    elseif t == "thread" then
      return "thread"
    elseif t == "userdata" then
      return tostring(val)
    else
      return tostring(val)
    end
  end

  -- Main inspection logic
  local function inspect_recursive(val, current_level, seen_table)
    local t = type(val)

    -- Handle non-table types
    if t ~= "table" then
      return value_to_string(val)
    end

    -- Check for recursion/circular references
    if seen_table[val] then
      return "<circular reference>"
    end

    -- Check max depth
    if current_level >= max_level then
      return "{...}"
    end

    -- Check for empty table
    if is_empty(val) then
      return "{}"
    end

    -- Mark this table as seen
    seen_table[val] = true

    local result = {}
    local indent_str = get_indent(current_level)
    local next_indent_str = get_indent(current_level + 1)

    -- Check if array-like for compact display
    local is_array = is_array_like(val)

    if is_array then
      -- Array format: {1, 2, 3}
      local items = {}
      for i = 1, #val do
        table.insert(items, inspect_recursive(val[i], current_level + 1, seen_table))
      end
      result[#result + 1] = string.format("{%s}", table.concat(items, ", "))
    else
      -- Table format: {key = value, key2 = value2}
      result[#result + 1] = "{" .. newline

      -- Collect and sort keys for consistent output
      local keys = {}
      for k, v in pairs(val) do
        table.insert(keys, k)
      end
      table.sort(keys, function(a, b)
        local type_a = type(a)
        local type_b = type(b)
        if type_a ~= type_b then
          return type_a < type_b
        end
        return tostring(a) < tostring(b)
      end)

      -- Process each key-value pair
      for _, k in ipairs(keys) do
        local v = val[k]
        local key_str = value_to_string(k)
        local value_str = inspect_recursive(v, current_level + 1, seen_table)

        -- Handle multiline values
        if type(v) == "table" and not is_empty(v) and type(k) ~= "number" then
          table.insert(result, string.format("%s%s = %s%s", next_indent_str, key_str, value_str, newline))
        else
          table.insert(result, string.format("%s%s = %s,%s", next_indent_str, key_str, value_str, newline))
        end
      end

      result[#result + 1] = indent_str .. "}"
    end

    -- Remove marking to allow reuse
    seen_table[val] = nil

    return table.concat(result)
  end

  return inspect_recursive(value, level, seen)
end

-- exec-once = waypaper-engine daemon
-- exec-once = ibus start --type wayland
-- exec-once = socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock EXEC:"shellevents ~/.config/ibus-bamboo/sway-watch-window-change.sh",nofork
