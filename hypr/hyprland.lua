-- ~/.config/hypr/hyprland.lua (copied from this repo's hypr/ by scripts/install-config.sh)
--
-- Hyprland >= 0.55 reads Lua. Each require() runs in its own scope, so an error
-- in one module does not stop the others from loading. Check for mistakes with:
--   hyprctl configerrors
--
-- Hyprland does ALL window management. Quickshell only draws the bar, the
-- launcher and notifications, and is started from autostart.lua.

-- Make sure the modules next to this file can be found, whatever the default is.
local config_home = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config")
package.path = config_home .. "/hypr/?.lua;" .. package.path

require("env")
require("monitors")
require("input")
require("looknfeel")
require("rules")
require("bindings")
require("autostart")

-- Optional per-machine overrides, not tracked in git. A missing file is fine.
pcall(require, "local")
