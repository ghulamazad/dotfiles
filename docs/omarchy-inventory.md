# Omarchy System Inventory

> **Date:** 2026-11-11  
> **Machine:** Omarchy machine (same host as this dotfiles repo)  
> **Method:** Read-only inspection of `/usr/share/omarchy/`, `~/.config/omarchy/`, `~/.config/hypr/`, `~/.config/ghostty/`, `~/.config/mpv/`, `~/.config/nvim/`, and system fontconfig.  
> **Principle:** Every value below was read from an actual file on disk. `TODO` marks anything that could not be confirmed.

---

## 1. OS and Versions

| Item | Value | Source |
|---|---|---|
| Omarchy version | `4.5.0-3` (package) / `4.0.0.alpha` (version file) | `pacman -Qi omarchy`; `/usr/share/omarchy/version` |
| Hyprland version | `0.56.2-4` | `pacman -Qi hyprland` |
| Kernel | `7.2.15-1-omarchy` | `uname -r` |
| GPU/driver | Intel integrated (12th-gen i5) — `hwdec=vaapi` in mpv config | `~/.config/mpv/mpv.conf` |

---

## 2. Active Theme

`omarchy theme current` returns **Unknown** — the `shell.json` has no `theme` key set. The shell falls back to Color.qml hardcoded defaults. However, the user has:
- Custom backgrounds stored at `~/.config/omarchy/backgrounds/tokyo-night/`
- Neovim set to `tokyonight-night` colorscheme
- Font base-size overridden to `16` in `~/.config/omarchy/shell.toml`

**Most likely intended theme: Tokyo Night** (confirmed by above evidence). The palette below is from `/usr/share/omarchy/themes/tokyo-night/colors.toml` (the definitive source for what a Tokyo Night session would apply). The shell.json `color.qml` hardcoded defaults are listed separately as the _currently running_ colors.

### Currently Running Shell Colors (Color.qml hardcoded defaults)

> These are what the Omarchy shell actually displays right now (no theme applied).

| Role | Hex | Source |
|---|---|---|
| foreground | `#cacccc` | `/usr/share/omarchy/shell/Commons/Color.qml` |
| background | `#101315` | `/usr/share/omarchy/shell/Commons/Color.qml` |
| accent | `#cacccc` | `/usr/share/omarchy/shell/Commons/Color.qml` |
| urgent | `#a55555` | `/usr/share/omarchy/shell/Commons/Color.qml` |
| muted | `#707880` | `/usr/share/omarchy/shell/Commons/Color.qml` |

### Tokyo Night Theme Palette

> From `/usr/share/omarchy/themes/tokyo-night/colors.toml`

| Role | Hex |
|---|---|
| `mode` | `dark` |
| `accent` | `#7aa2f7` |
| `selection` | `#292e42` |
| `muted` | `#414868` |
| `background` | `#1a1b26` |
| `dark_background` | `#13141c` |
| `darker_background` | `#0e0e14` |
| `lighter_background` | `#24283b` |
| `foreground` | `#a9b1d6` |
| `dark_foreground` | `#565f89` |
| `light_foreground` | `#b4bee6` |
| `bright_foreground` | `#c0caf5` |
| `red` | `#f7768e` |
| `yellow` | `#e0af68` |
| `orange` | `#eb927b` |
| `green` | `#9ece6a` |
| `cyan` | `#449dab` |
| `blue` | `#7aa2f7` |
| `magenta` | `#ad8ee6` |
| `brown` | `#75493d` |
| `bright_red` | `#ff7a93` |
| `bright_yellow` | `#ff9e64` |
| `bright_green` | `#b9f27c` |
| `bright_cyan` | `#0db9d7` |
| `bright_blue` | `#7da6ff` |
| `bright_magenta` | `#bb9af7` |

**Terminal color mapping** (from `/usr/share/omarchy/default/themed/ghostty.conf.tpl`):

| Palette index | Role | Hex |
|---|---|---|
| 0 (black) | background | `#1a1b26` |
| 1 (red) | red | `#f7768e` |
| 2 (green) | green | `#9ece6a` |
| 3 (yellow) | yellow | `#e0af68` |
| 4 (blue) | blue | `#7aa2f7` |
| 5 (magenta) | magenta | `#ad8ee6` |
| 6 (cyan) | cyan | `#449dab` |
| 7 (white) | foreground | `#a9b1d6` |
| 8 (bright black) | muted | `#414868` |
| 9 (bright red) | bright_red | `#ff7a93` |
| 10 (bright green) | bright_green | `#b9f27c` |
| 11 (bright yellow) | bright_yellow | `#ff9e64` |
| 12 (bright blue) | bright_blue | `#7da6ff` |
| 13 (bright magenta) | bright_magenta | `#bb9af7` |
| 14 (bright cyan) | bright_cyan | `#0db9d7` |
| 15 (bright white) | bright_foreground | `#c0caf5` |

---

## 3. Compositor Look (Hyprland)

All values come from the **effective merged config**: Omarchy default (`/usr/share/omarchy/default/hypr/looknfeel.lua`) overridden by user looknfeel (`~/.config/hypr/looknfeel.lua`).

### General

| Setting | Default value | User override | Effective value | Source |
|---|---|---|---|---|
| `gaps_in` | `5` | `2` | **`2`** | `/usr/share/omarchy/default/hypr/looknfeel.lua`; `~/.config/hypr/looknfeel.lua` |
| `gaps_out` | `10` | `1` | **`1`** | same |
| `border_size` | `2` | (none) | **`2`** | `/usr/share/omarchy/default/hypr/looknfeel.lua` |
| active border | `rgba(33ccffee)` → `rgba(00ff99ee)` 45° gradient | (none) | **gradient: `rgba(33ccffee)` to `rgba(00ff99ee)` at 45°** | `/usr/share/omarchy/default/hypr/looknfeel.lua` |
| inactive border | `rgba(595959aa)` | (none) | **`rgba(595959aa)`** | same |
| `resize_on_border` | `true` | (none) | `true` | same |
| `extend_border_grab_area` | `8` | (none) | `8` | same |
| `hover_icon_on_border` | `true` | (none) | `true` | same |
| `allow_tearing` | `false` | (none) | `false` | same |
| `layout` | `dwindle` | (none) | **`dwindle`** | same |

> **Note:** When a Tokyo Night theme is applied, the active border becomes `accent` (`#7aa2f7`) solid — the template `/usr/share/omarchy/default/themed/hyprland.lua.tpl` replaces the gradient with the theme palette unless a `hyprland_active_border` key is set in `colors.toml`. Tokyo Night has no such key, so it falls back to `accent`.

### Decoration

| Setting | Value | Source |
|---|---|---|
| `rounding` | `0` | `/usr/share/omarchy/default/hypr/looknfeel.lua` |
| `shadow.enabled` | `false` | same |
| `blur.enabled` | `false` | same |
| `dim_inactive` | not set (disabled) | same |

### Animations

Defined in `/usr/share/omarchy/default/hypr/looknfeel.lua`:

**Bezier curves:**

| Curve | Type | Points |
|---|---|---|
| `easeOutQuint` | bezier | `{0.23, 1}, {0.32, 1}` |
| `easeInOutCubic` | bezier | `{0.65, 0.05}, {0.36, 1}` |
| `linear` | bezier | `{0, 0}, {1, 1}` |
| `almostLinear` | bezier | `{0.5, 0.5}, {0.75, 1.0}` |
| `quick` | bezier | `{0.15, 0}, {0.1, 1}` |

**Animation settings:**

| Animation leaf | Enabled | Speed | Bezier | Style |
|---|---|---|---|---|
| `global` | true | 10 | default | — |
| `border` | true | 5.39 | easeOutQuint | — |
| `windows` | true | 3.79 | easeOutQuint | — |
| `windowsIn` | true | 4.1 | easeOutQuint | `popin 87%` |
| `windowsOut` | true | 1.49 | linear | `popin 87%` |
| `fadeIn` | true | 1.73 | almostLinear | — |
| `fadeOut` | true | 1.46 | almostLinear | — |
| `fade` | true | 3.03 | quick | — |
| `fadeSwitch` | **false** | — | — | — |
| `layers` | true | 3.81 | easeOutQuint | — |
| `layersIn` | true | 4.0 | easeOutQuint | `fade` |
| `layersOut` | true | 1.5 | linear | `fade` |
| `fadeLayersIn` | true | 1.79 | almostLinear | — |
| `fadeLayersOut` | true | 1.39 | almostLinear | — |
| `workspaces` | **false** | — | — | — |

### Layout (Dwindle)

| Setting | Value | Source |
|---|---|---|
| `preserve_split` | `true` | `/usr/share/omarchy/default/hypr/looknfeel.lua` |
| `force_split` | `2` | same |

### Misc

| Setting | Value | Source |
|---|---|---|
| `disable_hyprland_logo` | `true` | `/usr/share/omarchy/default/hypr/looknfeel.lua` |
| `disable_splash_rendering` | `true` | same |
| `background_color` | `rgb(000000)` | same |
| `focus_on_activate` | `true` | same |
| `initial_workspace_tracking` | `0` | same |
| `allow_session_lock_restore` | `true` | same |

### Cursor

| Setting | Value | Source |
|---|---|---|
| `XCURSOR_SIZE` | `24` | `/usr/share/omarchy/default/hypr/envs.lua` |
| `HYPRCURSOR_SIZE` | `24` | same |
| `hide_on_key_press` | `true` | `/usr/share/omarchy/default/hypr/looknfeel.lua` |
| `warp_on_change_workspace` | `1` | same |
| cursor theme | GSettings: `default` | `gsettings get org.gnome.desktop.interface cursor-theme` |

### Groupbar

| Setting | Value | Source |
|---|---|---|
| `font_size` | `12` | `/usr/share/omarchy/default/hypr/looknfeel.lua` |
| `font_family` | `monospace` | same |
| `font_weight_active` | `ultraheavy` | same |
| `font_weight_inactive` | `normal` | same |
| `indicator_height` | `1` | same |
| `indicator_gap` | `5` | same |
| `height` | `22` | same |
| `gaps_in` | `5` | same |
| `text_color` | `rgb(ffffff)` | same |
| `text_color_inactive` | `rgba(ffffff90)` | same |
| `col.active` | `rgba(00000040)` | same |
| `col.inactive` | `rgba(00000020)` | same |
| `gradients` | `true` | same |
| `gradient_rounding` | `0` | same |

---

## 4. Fonts

| Role | Font | Size | Where set |
|---|---|---|---|
| Monospace (terminal, bar, groupbar) | **VictorMono Nerd Font** | — | `~/.config/fontconfig/fonts.conf` (fontconfig alias `monospace` → `VictorMono Nerd Font`) |
| Terminal font size | `12` pt | — | `~/.config/ghostty/config` |
| Bar font base size | `16` px (user override of default `12`) | — | `~/.config/omarchy/shell.toml` |
| UI font (GTK) | `Adwaita Sans 11` | 11 | `gsettings` |
| Monospace (GTK) | `Adwaita Mono 11` | 11 | `gsettings` |
| Groupbar font | `monospace` (resolves to VictorMono NF) | 12 | `/usr/share/omarchy/default/hypr/looknfeel.lua` |
| MPV subtitle font | `JetBrainsMono Nerd Font` | 44 | `~/.config/mpv/mpv.conf` |
| MPV OSD font | `JetBrainsMono Nerd Font` | 36 | `~/.config/mpv/mpv.conf` |

**Font packages:** `ttf-victor-mono-nerd` (VictorMono NF), `ttf-jetbrains-mono-nerd` (JetBrains Mono NF), `adwaita-fonts` (Adwaita Sans/Mono).

---

## 5. Wallpapers

| Theme | Files | Path | Notes |
|---|---|---|---|
| Tokyo Night (system) | `0-liftoff.webp`, `1-winding-road.webp`, `2-quattro.webp`, `3-swirl-buck.webp`, `4-sunset-lake.webp`, `5-omakub.webp`, `6-oma-cityscape.jpg`, `7-oma.webp`, `omarchy.webp` | `/usr/share/omarchy/themes/tokyo-night/backgrounds/` | Shipped theme assets; no personal content visible in filenames |
| User custom (tokyo-night) | `miles-morales-watcher-im.jpg`, `tanjiro-nezuko.jpg` | `~/.config/omarchy/backgrounds/tokyo-night/` | Personal content — **not copying** |

The system Tokyo Night backgrounds under `/usr/share/omarchy/themes/tokyo-night/backgrounds/` appear to be shipped assets (webp/jpg without personal names). Screenshots would confirm. Actual copying awaits approval in the port plan.

---

## 6. Bar Layout and Look

**Source:** `~/.config/omarchy/shell.json` (layout), `/usr/share/omarchy/default/themed/shell.toml.tpl` (dimensions and colors), `/usr/share/omarchy/shell/plugins/bar/Bar.qml` (rendering), `~/.config/omarchy/shell.toml` (font override).

**Position:** top  
**Transparency:** false (opaque)

### Bar Layout (left → center → right)

| Section | Widgets (in order) |
|---|---|
| Left | `omarchy.menu`, `omarchy.workspaces` |
| Center-begin | `omarchy.indicators` |
| Center | `omarchy.clock` (format: `ddd d MMM h:mm AP`; alt: `d MMMM 'W'ww yyyy`) |
| Center-end | `omarchy.elsewhen`, `omarchy.weather`, `omarchy.system-update` |
| Right | `omarchy.tray`, `omarchy.keyboard-layout`, `omarchy.bluetooth`, `omarchy.network`, `omarchy.audio`, `omarchy.monitor`, `omarchy.power` (with percentage) |

### Bar Dimensions and Colors

| Property | Value | Source |
|---|---|---|
| Height (`size-horizontal`) | 26 px at base-size 12; with `scale-with-font = true` → ~**35 px** at user's base-size 16 | shell.toml.tpl + `~/.config/omarchy/shell.toml` |
| Font | VictorMono Nerd Font (via fontconfig `monospace` alias) | Style.qml fc-match |
| Background | `background` color (currently `#101315`; Tokyo Night: `#1a1b26`) | Color.qml `bar.background` |
| Background alpha | `1.0` (opaque) | shell.toml.tpl |
| Text color | `foreground` (currently `#cacccc`; Tokyo Night: `#a9b1d6`) | Color.qml `bar.text` |
| Active/alert color | `red` (currently `#a55555`; Tokyo Night: `#f7768e`) | Color.qml `bar.active` |

**Visual description:** A single top bar, opaque, full width. Left side: a menu hamburger/logo button, then workspace pips. Center: clock with day/date/time. Right: system tray, keyboard layout, bluetooth, wifi, audio, brightness, battery (with %). The bar is slim (~35 px at current font size), all glyphs rendered via Nerd Font.

---

## 7. Launcher Look

**Source:** `/usr/share/omarchy/default/themed/shell.toml.tpl` `[launcher]` section

| Property | Template token | Tokyo Night resolved |
|---|---|---|
| Background color | `background` | `#1a1b26` |
| Background alpha | `0.95` (slight translucency) | — |
| Text | `foreground` | `#a9b1d6` |
| Border | `hyprland.active-border-foreground` | `#a9b1d6` (foreground stop of accent color) |
| Border alpha | `1.0` | — |
| Scrim (backdrop) | `background` at `0.5` alpha | `#1a1b26` at 50% |
| Selected row background | `foreground` at `0.08` alpha | — |
| Selected text | `accent` | `#7aa2f7` |
| Selected border | `hyprland.active-border-foreground` at `0.25` | — |

**Position/size/rounding:** TODO — not in config files; need screenshot. No rounding by default (`rounding = 0`).

---

## 8. Notifications Look

**Source:** `/usr/share/omarchy/default/themed/shell.toml.tpl` `[notifications]` section

| Property | Template token | Tokyo Night resolved |
|---|---|---|
| Background | `background` at alpha `1.0` | `#1a1b26` opaque |
| Text | `foreground` | `#a9b1d6` |
| Border | `hyprland.active-border` (accent color) | `#7aa2f7` |
| Border alpha | `1.0` | — |
| Countdown accent | `accent` | `#7aa2f7` |

**Position/timeout/size:** TODO — not in config files; need screenshot.

---

## 9. Lock Screen

**Source:** `/usr/share/omarchy/themes/tokyo-night/shell.lock.toml`, `/usr/share/omarchy/default/themed/shell.toml.tpl` `[lock]` section

Tokyo Night ships a custom `shell.lock.toml` that makes all borders a flat foreground color (not the active-border gradient).

| Property | Value (Tokyo Night) | Source |
|---|---|---|
| Input card background | `background` at `0.8` alpha (`#1a1b26` at 80%) | shell.toml.tpl default |
| Text | `#a9b1d6` | `shell.lock.toml` |
| Placeholder text | `#a9b1d6` | `shell.lock.toml` |
| Border (idle) | `#a9b1d6` | `shell.lock.toml` |
| Border (active/typing) | `#a9b1d6` | `shell.lock.toml` |
| Border (error) | `#a9b1d6` | `shell.lock.toml` |
| Selection tint | `accent` (`#7aa2f7`) at `0.45` alpha | shell.toml.tpl |

**Idle/lock timeouts:**  
- Screensaver: `150 s` → `~/.config/omarchy/shell.json` `idle.screensaver`  
- Lock: `300 s` → `~/.config/omarchy/shell.json` `idle.lock`

---

## 10. Terminal (Ghostty)

**Source:** `~/.config/ghostty/config`

| Setting | Value |
|---|---|
| Emulator | Ghostty (`com.mitchellh.ghostty`) |
| Font family | `VictorMono Nerd Font` |
| Font size | `12` pt |
| Background opacity | `1` (opaque) |
| Window padding X | `0` |
| Window padding Y | `0` |
| Cursor style | `block` |
| Cursor blink | `false` |
| Window theme | `ghostty` |
| `confirm-close-surface` | `false` |
| `resize-overlay` | `never` |
| `gtk-toolbar-style` | `flat` |
| `async-backend` | `epoll` (Hyprland perf fix) |
| `mouse-scroll-multiplier` | `0.95` |
| Colors | Loaded from `~/.local/state/omarchy/current/theme/ghostty.conf` (not present — no theme currently applied) |

**Terminal color palette:** See Tokyo Night palette table in §2 for the 16-color mapping. Applied from template at `/usr/share/omarchy/default/themed/ghostty.conf.tpl` when a theme is set.

---

## 11. Editor / Shell Prompt / CLI Looks

### Neovim

| Setting | Value | Source |
|---|---|---|
| Config location | `~/.config/nvim/` (personal: `require("ghulamazad")`) | `~/.config/nvim/init.lua` |
| Colorscheme | `tokyonight-night` | `~/.config/nvim/lua/ghulamazad/lazy/colors.lua` |
| Plugin | `folke/tokyonight.nvim` via LazyVim | same |
| Omarchy default for TN | `folke/tokyonight.nvim` + `colorscheme = "tokyonight-night"` | `/usr/share/omarchy/themes/tokyo-night/neovim.lua` |

The personal Neovim config matches the Omarchy Tokyo Night recommendation exactly.

### Shell Prompt

**TODO** — No starship config found under `~/.config/starship*`. Screenshots needed.

### btop Theme Template

Tokens come from `/usr/share/omarchy/default/themed/btop.theme.tpl` (resolved against the Tokyo Night palette):

| Token | Maps to | Tokyo Night value |
|---|---|---|
| `main_bg` | `background` | `#1a1b26` |
| `main_fg` | `foreground` | `#a9b1d6` |
| `title` | `foreground` | `#a9b1d6` |
| `hi_fg` (highlight) | `accent` | `#7aa2f7` |
| `selected_bg` | `selection` | `#292e42` |
| `selected_fg` | `accent` | `#7aa2f7` |
| `inactive_fg` | `muted` | `#414868` |
| `graph_text` | `light_foreground` | `#b4bee6` |
| `meter_bg` | `selection` | `#292e42` |
| `proc_misc` | `light_foreground` | `#b4bee6` |

No live btop config directory found (`~/.config/btop/` absent) — Omarchy generates the theme file on each theme switch.

---

## 12. GTK / Qt / Icon / Cursor Themes

**Source:** `gsettings` queries and Tokyo Night `icons.theme`

| Setting | Value | Source |
|---|---|---|
| GTK theme | `Adwaita-dark` | `gsettings get org.gnome.desktop.interface gtk-theme` |
| Icon theme (GSettings) | `Yaru-magenta` | `gsettings get org.gnome.desktop.interface icon-theme` |
| Icon theme (Tokyo Night theme file) | `Yaru-purple` | `/usr/share/omarchy/themes/tokyo-night/icons.theme` |
| Cursor theme | `default` | `gsettings get org.gnome.desktop.interface cursor-theme` |
| Cursor size | `24` | `gsettings get org.gnome.desktop.interface cursor-size` |
| UI font | `Adwaita Sans 11` | `gsettings get org.gnome.desktop.interface font-name` |
| Monospace font | `Adwaita Mono 11` | `gsettings get org.gnome.desktop.interface monospace-font-name` |
| Qt platform theme | `gtk3` | `QT_QPA_PLATFORMTHEME=gtk3` in `/usr/share/omarchy/default/hypr/envs.lua` |

---

## 13. Keybindings

All bindings are from `/usr/share/omarchy/default/hypr/bindings/`. User `~/.config/hypr/bindings.lua` is empty (all commented examples). Bindings with `omarchy-*` commands depend on Omarchy infrastructure and cannot be ported directly.

**Key:** ✅ keep · 🔄 adapt · ⬇️ optional addition · ❌ drop (conflicts, Omarchy-only, or AI)

### Apps / Launch

| Chord | Action | Decision |
|---|---|---|
| `Super + Return` | Terminal | ✅ keep |
| `Super + Shift + Return` | Browser | 🔄 adapt (use your browser) |
| `Super + Shift + F` | File manager (Nautilus) | ✅ keep |
| `Super + Alt + Shift + F` | File manager (cwd) | 🔄 adapt |
| `Super + Shift + B` | Browser (alias) | 🔄 adapt |
| `Super + Shift + N` | Editor | ✅ keep (nvim) |
| `Super + Shift + M` | Music (Spotify) | ❌ drop (not installed) |
| `Super + Shift + A` | ChatGPT webapp | 🚫 drop (AI) |
| `Super + Shift + Alt + A` | Grok webapp | 🚫 drop (AI) |
| `Super + Shift + C` | Calendar (web) | ⬇️ optional |
| `Super + Shift + E` | Email (web) | ⬇️ optional |
| `Super + Shift + Y` | YouTube (web) | ⬇️ optional |
| `Super + Shift + G` | Signal | ⬇️ optional |
| `Super + Shift + O` | Obsidian | ⬇️ optional |
| `Super + Shift + W` | Omawrite | ❌ drop (Omarchy app) |
| `Super + Shift + Slash` | 1Password | ⬇️ optional |

### Windows / Tiling

| Chord | Action | Decision |
|---|---|---|
| `Super + W` / `Super + Q` | Close window | ✅ keep |
| `Super + J` | Toggle split | ✅ keep |
| `Super + P` | Pseudo window | ✅ keep |
| `Super + T` | Toggle float/tile | ✅ keep |
| `Super + F` | Fullscreen | ✅ keep |
| `Super + Alt + F` | Maximize | ✅ keep |
| `Super + Left/Right/Up/Down` | Focus direction | ✅ keep |
| `Super + Shift + Left/Right/Up/Down` | Swap window | ✅ keep |
| `Super + 1–0` | Switch workspace 1–10 | ✅ keep |
| `Super + Shift + 1–0` | Move window to workspace | ✅ keep |
| `Super + Tab` / `Super + Shift + Tab` | Next/prev workspace | ✅ keep |
| `Super + Ctrl + Tab` | Former workspace | ✅ keep |
| `Super + S` | Toggle scratchpad | ✅ keep |
| `Super + Alt + S` | Move window to scratchpad | ✅ keep |
| `Super + Grave` | Toggle Quake console | 🔄 adapt (if you have a quake-console setup) |
| `Alt + Tab` | Focus next window | ✅ keep |
| `Super + G` | Toggle group | ✅ keep |
| `Super + Alt + G` | Move out of group | ✅ keep |
| `Super + Alt + Left/Right/Up/Down` | Move window into group | ✅ keep |
| `Super + mouse:272` | Move window (drag) | ✅ keep |
| `Super + mouse:273` | Resize window (drag) | ✅ keep |
| `Super + = (code:20)` / `Super + - (code:21)` | Resize window | ✅ keep |
| `Super + mouse_down/up` | Scroll workspace | ✅ keep |
| `Super + L` | Cycle workspace layout | 🔄 adapt (Omarchy command) |
| `Super + M` | Minimize to dock | ❌ drop (Omarchy dock) |
| `Super + O` | Pop window (float & pin) | 🔄 adapt (Omarchy command) |

### System / Utilities

| Chord | Action | Decision |
|---|---|---|
| `Super + Space` | Omarchy root menu | 🔄 adapt → your launcher (`Super + Space` already set) |
| `Super + Ctrl + L` | Lock system | ✅ keep |
| `Super + Escape` | System menu | 🔄 adapt → power menu |
| `Super + Backspace` | Toggle window transparency | ✅ keep |
| `Super + Shift + Backspace` | Toggle window gaps | ✅ keep |
| `Super + Ctrl + Z` | Zoom in | ✅ keep |
| `Super + Ctrl + Alt + Z` | Reset zoom | ✅ keep |
| `Super + comma` | Dismiss/invoke last notification | ✅ keep |
| `Super + Shift + comma` | Dismiss all notifications | ✅ keep |
| `Super + Ctrl + comma` | Keyboard-control notifications | ✅ keep |
| `Super + Ctrl + B` | Bluetooth panel | ✅ keep |
| `Super + Ctrl + A` | Audio panel | ✅ keep |
| `Super + Ctrl + D` | Display panel | ✅ keep |
| `Super + Ctrl + N` | Network panel | ✅ keep |
| `Super + Ctrl + P` | Power panel | ✅ keep |
| `Super + Shift + T` | btop (activity) | ✅ keep |
| `Super + Shift + Space` | Toggle bar | ✅ keep |
| `Super + Ctrl + Space` | Background switcher | 🔄 adapt |
| `Super + Ctrl + T` | Theme menu | 🔄 adapt |
| `Super + Shift + Ctrl + A` | AI Agent picker | 🚫 drop (AI) |
| `Print` | Screenshot | ✅ keep |
| `Alt + Print` | Screen recording | ✅ keep |
| `Super + Print` | Color picker | ✅ keep |
| `Super + Ctrl + Print` | OCR screenshot | ⬇️ optional |
| `Super + Ctrl + S` | Share menu | ❌ drop (Omarchy-only) |

### Media

| Chord | Action | Decision |
|---|---|---|
| `XF86AudioRaiseVolume` | Volume up | ✅ keep |
| `XF86AudioLowerVolume` | Volume down | ✅ keep |
| `XF86AudioMute` | Mute | ✅ keep |
| `XF86AudioMicMute` | Mute microphone | ✅ keep |
| `XF86MonBrightnessUp/Down` | Brightness | ✅ keep |
| `XF86AudioNext/Prev/Play/Pause/Eject` | Media controls | ✅ keep |
| `Alt + XF86AudioRaiseVolume/LowerVolume` | Precise volume | ✅ keep |
| `Alt + XF86MonBrightnessUp/Down` | Precise brightness | ✅ keep |
| `Shift + XF86AudioMute` | Switch audio output | ✅ keep |

---

## 14. mpv

**Source:** `~/.config/mpv/mpv.conf`, `~/.config/mpv/input.conf`  
No `scripts/` or `script-opts/` directories exist.

### mpv.conf

| Section | Key settings |
|---|---|
| Video | `vo=gpu-next`, `gpu-api=vulkan`, `hwdec=vaapi`, `hwdec-codecs=all` |
| Scaling | `scale=ewa_lanczos`, `cscale=ewa_lanczos`, `dscale=mitchell`, `correct-downscaling=yes`, `sigmoid-upscaling=yes` |
| HDR | `target-colorspace-hint=yes` |
| Audio | `audio-pitch-correction=yes`, `volume-max=150`, `af=acompressor` |
| Subtitles | `sub-auto=fuzzy`, `sub-font=JetBrainsMono Nerd Font`, `sub-font-size=44`, white text (`#FFFFFFFF`), dark border+shadow |
| OSD | `osd-font=JetBrainsMono Nerd Font`, `osd-font-size=36`, thin bar (`osd-bar-h=2`) pinned to bottom, 2 s duration |
| Window | `keep-open=yes`, `save-position-on-quit=yes`, `geometry=60%`, `autofit-larger=100%x90%`, `border=no`, `cursor-autohide=1000` |
| Screenshots | PNG, `~/Pictures/mpv/`, template `%F_%wH%wM%wS` |
| Cache | `demuxer-max-bytes=400MiB`, `demuxer-max-back-bytes=100MiB` |

### input.conf

| Key | Action |
|---|---|
| `Space` | toggle pause |
| `s` | stop |
| `Ctrl+q` | quit |
| `f` | toggle fullscreen |
| `Esc` | exit fullscreen |
| `Up/Down` | volume ±5 |
| `m` | toggle mute |
| `Wheel up/down` | volume ±2 |
| `Right/Left` | seek ±10 s |
| `Shift+Right/Left` | seek ±60 s |
| `Alt+Right/Left` | seek ±3 s |
| `n / p` / `> / <` | playlist next/prev |
| `v` | cycle subtitle tracks |
| `J / K` | subtitle track next/prev |
| `g / h` | subtitle delay ±0.1 s |
| `a / A` | audio track next/prev |
| `k / l` | audio delay ±0.1 s |
| `. / ,` | frame step fwd/back |
| `Shift+s` | screenshot (with subs) |
| `i` | stats toggle |
| `[ / ]` | speed ±0.1 |
| `+ / -` | speed ±0.5 |
| `=` | reset speed to 1.0 |
| `z / x` | zoom ±0.1 |
| `Ctrl+arrows` | pan video |
| `r` | rotate (cycle 90°) |
| `Ctrl+v` | open clipboard path in mpv |
| `MBTN_LEFT` | toggle pause |
| `MBTN_LEFT_DBL` | toggle fullscreen |

---

## 15. AI-Related Items Found (NOT porting)

| Item | Location | Disposition |
|---|---|---|
| `Super + Shift + A` → ChatGPT webapp | `/usr/share/omarchy/default/hypr/bindings/applications.lua` | **DROP** |
| `Super + Shift + Alt + A` → Grok webapp | same | **DROP** |
| `Super + Shift + Ctrl + A` → `omarchy-agent --pick` (AI agent) | `/usr/share/omarchy/default/hypr/bindings/utilities.lua` | **DROP** |
| Omarchy AI agent plugin (`/usr/share/omarchy/shell/plugins/agents/`) | Omarchy shell | Not porting |

---

## 16. Screenshots Requested

As specified in the brief, please provide screenshots of the **Omarchy machine** as the reference for Step 4 comparison:

1. **Empty desktop with the bar** (no windows open)
2. **Two terminals tiled side by side**
3. **Launcher open** (`Super + Space`)
4. **A notification popup** (trigger one, e.g. via `notify-send`)
5. **Lock screen** (`Super + Ctrl + L`)
6. **File manager** (Nautilus open)
7. **Neovim** open with a source file

You can use `Print` or `omarchy-capture-screenshot` and share the resulting images.

---

## 17. Known Unknowns and Open Questions

| Item | Status | Notes |
|---|---|---|
| Active theme | **Ambiguous** — Tokyo Night assumed from evidence | Confirm: is Tokyo Night the intended theme to port? |
| Lock screen wallpaper image | **TODO** | Not found in config; hyprlock wallpaper source unknown without running system |
| Launcher position/size/corner radius | **TODO** | Need screenshot |
| Notification position/timeout/size | **TODO** | Need screenshot |
| Shell prompt appearance | **TODO** | No starship config found in `~/.config/` |
| Monitor scale | `1` (both GDK and Hyprland) | `~/.config/hypr/monitors.lua` |
| Idle screensaver appearance | **TODO** | shell.json sets timeout but not what it shows |
| btop live theme file | Not present | Omarchy generates it on theme switch; template documented above |
| mpv scripts/script-opts | None | No `~/.config/mpv/scripts/` or `script-opts/` dir |
