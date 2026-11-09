# Keybindings

`Super` = the Windows key. Defined in `hypr/keybindings.lua`.

| Keys | Action |
|---|---|
| Super+Return | Terminal (kitty) |
| Super+Space | Launcher (apps, calculator, recents, power actions; just type) |
| Super+D | Dashboard |
| Super+A | Quick settings |
| Super+N | Notification center |
| Super+C | Clipboard history |
| Super+W | Wallpaper picker |
| Super+Tab | Window overview |
| Super+Shift+E | Power menu |
| Super+Q | Close window |
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
| Super+S / Super+Shift+S | Toggle / send to scratchpad |
| Super+left-drag / right-drag | Move / resize floating window |
| Print / Shift+Print | Screenshot region / screen |
| Media, volume, brightness keys | wpctl, brightnessctl, playerctl |

Kitty uses Ctrl+Shift combos only, so nothing conflicts with Super binds.
The launcher calculator syntax is in `quickshell/launcher/Launcher.qml`; check it
there rather than trusting this table if you change it.
