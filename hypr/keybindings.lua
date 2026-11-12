-- Keybindings. Full table in docs/keybindings.md.
--
-- Dispatcher names and argument shapes follow Hyprland's own example config
-- and its Lua binding source (hl.dsp.window.*, hl.dsp.focus, hl.dsp.layout, ...).
--
-- Design rule: everything essential to survive a crashed Quickshell works
-- WITHOUT Quickshell: terminal, close, focus, workspaces, lock, screenshots,
-- restart-shell. Only the launcher and the bar panels depend on it.
--
-- No two binds share the same key combination. When adding a bind, search
-- this file for the combo first.

local mainMod = "SUPER"
local home    = os.getenv("HOME") or ""
local scripts = home .. "/.local/share/dotfiles/scripts"

-- Helper: call a method on a Quickshell IPC target (see quickshell/shell.qml).
local function qs(target, fn)
    return hl.dsp.exec_cmd("qs ipc call " .. target .. " " .. fn)
end

-------------------------------------------------------------------------------
-- Core
-------------------------------------------------------------------------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + W",      hl.dsp.window.close())
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())              -- dwindle only
hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit"))        -- dwindle only
hl.bind(mainMod .. " + G",      hl.dsp.group.toggle())               -- toggle window group
hl.bind(mainMod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd("loginctl lock-session"))

-- Applications (non-conflicting, non-AI developer binds from Omarchy Inventory §13)
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("ghostty -e nvim"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("nautilus --new-window"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("ghostty -e btop"))

-- Reload the Hyprland config / restart the Quickshell shell independently.
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.reload_config())
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(scripts .. "/restart-shell.sh"))

-- Toggle between the two layouts. State lives in this closure; the runtime
-- hl.config() call is the documented way to change options on the fly.
local currentLayout = "dwindle"
hl.bind(mainMod .. " + SHIFT + Space", function()
    currentLayout = (currentLayout == "dwindle") and "master" or "dwindle"
    hl.config({ general = { layout = currentLayout } })
end)

-------------------------------------------------------------------------------
-- Quickshell UI (qs ipc call <target> <function>)
-------------------------------------------------------------------------------
hl.bind(mainMod .. " + Space",       qs("launcher", "toggle"))
hl.bind(mainMod .. " + N",           qs("notifications", "toggleCenter"))
hl.bind(mainMod .. " + C",           qs("launcher", "openClipboard"))
hl.bind(mainMod .. " + SHIFT + W", qs("launcher", "openWallpapers"))
hl.bind(mainMod .. " + Tab",         qs("overview", "toggle"))
hl.bind(mainMod .. " + SHIFT + E",   qs("power", "toggle"))

-------------------------------------------------------------------------------
-- Focus / move windows
-------------------------------------------------------------------------------
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-------------------------------------------------------------------------------
-- Workspaces 1-9
-------------------------------------------------------------------------------
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

-- Previous/next workspace (relative to existing ones, as in the example config).
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-1" }))

-------------------------------------------------------------------------------
-- Mouse: SUPER + drag to move, SUPER + right-drag to resize
-------------------------------------------------------------------------------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-------------------------------------------------------------------------------
-- Screenshots (scripts/screenshot.sh: grim + slurp + jq + wl-copy)
-------------------------------------------------------------------------------
-- Pick a window (click) or an area (drag). Saved to ~/Pictures/Screenshots and copied.
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scripts .. "/screenshot.sh select"))
hl.bind("Print",         hl.dsp.exec_cmd(scripts .. "/screenshot.sh select"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(scripts .. "/screenshot.sh screen"))

-------------------------------------------------------------------------------
-- Media / hardware keys (work on the lock screen too: locked = true)
-------------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
