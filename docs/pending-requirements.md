# Pending requirements

Things the owner wants that are NOT implemented yet. An AI agent (Claude Code,
Antigravity, etc.) or a person should read this file before changing the repo.
Do not mark an item done unless it was actually implemented and checked.

## mpv: configure it like Omarchy

**Status:** not implemented. The Omarchy mpv config was not available when this
was written, and it was not found in the public pages that were checked. Nothing
here is a copy of Omarchy's file, and no Omarchy mpv settings should be guessed.

**What is wanted:** `mpv/mpv.conf` in this repo that reproduces the mpv setup
Omarchy ships, so mpv behaves the same here.

**How to do it (for an agent with access to a machine running Omarchy):**
1. Read the Omarchy mpv config from that machine. The expected location is
   `~/.config/mpv/mpv.conf`. Also check for `~/.config/mpv/input.conf`, `scripts/`
   and `script-opts/`, and list anything else in `~/.config/mpv/`.
2. If no such files exist there, stop and tell the owner. Do not invent settings
   and present them as Omarchy's.
3. Copy the options into `mpv/mpv.conf` (and `input.conf` etc. if present),
   keeping comments. Remove any option that does not apply to this setup, such
   as hardware-decoding settings for a GPU the target does not have, and note
   each removal.
4. Check every option name and value against the installed mpv's documentation
   (`man mpv`, or the manual for the installed version). mpv renames and removes
   options between versions, so a config copied from another version can fail.
5. Add `mpv` to `packages/packages.txt` and a line
   `mpv    ~/.config/mpv` to `packages/links.txt`.
6. Test with `mpv --no-config` versus the new config on a sample file, and read
   mpv's startup output for "option not found" or "invalid value" messages.
   Report what was and was not tested, especially under a VM where hardware
   decoding may not work.

**Owner's environment:** Hyprland on CachyOS, currently in a QEMU/KVM VM.

## Implemented in the last build (statically checked only, not run live)

Bar and panels, Ghostty instead of kitty, Nautilus, `btop`, dark-theme script,
Super+W close, launcher Ctrl keys, window-or-area screenshot, scratchpad and
dashboard removed, lock-screen wallpaper through `wallpaper.sh set-lock`.
See README "Known limitations" for what is unverified.

## Still manual (not done by any script)

- Removing Micro, Alacritty, Meld, the SchedExt GUI manager and Shelly:
  check each with `pacman -Qi <name>` for "Required By", then `sudo pacman -Rns`.
- Package installs outside the official repos: use `paru` by hand and read each
  PKGBUILD first. `install.sh` stays official-repos-only.
