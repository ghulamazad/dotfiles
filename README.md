# dotfiles: minimal Hyprland + Quickshell for systems programming

A small, readable desktop for CachyOS (Arch-based): Hyprland (tiling, Lua config),
Quickshell as the whole shell (bar, launcher, dashboard, notifications, quick
settings, power menu, overview), Kitty, Zsh and a C/C++/kernel-oriented Neovim.
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
| Neovim Lua: syntax, kernel-tree detection unit tests | LazyVim plugin loading, clangd/DAP behaviour |

Expect a few runtime errors on first launch. Fix them from the logs (see
`docs/troubleshooting.md`). Treat this as a solid starting point, not a finished product.

## Requirements

- Hyprland **0.55 or newer** (Lua configuration). Check: `Hyprland --version`.
  Older versions will not read `hyprland.lua`.
- Quickshell 0.3.x.
- A Nerd Font (`ttf-jetbrains-mono-nerd`); icons are Nerd Font glyphs.
- In a VM: UEFI and virtio-gpu with 3D acceleration (QEMU/KVM + virt-manager).
  Details in `docs/installation.md`.

## Install

```sh
git clone <this repo> ~/dotfiles && cd ~/dotfiles
./install.sh --dry-run      # shows everything, changes nothing
./install.sh                # packages (official repos only) + symlinks
```

Flags: `--dry-run`, `--yes`, `--no-packages`, `--no-distro-check`. Refuses to run as root.
Existing files are moved to `~/.dotfiles-backup/<timestamp>/` first.
`./uninstall.sh` removes only the links it made and restores backups.

## Layout

| Path | Purpose |
|---|---|
| `hypr/` | Lua config split by topic; `local.lua` (git-ignored) for per-machine overrides |
| `quickshell/` | `shell.qml` plus `modules, widgets, launcher, dashboard, notifications, quicksettings, services, components, themes, config` |
| `nvim/` | LazyVim-based config, system toolchain instead of Mason |
| `kitty/`, `zsh/` | Terminal and shell |
| `scripts/` | `screenshot.sh`, `wallpaper.sh`, `system-info.sh`, `restart-shell.sh`, `cpu-temp.sh` |
| `packages/` | `packages.txt` (package list), `links.txt` (symlink table) |
| `docs/` | installation, keybindings, troubleshooting, security, kernel-dev |

## Known limitations (by design or unverified)

- **Wi-Fi**: status and on/off only (via `nmcli`). No network list, no password entry.
  Use `nmtui` or `nmcli` in a terminal.
- **Overview** (Super+Tab) lists windows by title. No live thumbnails.
- **Wallpapers**: none by default. Put images in `~/Pictures/Wallpapers` (or set
  `DOTFILES_WALLPAPER_DIR`).
- **Night light** uses `hyprsunset`; package name and flags are unverified and it is
  not in `packages.txt`. The toggle does nothing useful unless you install it and check.
- **Notifications**: Quickshell is the notification daemon. Do not run mako/dunst/swaync.
- **Brightness** relies on `brightnessctl` machine-readable output (`-m`); unverified.
- `hyprlock.conf` and `hypridle.conf` are unverified against current syntax.
- Not touched on purpose: disk layout, LUKS, Btrfs/Snapper, Limine, the bootloader.

## Safety net

If the shell breaks, press **Super+Shift+B** (restart shell) or open a TTY
(Ctrl+Alt+F3) and run `./uninstall.sh`. Your old configs are in `~/.dotfiles-backup/`.
