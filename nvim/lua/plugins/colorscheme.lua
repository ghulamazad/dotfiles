-- Obsidian Plum & Sage Jade colorscheme (matching reference screenshot).

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
        c.bg = "#150f1d"
        c.bg_dark = "#100a18"
        c.bg_float = "#1a1224"
        c.bg_highlight = "#281e36"
        c.bg_popup = "#1a1224"
        c.bg_search = "#295d50"
        c.bg_sidebar = "#140e1c"
        c.bg_statusline = "#2d3739"
        c.bg_visual = "#295d50"
        c.border = "#31343d"
        c.border_highlight = "#7db6a7"
        c.fg = "#c6bdce"
        c.fg_dark = "#8f8498"
        c.fg_float = "#c6bdce"
        c.fg_gutter = "#4f4657"
        c.fg_sidebar = "#c6bdce"
        c.blue = "#7db6a7"
        c.blue0 = "#78b0a2"
        c.blue1 = "#81beae"
        c.cyan = "#8bcbb1"
        c.green = "#81beae"
        c.green1 = "#9fbc79"
        c.green2 = "#a7dfc5"
        c.magenta = "#b7a1c8"
        c.magenta2 = "#cfbce0"
        c.orange = "#d7ba7d"
        c.purple = "#b5acbd"
        c.red = "#d88d91"
        c.red1 = "#e6a6aa"
        c.teal = "#78b0a2"
        c.yellow = "#d7ba7d"
      end,
      on_highlights = function(hl, c)
        -- Markdown heading banners matching the screenshot
        hl["@markup.heading.1"] = { bg = "#7db6a7", fg = "#150f1d", bold = true }
        hl["@markup.heading.2"] = { bg = "#2b5147", fg = "#81beae", bold = true }
        hl["@markup.heading.3"] = { bg = "#203b31", fg = "#a7dfc5", bold = true }
        hl["@markup.raw.inline"] = { bg = "#295d50", fg = "#a7dfc5" }
        hl["@markup.raw.block"] = { bg = "#1a1224" }
        hl["@markup.link"] = { fg = "#7db6a7", underline = true }

        -- Statusline matching the screenshot (sage green normal mode + dark teal bar)
        hl.StatusLine = { bg = "#2d3739", fg = "#c6bdce" }
        hl.StatusLineNC = { bg = "#180f20", fg = "#4f4657" }
        hl.WinSeparator = { fg = "#31343d", bg = "NONE" }
        hl.NormalFloat = { bg = "#1a1224", fg = "#c6bdce" }
        hl.FloatBorder = { bg = "#1a1224", fg = "#31343d" }
        hl.LineNr = { fg = "#4f4657" }
        hl.CursorLineNr = { fg = "#7db6a7", bold = true }
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
