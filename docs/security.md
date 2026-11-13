# Security notes

## Threat model
Single-user desktop. Goals: do not run untrusted code by accident, do not escalate
privileges silently, stay recoverable.

## What this repo does
- No `sudo`/`pkexec` in any QML, Lua or script. The only `sudo` is `pacman -S` in
  `install.sh`, which asks first. Privileged desktop actions go through polkit
  (`hyprpolkitagent`).
- Commands are fixed argument lists, not shell strings built from user input. The
  launcher calculator accepts only a regex-whitelisted expression.
- Official repositories only; every package checked with `pacman -Si`. No AUR.
- Installer never touches partitions, LUKS, Btrfs, Snapper or the bootloader, only
  paths under `$HOME`, with backups and an uninstaller.
- No network access from the config itself; no telemetry, no AI services.

## Quickshell is code, not a theme
QML can run processes and read files as your user. Treat `quickshell/` like a program:
read changes before pulling them, and apply the same care to any third-party
"shell" config you copy. This repo's QML uses `Process` only with fixed commands
(grep for `command:` to audit).

## Network status
The bar only reads `nmcli device status` (read-only). It never changes a connection.
Privileged actions (Wi-Fi passwords, DNS, power) are done by you in a terminal, so no
Quickshell code handles secrets.

## Not covered / unverified
- Hyprland's own permission system for screencopy/keyboard grabs exists in recent
  versions; its exact options were not verified here, so none are configured.
- Not a substitute for full-disk encryption, a firewall or updates.
- I did not audit upstream packages.

## Reviewing before you run
```sh
./install.sh --dry-run
grep -rn "sudo\|pkexec" . --include='*' 2>/dev/null | grep -v '^./docs'
grep -rn "command:" quickshell
```
