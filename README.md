# dotfiles: minimal Hyprland + Quickshell for systems programming

A small, readable desktop for Arch Linux: Hyprland (tiling, Lua config),
Quickshell as a minimal shell (a bar, an app launcher and notification popups, nothing
else), Ghostty, Nautilus, Zsh and your own Neovim config (`ghulamazad`).
No AI features, no telemetry, no AUR packages, no Waybar/Rofi/dock.

## Status: read this first

This repo was written without access to a running Hyprland, Quickshell or Neovim,
so the honest status is:

| Checked (static, in the authoring environment) | NOT checked (needs your VM) |
|---|---|
| Shell scripts pass `bash -n` and shellcheck | Hyprland actually accepting the Lua config |
| Installer: dry-run, backup, idempotent re-run, uninstall restore | Quickshell loading every QML file at runtime |
| Hyprland Lua: every `hl.*` call matches names found in Hyprland's source (strict mock) | `hypridle.conf` / `hyprlock.conf` syntax |
| QML: all files parse; imports, IPC names, scripts and layer namespaces cross-checked | Package names in `packages.txt` (only some verified) |
| Neovim Lua: syntax; colour module runs against a mock `vim` | Plugin loading, clangd/DAP behaviour, how the colours look |

Expect a few runtime errors on first launch. Fix them from the logs (see
`docs/troubleshooting.md`). Treat this as a solid starting point, not a finished product.

## Requirements

- Hyprland **0.55 or newer** (Lua configuration). Check: `Hyprland --version`.
  Older versions will not read `hyprland.lua`.
- Quickshell 0.3.x.
- A Nerd Font (`ttf-victor-mono-nerd` or `ttf-jetbrains-mono-nerd`); icons are Nerd Font glyphs.
- In a VM: UEFI and virtio-gpu with 3D acceleration (QEMU/KVM + virt-manager).
  Details in `docs/installation.md`.

## Install

```sh
git clone <this repo> ~/dotfiles && cd ~/dotfiles
./install.sh --dry-run      # shows everything, changes nothing
./install.sh                # packages (official repos only) + copies your config into ~/.config etc.
```

Flags: `--dry-run`, `--yes`, `--no-packages`, `--no-distro-check`. Refuses to run as root.
Existing files are moved to `~/.dotfiles-backup/<timestamp>/` first.
`./uninstall.sh` removes only the links it made and restores backups.

## Layout

| Path | Purpose |
|---|---|
| `hypr/` | Lua config split by topic; `local.lua` (git-ignored) for per-machine overrides |
| `quickshell/` | `shell.qml` plus `modules, widgets, launcher, notifications, services, components, themes, config` |
| `nvim/` | Your own Neovim config (`ghulamazad`) with the standalone Petrol Lagoon colourscheme (`colors/`, `lua/ghulamazad/petrol_lagoon.lua`); tokyodark removed |
| `git/` | Your git config and ignore file (identity stays in `~/.config/git/local`, not in this repo) |
| `ghostty/`, `zsh/` | Terminal and shell (with aliases, functions, fzf integration) |
| `tmux/` | Terminal multiplexer configured with the Petrol Lagoon theme |
| `starship/` | Cross-shell prompt configuration |
| `lazygit/` | TUI Git interface styled with the Petrol Lagoon theme |
| `tmux-sessionizer-config/` | Fuzzy project switcher configuration |
| `scripts-local/` | User scripts (`tmux-sessionizer`) copied to `~/.local/scripts` |
| `btop/` | System monitor configuration and Petrol Lagoon theme |
| `mpv/` | GPU-accelerated video player config (ported from Omarchy) |
| `wallpapers/` | Shipped desktop wallpapers (not recolored) |
| `scripts/` | `screenshot.sh`, `wallpaper.sh`, `dark-theme.sh`, `restart-shell.sh` |
| `packages/` | `packages.txt` (package list), `links.txt` (copy table) |
| `docs/` | installation, keybindings, troubleshooting, security, pending-requirements, omarchy-port-brief, omarchy-inventory, omarchy-port-plan |

## Known limitations (by design or unverified)

- **Bar**: workspaces (left), date and time (center), tray plus Bluetooth, network, sound
  and battery icons (right). The icons are display-only: nothing opens when you click
  them. Manage things yourself: `nmtui`, `bluetoothctl`, `wpctl`, `btop`. Not run live.
- **Launcher** (Super+Space): apps and recents only. No calculator, clipboard history,
  wallpaper picker, power menu or window overview (removed on purpose). Power off or
  log out from a terminal (`systemctl poweroff`, `hyprctl dispatch exit`).
- **Wallpaper**: drawn by Quickshell from a state file. Set it from a terminal with
  `~/.local/share/dotfiles/scripts/wallpaper.sh set FILE` (`set-lock FILE` for the lock
  screen, `list` to see choices). Shipped images are in `wallpapers/`.
- **Screenshots**: Super+Shift+S (or Print) picks a window or an area; Shift+Print takes
  the whole screen. Saved to `~/Pictures/Screenshots` and copied. The window-picking
  logic was tested against sample data only, not a live Hyprland.
- **Dark theme**: `scripts/dark-theme.sh` sets the GTK/portal dark preference. Qt apps and apps
  with their own theme setting may still need a manual change.
- **mpv**: configured with GPU acceleration (`vo=gpu-next`), Vulkan, VAAPI, frameless UI and custom bindings ported from Omarchy.
- **Notifications**: popups only (no history, no Do Not Disturb). Quickshell is the
  notification daemon. Do not run mako/dunst/swaync.
- `hyprlock.conf` and `hypridle.conf` are unverified against current syntax.
- Not touched on purpose: disk layout, LUKS, Btrfs/Snapper, Limine, the bootloader.

## Safety net

If the shell breaks, press **Super+Shift+B** (restart shell) or open a TTY
(Ctrl+Alt+F3) and run `./uninstall.sh`. Your old configs are in `~/.dotfiles-backup/`.
