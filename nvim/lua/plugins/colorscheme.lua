-- Tokyo Night Night colorscheme with screenshot-matching overrides.
-- Base palette: /usr/share/omarchy/themes/tokyo-night/colors.toml
-- Visual reference: screenshot showing dark bg, green ##-banner sections,
-- amber # headings, teal links, very dark status bar.

return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      styles = {
        sidebars = "normal",
        floats = "normal",
      },
      on_colors = function(c)
        -- Exact Tokyo Night Night values from colors.toml
        c.bg            = "#1a1b26"
        c.bg_dark       = "#13141c"
        c.bg_float      = "#1a1b26"
        c.bg_highlight  = "#292e42"
        c.bg_popup      = "#1a1b26"
        c.bg_search     = "#3d59a1"
        c.bg_sidebar    = "#1a1b26"
        c.bg_statusline = "#13141c"
        c.bg_visual     = "#292e42"
        c.border        = "#414868"
        c.border_highlight = "#7aa2f7"
        c.fg            = "#a9b1d6"
        c.fg_dark       = "#565f89"
        c.fg_float      = "#a9b1d6"
        c.fg_gutter     = "#3b3d57"
        c.fg_sidebar    = "#a9b1d6"
        c.blue          = "#7aa2f7"
        c.blue0         = "#7da6ff"
        c.blue1         = "#2ac3de"
        c.cyan          = "#449dab"
        c.green         = "#9ece6a"
        c.green1        = "#73daca"
        c.green2        = "#41a6b5"
        c.magenta       = "#ad8ee6"
        c.magenta2      = "#bb9af7"
        c.orange        = "#ff9e64"
        c.purple        = "#9d7cd8"
        c.red           = "#f7768e"
        c.red1          = "#ff7a93"
        c.teal          = "#1abc9c"
        c.yellow        = "#e0af68"
      end,
      on_highlights = function(hl, c)
        -- Markdown heading banners matching the screenshot
        -- # heading: amber text, no background
        hl["@markup.heading.1.marker"] = { fg = "#e0af68", bold = true }
        hl["@markup.heading.1"]        = { fg = "#e0af68", bold = true }
        -- ## heading: full-width dark-green bar + green text (screenshot)
        hl["@markup.heading.2.marker"] = { bg = "#1a2a1a", fg = "#9ece6a", bold = true }
        hl["@markup.heading.2"]        = { bg = "#1a2a1a", fg = "#9ece6a", bold = true }
        -- ### heading: slightly lighter green bar
        hl["@markup.heading.3.marker"] = { bg = "#172217", fg = "#73daca", bold = true }
        hl["@markup.heading.3"]        = { bg = "#172217", fg = "#73daca", bold = true }
        -- Inline code: slight dark tint
        hl["@markup.raw.inline"] = { bg = "#292e42", fg = "#73daca" }
        hl["@markup.raw.block"]  = { bg = "#1a1b26" }
        -- Links: teal underlined (screenshot)
        hl["@markup.link"]       = { fg = "#449dab", underline = true }
        hl["@markup.link.url"]   = { fg = "#449dab", underline = true }

        -- Statusline: very dark bg (screenshot), green mode indicator
        hl.StatusLine   = { bg = "#13141c", fg = "#a9b1d6" }
        hl.StatusLineNC = { bg = "#13141c", fg = "#565f89" }
        -- Window separator: muted border only, no bg
        hl.WinSeparator = { fg = "#414868", bg = "NONE" }
        -- Floats: same dark bg
        hl.NormalFloat  = { bg = "#1a1b26", fg = "#a9b1d6" }
        hl.FloatBorder  = { bg = "#1a1b26", fg = "#414868" }
        -- Line numbers: muted; current line: blue accent
        hl.LineNr       = { fg = "#3b3d57" }
        hl.CursorLineNr = { fg = "#7aa2f7", bold = true }
        -- Diagnostics hint in status bar (amber, matching screenshot)
        hl.DiagnosticWarn = { fg = "#e0af68" }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
