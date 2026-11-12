# Omarchy Port Plan

This document maps Omarchy look-and-feel values (identified in `docs/omarchy-inventory.md`) to the Arch Linux dotfiles repository, recording whether each item is kept, adapted, or dropped, along with the rationale.

---

## 1. Summary of Changes by File

| File | Old Value | New Value | Inventory Reference | Action |
|---|---|---|---|---|
| `quickshell/themes/Theme.qml` | Dark/light hybrid palette with `#14161b` bg, `#1c1f26` surface, `#d8dee9` text, `#ee14161b` translucent panel | Tokyo Night palette: `bg: "#1a1b26"`, `surface: "#24283b"`, `surface2: "#292e42"`, `border: "#414868"`, `text: "#c0caf5"`, `subtext: "#565f89"`, `panel: "#1a1b26"` (opaque), `scrim: "#801a1b26"` (50% alpha) | §2 (Tokyo Night palette), §6 (Opaque bar), §7 (Launcher scrim) | Adapt |
| `quickshell/config/Config.qml` | `fontFamily: "JetBrainsMono Nerd Font"`, `radius: 12`, `fontSize: 13`, `barHeight: 34` | `fontFamily: "VictorMono Nerd Font"`, `radius: 0` (sharp corners), `fontSize: 12`, `barHeight: 35` | §3 (rounding = 0), §4 (VictorMono NF font), §6 (bar height ~35px) | Adapt |
| `ghostty/config` | `font-family = JetBrainsMono Nerd Font`, `font-size = 11.5`, `background-opacity = 0.93`, `window-padding = 8`, hybrid palette | `font-family = VictorMono Nerd Font`, `font-size = 12`, `background-opacity = 1`, `window-padding = 0`, `cursor-style = block`, `cursor-style-blink = false`, `mouse-scroll-multiplier = 0.95`, `async-backend = epoll`, exact 16-color Tokyo Night palette | §2 (Terminal colors), §10 (Ghostty settings) | Adapt |
| `nvim/lua/plugins/colorscheme.lua` | (not present; defaults to LazyVim tokyonight extra) | Spec specifying `folke/tokyonight.nvim` with `colorscheme = "tokyonight-night"` | §11 (Neovim colorscheme) | Keep |
| `btop/themes/tokyo-night.theme` & `btop/btop.conf` | (not present in repo) | Generated btop theme matching Omarchy's `btop.theme.tpl` using Tokyo Night palette; configure `color_theme = "tokyo-night"` | §11 (btop theme template) | Adapt |
| `hypr/appearance.lua` | `gaps_in = 4`, `gaps_out = 10`, `rounding = 10`, `shadow.enabled = true`, `blur.enabled = true`, `active_border = gradient(7aa2f7, bb9af7)` | `gaps_in = 2`, `gaps_out = 1`, `rounding = 0`, `shadow.enabled = false`, `blur.enabled = false`, `active_border = 0xee7aa2f7` (Tokyo Night accent), `inactive_border = rgba(595959aa)`, cursor warp & hide on key press | §3 (Compositor look: gaps, borders, decoration, cursor) | Adapt |
| `hypr/animations.lua` | Speeds: windows 4.8, popin 90%, layers 3.8/4/1.5, workspaces enabled (speed 3, slide) | Omarchy exact curves (`easeOutQuint`, `easeInOutCubic`, `linear`, `almostLinear`, `quick`) and leaf animations (`windows` 3.79, `windowsIn` 4.1 popin 87%, `windowsOut` 1.49, `layers` 3.81, `workspaces` disabled) | §3 (Animations) | Adapt |
| `hypr/window-rules.lua` | `qs-blur` enables layer blur on all quickshell namespaces | Layer blur disabled / no-blur on quickshell layers to match `blur.enabled = false` and Omarchy flat look | §3 (Decoration blur) | Adapt |
| `quickshell/modules/Bar.qml` | Height 34, translucent panel with bottom border | Height 35, opaque Tokyo Night `#1a1b26` background, border `#414868`, layout preserved | §4 (Bar mapping), §6 (Bar look) | Adapt |
| `quickshell/launcher/Launcher.qml` | Rounded card (radius 12), translucent | Flat sharp card (radius 0), Tokyo Night surface `#1a1b26`, selected row `#292e42`, scrim `#801a1b26` | §7 (Launcher look) | Adapt |
| `quickshell/notifications/NotificationPopups.qml` & `Card.qml` | Rounded card with border `#3b4252` | Sharp card (radius 0), border `Theme.accent` (`#7aa2f7`) / `Theme.red` for critical, opaque | §8 (Notification look) | Adapt |
| `hypr/hyprlock.conf` | `inner_color = rgba(1c1f26ff)`, `outer_color = rgba(7aa2f7ff)`, `font_color = rgba(d8dee9ff)` | `inner_color = rgba(1a1b26cc)` (0.8 alpha `#1a1b26`), `outer_color = rgba(a9b1d6ff)`, `font_color = rgba(a9b1d6ff)`, `font_family = VictorMono Nerd Font`, `outline_thickness = 1` | §9 (Lock screen) | Adapt |
| `mpv/mpv.conf` & `mpv/input.conf` | (not present in repo) | Opinionated mpv config from Omarchy: `vo=gpu-next`, `gpu-api=vulkan`, `hwdec=vaapi`, `scale=ewa_lanczos`, JetBrainsMono NF OSD/subs, frameless, and complete custom `input.conf` | §14 (mpv) | Keep |
| `packages/links.txt` | 6 entries (hypr, quickshell, nvim, ghostty, zshrc, scripts) | Add `mpv ~/.config/mpv` and `btop ~/.config/btop` | §4 (mpv mapping, btop) | Adapt |
| `hypr/keybindings.lua` | Baseline keybindings | Add non-conflicting, non-AI developer binds: `Super+Shift+N` (editor/nvim), `Super+Shift+F` (Nautilus file manager), `Super+Shift+T` (btop activity monitor) | §13 (Keybindings) | Adapt |

---

## 2. Omarchy Components to Repo Mapping Table

| Omarchy Component / Value | Target in dotfiles | Disposition | Reason |
|---|---|---|---|
| Tokyo Night color palette | `quickshell/themes/Theme.qml`, `ghostty/config`, `hypr/appearance.lua`, `hypr/hyprlock.conf`, `btop/themes/` | **Keep** | User's preferred theme, quiet and readable for systems programming. |
| VictorMono Nerd Font | `quickshell/config/Config.qml`, `ghostty/config`, `hypr/hyprlock.conf` | **Keep** | Omarchy's system monospace font. |
| Window gaps (in: 2, out: 1) | `hypr/appearance.lua` | **Keep** | User's personal Omarchy override. |
| Window borders (2px, active #7aa2f7, inactive rgba(595959aa)) | `hypr/appearance.lua` | **Keep** | Matches Omarchy Tokyo Night appearance. |
| Window rounding = 0 | `hypr/appearance.lua`, `quickshell/config/Config.qml` | **Keep** | Omarchy default is sharp 0 rounding. |
| Blur & Shadows disabled | `hypr/appearance.lua`, `hypr/window-rules.lua` | **Keep** | Omarchy defaults `shadow.enabled = false`, `blur.enabled = false`. |
| Animation curves & leaves (easeOutQuint, popin 87%, workspaces disabled) | `hypr/animations.lua` | **Keep** | Omarchy's exact animation timing. |
| Opaque top bar (~35px, VictorMono NF, clock center, tray+indicators right) | `quickshell/modules/Bar.qml`, `quickshell/config/Config.qml` | **Adapt** | Repositories use Quickshell QML; styling matched to Omarchy bar while preserving existing architecture. |
| Launcher (sharp corners, opaque card, 50% scrim, selection highlight) | `quickshell/launcher/Launcher.qml` | **Adapt** | Restyle existing Quickshell launcher to match Omarchy launcher tokens. |
| Notifications (opaque, accent border, sharp corners) | `quickshell/notifications/NotificationPopups.qml` | **Adapt** | Restyle existing Quickshell notification popups. |
| Lock screen (hyprlock with Tokyo Night colors and VictorMono font) | `hypr/hyprlock.conf` | **Adapt** | Map Omarchy `shell.lock.toml` into hyprlock format. |
| Ghostty configuration (opaque, zero padding, VictorMono NF 12pt, epoll) | `ghostty/config` | **Keep** | Directly identical settings to Omarchy's Ghostty setup. |
| mpv player configuration & keybindings | `mpv/mpv.conf`, `mpv/input.conf` | **Keep** | Direct port of Omarchy mpv configuration per pending requirements. |
| btop system monitor theme | `btop/themes/tokyo-night.theme`, `btop/btop.conf` | **Adapt** | Render Omarchy `btop.theme.tpl` with Tokyo Night colors into standalone btop theme. |
| Shipped Tokyo Night wallpapers | `~/Pictures/Wallpapers/` | **Keep** | Shipped system theme assets from `/usr/share/omarchy/themes/tokyo-night/backgrounds/`. |
| AI Keybinding `Super+Shift+A` (ChatGPT) | — | **DROP** | AI-related (rule 3). |
| AI Keybinding `Super+Shift+Alt+A` (Grok) | — | **DROP** | AI-related (rule 3). |
| AI Keybinding `Super+Shift+Ctrl+A` (omarchy-agent) | — | **DROP** | AI-related (rule 3). |
| Omarchy shell scripts & update system (`omarchy-*`) | — | **DROP** | Omarchy proprietary runtime; this repo uses pure Arch + Quickshell. |
| Omarchy dock / app grid | — | **DROP** | User design rule: no dock. |
| Omarchy web app bindings (Spotify, WhatsApp, YouTube, X, etc.) | — | **DROP** | Web app shortcuts not used or requested. |
| Omarchy proprietary apps (Omawrite, Omacalc) | — | **DROP** | Omarchy-specific packages. |
