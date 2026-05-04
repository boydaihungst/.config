-- Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

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
-- SUPER key
local mod = "MOD4"
local left = "h"
local down = "j"
local up = "k"
local right = "l"

local terminal = "kitty"
local browser = "vivaldi"
local powermenu = "~/.config/rofi/powermenu/type-2/powermenu.sh"
local applaucher = "~/.config/rofi/launchers/type-1/launcher.sh"
local powerprofiles = "~/.config/hypr/scripts/power-profiles"
local volumectl = "~/.config/hypr/scripts/volumectl"
local brightnesschange = "~/.config/hypr/scripts/brightness-change.sh"
local toggle_gemini = "~/.config/hypr/scripts/toggle_gemini.sh"

-- Basic Keybindings
-- Open terminal
hl.bind(mod .. " + RETURN", hl.dsp.exec_raw(terminal))
-- Close current window
hl.bind(mod .. " + Q", hl.dsp.window.close())
-- Open app launcher
hl.bind(mod .. " + D", hl.dsp.exec_raw(applaucher))
-- Open power menu
hl.bind(mod .. " + X", hl.dsp.exec_raw(powermenu))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))

-- Open yazi file manager
hl.bind(mod .. " + N", hl.dsp.exec_raw(terminal .. " --app-id 'yazi' -- yazi"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_raw("YAZI_LOG=debug " .. terminal .. " --app-id 'yazi' -- yazi"))

-- Open nvim editor
hl.bind(mod .. " + E", hl.dsp.exec_raw(terminal .. " --app-id 'nvim' -- nvim"))
-- bind = $mod, N, exec, wezterm start --class 'yazi' -- yazi
-- bind = $mod SHIFT, N, exec, YAZI_LOG=debug wezterm start --class 'yazi' -- yazi
-- bind = $mod, E, exec, wezterm start --class 'nvim' -- nvim
--
-- Open browser
hl.bind(mod .. " + W", hl.dsp.exec_raw(browser))

-- Color picker
hl.bind(mod .. " + Z", hl.dsp.exec_cmd("hyprpicker -a -f hex -r -q"), { locked = true })

-- Ibus switch
-- bind = Control_L, SPACE, exec, ~/.config/ibus-bamboo/ibus_switch.sh

-- Screenshot
hl.bind(
  "Print",
  hl.dsp.exec_cmd('hyprshot -m output -o "$HOME/Pictures/Screenshots" -m active -t 3000 -z'),
  { locked = true }
)
hl.bind(
  mod .. " + SHIFT + S",
  hl.dsp.exec_cmd('hyprshot -m region -m active  -o "$HOME/Pictures/Screenshots" -t 3000 -z'),
  { locked = true }
)
hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_raw(powerprofiles), { locked = true })

-- Clipboard Management
hl.bind(
  mod .. " + C",
  hl.dsp.exec_cmd(
    "cliphist list -max-items 1000 -max-dedupe-search 100 | rofi -dmenu -i -theme ~/.config/rofi/clipboard.rasi -display-columns 2 | cliphist decode | wl-copy"
  )
)

-- Volume Controls
hl.bind("XF86AudioMute", hl.dsp.exec_raw(volumectl .. " togmute"), { repeating = true, locked = true })
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_raw(volumectl .. " --volume-step 1 up"),
  { repeating = true, locked = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_raw(volumectl .. " --volume-step 1 down"),
  { repeating = true, locked = true }
)

-- Backlight
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_raw(brightnesschange .. " 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_raw(brightnesschange .. " 5%-"), { repeating = true, locked = true })

-- Toggle touchpad
hl.bind(
  "XF86TouchpadOff",
  hl.dsp.exec_cmd('hyprctl -r keyword "device[elan06fa:00-04f3:327e-touchpad]:enabled" false'),
  { locked = true }
)
hl.bind(
  "XF86TouchpadOn",
  hl.dsp.exec_cmd('hyprctl -r keyword "device[elan06fa:00-04f3:327e-touchpad]:enabled" true'),
  { locked = true }
)

-- Open calculator app
if check_cli_app("speedcrunch") then
  hl.bind("XF86Calculator", hl.dsp.exec_raw("speedcrunch"))
elseif check_cli_app("galculator") then
  hl.bind("XF86Calculator", hl.dsp.exec_raw("galculator"))
end

-- Media Controls
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86WLAN", hl.dsp.exec_cmd("nmcli radio wifi toggle"), { locked = true })
-- Lenovo legion 5 copilot AI button
hl.bind(mod .. " + SHIFT + XF86TouchpadOff", hl.dsp.exec_raw(toggle_gemini))
hl.bind("XF86Phone", hl.dsp.exec_cmd('notify-send "Phone"'))
hl.bind(mod .. " + P", hl.dsp.exec_raw('notify-send "Switch Video Mode key pressed"'))

-- Move focus with mod + arrow keys
hl.bind(mod .. " + " .. left, hl.dsp.focus({ direction = "l" })) -- Move focus left
hl.bind(mod .. " + " .. right, hl.dsp.focus({ direction = "r" })) -- Move focus right
hl.bind(mod .. " + " .. up, hl.dsp.focus({ direction = "u" })) -- Move focus up
hl.bind(mod .. " + " .. down, hl.dsp.focus({ direction = "d" })) -- Move focus down
hl.bind(mod .. " + T", hl.dsp.window.cycle_next({ floating = true })) -- Focus next floating window
hl.bind(mod .. " + SHIFT + " .. left, hl.dsp.window.move({ direction = "l" })) -- Move window left
hl.bind(mod .. " + SHIFT + " .. right, hl.dsp.window.move({ direction = "r" })) -- Move window right
hl.bind(mod .. " + SHIFT + " .. up, hl.dsp.window.move({ direction = "u" })) -- Move window up
hl.bind(mod .. " + SHIFT + " .. down, hl.dsp.window.move({ direction = "d" })) -- Move window down

-- switch/iterate between workspaces
hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "m-1" }))

-- Switch workspaces with mod + [0-9]
hl.bind(mod .. " + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind(mod .. " + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind(mod .. " + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind(mod .. " + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind(mod .. " + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind(mod .. " + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind(mod .. " + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind(mod .. " + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind(mod .. " + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to a workspace with mod + SHIFT + [0-9] and mod + [0-9]
hl.bind(mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = "1", follow = false }))
hl.bind(mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = "2", follow = false }))
hl.bind(mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = "3", follow = false }))
hl.bind(mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = "4", follow = false }))
hl.bind(mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = "5", follow = false }))
hl.bind(mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = "6", follow = false }))
hl.bind(mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = "7", follow = false }))
hl.bind(mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = "8", follow = false }))
hl.bind(mod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = "9", follow = false }))
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10", follow = false }))

-- Move window to monitor with mod + left/right/up/down
hl.bind(mod .. " + LEFT", hl.dsp.window.move({ monitor = "l", follow = false }))
hl.bind(mod .. " + RIGHT", hl.dsp.window.move({ monitor = "r", follow = false }))
hl.bind(mod .. " + UP", hl.dsp.window.move({ monitor = "u", follow = false }))
hl.bind(mod .. " + DOWN", hl.dsp.window.move({ monitor = "d", follow = false }))

-- Layout and Tiling
-- bind = $mod, MINUS, layoutmsg
-- https://wiki.hyprland.org/Configuring/Dispatchers/#fullscreenstate
--
-- Toggle floating of current window
hl.bind(mod .. " + F", hl.dsp.window.fullscreen_state({ action = "toggle", internal = 2, client = 2 }))

-- Toggle floating/tiling of current window
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Toggle Resize Mode
hl.bind(mod .. " + R", function()
  if hl.get_current_submap() == " Resize " then
    hl.dispatch(hl.dsp.submap("reset"))
  else
    hl.dispatch(hl.dsp.submap(" Resize "))
  end
end, { submap_universal = true })

-- Start a submap called "resize".
hl.define_submap(" Resize ", function()
  -- Set repeating binds for resizing the active window.
  hl.bind(right, hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
  hl.bind(left, hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
  hl.bind(up, hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
  hl.bind(down, hl.dsp.window.resize({ x = 50, y = 50, relative = true }), { repeating = true })

  hl.bind("RIGHT", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
  hl.bind("LEFT", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
  hl.bind("UP", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
  hl.bind("DOWN", hl.dsp.window.resize({ x = 50, y = 50, relative = true }), { repeating = true })

  -- Use `reset` to go back to the global submap
  hl.bind("ESCAPE", hl.dsp.submap("reset"))
  hl.bind("RETURN", hl.dsp.submap("reset"))
end)
hl.config({
  binds = {
    drag_threshold = 10, -- Fire a drag event only after dragging for more than 10px
  },
})
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true }) -- ALT + LMB: Move a window by dragging more than 10px.
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- ALT + LMB: Floats a window by clicking
-- Move/resize windows with mod + LMB/RMB and dragging
-- bindm = $mod, mouse:272, movewindow -- Move window
-- bindm = $mod, mouse:273, resizewindow -- Resize window
