# Brief for an AI agent: make this Arch Linux setup look and feel like my Omarchy system, without the AI

You are an AI coding agent (Claude Code, Antigravity, or similar). Read this whole
file before doing anything. It is written for you, not for a human skimming.

## 1. The goal

I (the owner) use **Omarchy** on one machine and like how it looks and feels. I want
my **Arch Linux** machine to look and feel the same, **without any AI features**.
This repository (`dotfiles/`) is the Arch Linux configuration. Your job is to read the
Omarchy system's configuration and carry the *look and feel* into this repo.

"Look and feel" means: colors, fonts, wallpapers, window gaps/borders/rounding/blur,
animations, bar look, launcher look, notification look, terminal look, lock screen
look, icon and cursor themes, keyboard shortcuts' muscle memory where reasonable.
It does not mean copying Omarchy's scripts, installers, update mechanism, or any
AI-related component.

## 2. Hard rules

1. **Read-only on the Omarchy machine.** Inspect, copy text out, take notes. Do not
   change, install, delete, or update anything there.
2. **No secrets.** Never read or copy `~/.ssh`, `~/.gnupg`, browser profiles, password
   stores, shell history, `.env` files, token files, API keys, or anything under
   a keyring. If a config file contains a key or token, copy the file's structure but
   replace the value with `REDACTED`, and tell me.
3. **No AI.** Do not port or enable any AI assistant, chatbot launcher, AI web-app
   shortcut, model runner, AI keybinding, or AI-related package. If you are unsure
   whether something is AI-related, leave it out and list it in your report.
4. **Do not invent.** Every value you write (hex color, font name, gap size, key
   name) must come from a file you actually read on the Omarchy machine or from
   documentation you actually fetched. If you cannot find a value, say so and leave
   a clearly marked `TODO`. Never present a guess as Omarchy's setting.
5. **Official repositories only.** No AUR packages, no `curl | sh`, no `sudo`
   inside any config. If something needs the AUR, stop and ask me.
6. **Keep this repo's design.** See section 4. Do not reintroduce Waybar, Rofi,
   Walker, Mako, a dock, or a second notification daemon.
7. **Idempotent and recoverable.** Anything you add must be safe to run twice and
   covered by `install.sh --dry-run`, backups, and `uninstall.sh`.
8. **Be honest about testing.** Say exactly what you ran and what you did not.

## 2a. If you cannot reach the Omarchy machine

If you were started on the Arch Linux machine (or anywhere without the Omarchy
configuration available), stop. Do not guess Omarchy's values from memory. Tell me
you need access to the Omarchy files and ask me to either run you there, or give
you an archive of the relevant folders with secrets removed.

## 3. Step 1: inventory the Omarchy system (read-only)

Do not assume paths. Discover them. Omarchy is Arch-based and uses Hyprland, so the
usual places to look are `~/.config/` and the system data directories, but verify
each one exists before relying on it. Produce `docs/omarchy-inventory.md` in this
repo containing, for each item, **the file path you read it from** and the value:

- **OS and versions:** Omarchy version, Hyprland version, kernel, and the GPU/driver.
- **Compositor look (Hyprland):** gaps (in/out), border size and colors (active and
  inactive), rounding, blur settings, shadow settings, opacity rules, animations and
  curves, workspace layout (dwindle/master options), cursor size, monitor scale.
- **Theme system:** how Omarchy defines a theme (which files), the name of the
  **currently active theme**, and its full palette (background, foreground, accent,
  the 16 terminal colors, selection, cursor). Record hex values exactly.
- **Fonts:** the UI font, monospace font, sizes, and where each is set. Note which
  font *packages* provide them.
- **Wallpapers:** which files the active theme uses. List names and paths. Copy the
  image files only if they are clearly shipped theme assets with no personal content,
  and tell me where you put them.
- **Bar:** layout, which modules appear, their order, icons/glyphs, spacing, height,
  colors, font size, any hover or active styling. Include a description of what a
  screenshot would show.
- **Launcher, notifications, lock screen, idle behavior:** look (colors, size,
  position, rounding, font) and timeouts.
- **Terminal:** emulator name, font, size, opacity, padding, palette, cursor style.
- **Editor / shell prompt / other CLI looks:** Neovim colorscheme and plugin theme
  settings, shell prompt style, `btop` theme, `fastfetch` or similar if present.
- **GTK / Qt / icon / cursor themes:** names and where set.
- **Keybindings:** the full Hyprland bind list, grouped (apps, windows, workspaces,
  media, screenshots, system). Mark each as keep / change / drop (see section 5).
- **mpv:** the full contents of `~/.config/mpv/` if it exists (`mpv.conf`,
  `input.conf`, `scripts/`, `script-opts/`). This is a pending item in
  `docs/pending-requirements.md`.
- **Anything AI-related you saw** (packages, launcher entries, web-app shortcuts,
  keybindings, services, environment variables). List it, do not port it.
- **Screenshots:** ask me to take them if you cannot. I want one of: empty desktop
  with the bar, a tiled layout with two terminals, the launcher open, a notification,
  the lock screen, a file manager, and Neovim. These are the reference for step 4.

## 4. Step 2: map Omarchy pieces onto this repo

This repo is a different architecture from Omarchy. Port the *appearance*, not the
components.

| Omarchy piece (verify what it really uses) | Goes into this repo as |
|---|---|
| Compositor look and animations | `hypr/appearance.lua`, `hypr/animations.lua` |
| Bar | `quickshell/modules/Bar.qml` and `quickshell/widgets/` (keep my layout: workspaces left, date/time center, tray plus Bluetooth, network, sound, display, battery right) |
| Launcher | `quickshell/launcher/Launcher.qml` (restyle only) |
| Notifications | `quickshell/notifications/` (restyle only; Quickshell stays the only notification daemon) |
| Panels (Wi-Fi, Bluetooth, sound, display, battery, calendar) | `quickshell/panels/` (restyle only) |
| Theme colors and fonts | `quickshell/themes/Theme.qml` is the single source for the shell; mirror the same values in `ghostty/config`, `hypr/appearance.lua`, `hypr/hyprlock.conf`, and the Neovim colorscheme |
| Terminal | `ghostty/config` (the terminal is Ghostty; do not add another) |
| Lock screen | `hypr/hyprlock.conf` plus `scripts/wallpaper.sh` (`set-lock`) |
| GTK/Qt dark theme | `scripts/dark-theme.sh` |
| mpv | `mpv/mpv.conf` etc., plus `packages/links.txt` and `packages/packages.txt` |
| Wallpapers | `~/Pictures/Wallpapers` (not committed unless license is clear) |

Constraints that already exist in this repo (read the code before changing it):
- Quickshell panels, launcher and bar are written in QML under `quickshell/`.
  Colors come from `Theme.qml`. Prefer changing tokens there over editing many files.
- Hyprland config is **Lua** (Hyprland 0.55+). Option and function names were
  checked against Hyprland's source; use `hypr/` as the pattern and verify any new
  option name in the Hyprland source or docs for the installed version.
- The bar must stay light: no polling loops that run every second, no dashboards.
- Super+W closes a window, Super+Space opens the launcher, Super+Shift+S takes
  screenshots. See `docs/keybindings.md`. Do not break these.

## 5. Step 3: decide what to change, and show me before applying

Write `docs/omarchy-port-plan.md` with a table: *Omarchy value -> where it goes here
-> keep / adapt / drop -> reason*. Mark as **drop** anything AI-related, anything
that depends on Omarchy's own scripts or menu system, and anything that conflicts
with my layout rules. Wait for me to approve the plan before editing files.

Keybindings: keep my current binds. Offer Omarchy binds that do not conflict as
optional additions in the plan; do not silently replace mine.

## 6. Step 4: implement

After I approve the plan:
1. Make changes in small commits or clearly separated steps, one area at a time
   (palette and fonts first, then Hyprland look, then bar, launcher, notifications,
   panels, terminal, lock screen, Neovim, mpv, wallpapers).
2. Keep every file readable: comments explain *why*, not *what*.
3. Update `packages/packages.txt` with any new official package (name checked with
   `pacman -Si`), and `docs/` where behavior changes. Update `docs/keybindings.md` if
   any bind changes.
4. Run the repo's checks and report their real output:
   - `shellcheck -S warning install.sh uninstall.sh scripts/*.sh`
   - the Hyprland Lua and QML syntax checks if available (`luac -p`, `pyside6-qmllint`)
   - `./install.sh --dry-run`
   If a check cannot run in your environment, say so; do not claim it passed.
5. Do not run `install.sh` for real on the Omarchy machine. It is for Arch Linux.

## 7. Step 5: compare and report

Ask me for screenshots of the Arch Linux machine after install, and compare against the
Omarchy reference screenshots, one view at a time. List every visible difference and
whether it is intentional (my layout, no AI) or a gap to fix. Iterate until I say the
look and feel is close enough.

Final report must contain:
- What you changed, per file.
- What you verified (with command output) and what you could not.
- Every value you could not find, marked `TODO`.
- Everything AI-related you found and left out.
- Anything you were unsure about, as questions for me.

## 8. Owner context

- Target: Arch Linux on a QEMU/KVM virtual machine first, later real hardware
  (12th-gen Intel i5, integrated GPU, 16 GB RAM, Btrfs, LUKS2, Limine).
- I am learning systems programming (C/C++/kernel work). The look should stay
  quiet and readable for long editing sessions.
- Installer is official-repos-only. For anything else I will use `paru` by hand and
  read each PKGBUILD myself.
- Quickshell is the whole shell. The terminal is Ghostty. The file manager is Nautilus.
- System monitor is `btop`; there is no dashboard.
- Known unverified areas in this repo: `hyprlock.conf`, `hypridle.conf`, the Wi-Fi,
  Bluetooth and brightness panels (a VM has no adapters), some Ghostty options, and
  the window-picking screenshot logic. See the README. Do not treat them as proven.
