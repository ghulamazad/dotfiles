-- Environment for everything Hyprland launches. Hyprland already exports the
-- Wayland session variables; only add what is needed.

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt apps (including Quickshell) use Wayland, falling back to X11.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- Icon theme for Quickshell (launcher, tray, notifications): Tela, if installed.
-- Tela is AUR-only. Look for the variant folders instead of assuming one exists;
-- if none is found nothing is set and Quickshell keeps its default icons.
local home = os.getenv("HOME") or ""
local roots = { home .. "/.local/share/icons", home .. "/.icons", "/usr/share/icons" }
local found = nil
for _, name in ipairs({ "Tela-green-dark", "Tela-dark", "Tela" }) do
    for _, root in ipairs(roots) do
        if not found then
            local f = io.open(root .. "/" .. name .. "/index.theme", "r")
            if f then f:close() found = name end
        end
    end
end
if found then hl.env("QS_ICON_THEME", found) end
