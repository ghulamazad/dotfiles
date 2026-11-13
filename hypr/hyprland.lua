-- ~/.config/hypr/hyprland.lua  (copied from dotfiles/hypr by install.sh)
--
-- Entry point. Hyprland >= 0.55 uses Lua; the old hyprlang .conf format is
-- deprecated upstream, so this repo ships .lua modules instead of .conf files.
--
-- Hyprland runs every require() in its own Lua scope, so an error inside one
-- module does not stop the others from loading. Keep it that way: do NOT put
-- everything in this file.
--
-- Hyprland handles ALL window management (layouts, workspaces, rules, focus).
-- Quickshell only draws the UI and is started from autostart.lua.

require("env")
require("monitors")
require("appearance")
require("animations")
require("input")
require("window-rules")
require("keybindings")
require("autostart")

-- Optional per-machine overrides (e.g. disable blur in a VM). Not tracked in
-- git. A missing file is fine, hence pcall.
pcall(require, "local")
