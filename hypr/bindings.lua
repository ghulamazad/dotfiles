-- Keybindings. Full list: README.md.
-- Dispatcher shapes (hl.dsp.*) follow Hyprland's own Lua example config.
--
-- Everything essential works WITHOUT Quickshell (terminal, close, focus,
-- workspaces, lock, screenshots, restart-shell). Only the launcher and the bar
-- toggle depend on it. Before adding a bind, search this file for the key combo.

local mainMod = "SUPER"
local home    = os.getenv("HOME") or ""
local scripts = home .. "/.local/scripts"

-- Call a function on a Quickshell IPC target (see quickshell/shell.qml).
local function qs(target, fn)
    return hl.dsp.exec_cmd("qs ipc call " .. target .. " " .. fn)
end

-------------------------------------------------------------------------------
-- Apps and shell
-------------------------------------------------------------------------------
hl.bind(mainMod .. " + Return",           hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + SHIFT + F",        hl.dsp.exec_cmd("nautilus --new-window"))
hl.bind(mainMod .. " + SHIFT + N",        hl.dsp.exec_cmd("ghostty -e nvim"))
hl.bind(mainMod .. " + SHIFT + T",        hl.dsp.exec_cmd("ghostty -e btop"))
hl.bind(mainMod .. " + Space",            qs("launcher", "toggle"))
hl.bind(mainMod .. " + Escape",           qs("launcher", "power"))
hl.bind(mainMod .. " + SHIFT + Space",    qs("bar", "toggle"))
hl.bind(mainMod .. " + CTRL + L",         hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + SHIFT + R",        hl.dsp.reload_config())
hl.bind(mainMod .. " + SHIFT + B",        hl.dsp.exec_cmd(scripts .. "/restart-shell.sh"))

-------------------------------------------------------------------------------
-- Windows
-------------------------------------------------------------------------------
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }))

-- Resize with SUPER + minus / equal (key codes 20 and 21, any keyboard layout).
hl.bind(mainMod .. " + code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + code:21", hl.dsp.window.resize({ x = 100,  y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(mainMod .. " + SHIFT + code:21", hl.dsp.window.resize({ x = 0, y = 100,  relative = true }))

-- Cycle through windows.
hl.bind("ALT + TAB", hl.dsp.window.cycle_next())
hl.bind("ALT + TAB", hl.dsp.window.bring_to_top())
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }))

-------------------------------------------------------------------------------
-- Workspaces 1-10 (key codes 10-19, so the number row works on any layout)
-------------------------------------------------------------------------------
for i = 1, 10 do
    local key = "code:" .. tostring(i + 9)
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + mouse_down",  hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + mouse_up",    hl.dsp.focus({ workspace = "m-1" }))

-- Scratchpad.
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + ALT + S",   hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Mouse: SUPER + drag moves, SUPER + right-drag resizes.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-------------------------------------------------------------------------------
-- Screenshots (bin/screenshot.sh: grim + slurp + jq + wl-copy)
-------------------------------------------------------------------------------
hl.bind("Print",         hl.dsp.exec_cmd(scripts .. "/screenshot.sh select"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(scripts .. "/screenshot.sh screen"))

-------------------------------------------------------------------------------
-- Hardware keys (also work on the lock screen: locked = true)
-------------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
