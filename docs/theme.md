# Theme: Petrol Lagoon

Dark teal palette. Source: the "Petrol Lagoon" theme from the Rex terminal
(colors supplied by the owner from the terminal theme file). Previous theme:
Obsidian Plum & Sage Jade (still in git history).

## Base colors (verbatim from the theme)

| Role | Hex |
|---|---|
| background | `#0c1618` |
| foreground | `#c2d8d8` |
| cursor / text on cursor | `#35d0c0` / `#0c1618` |
| selection bg / text | `#17393d` / `#dfeeee` |
| normal: black red green yellow | `#152325` `#e0736e` `#6cc48e` `#d1b366` |
| normal: blue magenta cyan white | `#5b9fc4` `#9d8ccc` `#3fc4b7` `#a0b8b8` |
| bright: black red green yellow | `#4d6467` `#ec8f88` `#8adaa8` `#e2c985` |
| bright: blue magenta cyan white | `#7db8d8` `#b5a7dd` `#66d9cd` `#dfeeee` |

## Derived colors (NOT part of the original theme; chosen to fit it)

| Use | Hex | How |
|---|---|---|
| surface (raised panels) | `#152325` | the theme's normal black |
| borders, dividers | `#2a3f42` | between surface and bright black |
| subtext | `#a0b8b8` | the theme's normal white |
| muted / gutter | `#4d6467` | the theme's bright black |
| accent | `#35d0c0` | the theme's cursor color |
| nvim dark/float/sidebar backgrounds | `#081012`, `#101c1e` | darker/lighter steps of the background |

## Where the colors live (change them together)

`quickshell/themes/Theme.qml`, `ghostty/config`, `hypr/appearance.lua`,
`hypr/hyprlock.conf`, `scripts/wallpaper.sh` (lock fallback), `tmux/tmux.conf`,
`lazygit/config.yml`, `zsh/.zsh/fzf.zsh`, `btop/themes/petrol-lagoon.theme`,
`nvim/lua/ghulamazad/petrol_lagoon.lua`.

## Limits

- Petrol Lagoon is a dark theme. The Quickshell light mode keeps a neutral light set.
- Neovim: tokyodark is removed. `nvim/lua/ghulamazad/petrol_lagoon.lua` is a standalone colourscheme (`nvim/colors/petrol-lagoon.lua`) that defines the groups itself. Groups that only a plugin defines and that are not listed there follow their links to the standard groups.
- Wallpapers in `wallpapers/` were not recolored.
- GTK/Qt apps only get the dark preference, not this palette.
- Not viewed on a live desktop: check contrast on first boot.
