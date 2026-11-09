# Troubleshooting

Always start from the logs; do not guess.

## Hyprland won't start / config errors
- `Hyprland --version`: Lua config needs 0.55+.
- Errors show as a banner in the session; `hyprctl configerrors` lists them.
- Black screen/immediate exit in a VM: enable virtio-gpu 3D (see installation.md).
- Per-machine overrides go in `hypr/local.lua`; delete it to rule it out.
- Window-rule value formats were checked in source (`size = {w, h}`, `idle_inhibit =
  "fullscreen"`), but a rule can still fail at runtime; the error banner names it.

## Bar/shell missing or broken
- Run `qs` in a terminal to see QML errors (type errors, missing modules).
- `qs log` shows the running instance's log.
- Super+Shift+B restarts it.
- Icons show as boxes: the Nerd Font is not installed (`ttf-jetbrains-mono-nerd`).
- No tray icons: needs the app to use StatusNotifier; some apps do not.

## No notifications
Only one notification daemon can own the D-Bus name. Stop mako/dunst/swaync.
Test: `notify-send hello`.

## Volume/brightness/Wi-Fi/Bluetooth widgets
- Audio needs PipeWire + WirePlumber running: `wpctl status`.
- Brightness: `brightnessctl -m`; absent on VMs without a backlight (widget may be inert).
- Wi-Fi: `nmcli general status`. Bluetooth: `systemctl status bluetooth`.

## Neovim
- `:checkhealth`, `:Lazy`, `:LspInfo`.
- clangd needs `compile_commands.json` (CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`;
  Make: `bear -- make`).

## Lock/idle
`hypridle.conf` and `hyprlock.conf` are unverified. If lock fails, check the
hyprlock/hypridle versions' docs and run `hyprlock` from a terminal.

## Undo everything
`./uninstall.sh` (works from a TTY), then log in with your previous setup.
