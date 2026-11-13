# Keybindings

`Super` = the Windows key. Defined in `hypr/keybindings.lua`.

| Keys | Action |
|---|---|
| Super+Return | Terminal (Ghostty) |
| Super+Shift+N | Editor (Neovim in Ghostty) |
| Super+Shift+F | File manager (Nautilus) |
| Super+Shift+T | Activity monitor (btop in Ghostty) |
| Super+G / Super+Alt+G | Toggle window group / Move out of group |
| Super+Space | App launcher (just type) |
| Super+W | Close window |
| Super+F | Fullscreen |
| Super+V | Toggle floating |
| Super+P / Super+J | Pseudotile / toggle split (dwindle layout) |
| Super+Shift+Space | Switch layout |
| Super+L | Lock screen |
| Super+Shift+R | Reload Hyprland config |
| Super+Shift+B | Restart Quickshell |
| Super+Arrows | Focus |
| Super+Shift+Arrows | Move window |
| Super+1..9 | Workspace |
| Super+Shift+1..9 | Move window to workspace |
| Super+Ctrl+Left/Right, Super+scroll | Previous/next workspace |
| Super+left-drag / right-drag | Move / resize floating window |
| Super+Shift+S or Print | Screenshot: click a window or drag an area |
| Shift+Print | Screenshot of the whole screen |
| Volume, mic, brightness, media keys | wpctl, brightnessctl, playerctl |

## Inside the launcher
Up/Down, Ctrl+N / Ctrl+J (next), Ctrl+P / Ctrl+K (previous), Enter (run),
Esc (close).

## Bar
Display only. Tray icons still respond to clicks (left/right click, menus).

Removed on purpose: Super+C (clipboard history), Super+Shift+W (wallpaper picker),
Super+N (notification center), Super+Tab (overview), Super+Shift+E (power menu),
Super+D (dashboard, use `btop`), Super+A, Super+Q (now Super+W), the scratchpad binds.
