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
        c.bg = "#0c1618"
        c.bg_dark = "#081012"
        c.bg_float = "#101c1e"
        c.bg_highlight = "#152325"
        c.bg_popup = "#101c1e"
        c.bg_search = "#17393d"
        c.bg_sidebar = "#101c1e"
        c.bg_statusline = "#152325"
        c.bg_visual = "#17393d"
        c.border = "#2a3f42"
        c.border_highlight = "#35d0c0"
        c.fg = "#c2d8d8"
        c.fg_dark = "#a0b8b8"
        c.fg_float = "#c2d8d8"
        c.fg_gutter = "#4d6467"
        c.fg_sidebar = "#c2d8d8"
        c.blue = "#35d0c0"
        c.blue0 = "#3fc4b7"
        c.blue1 = "#6cc48e"
        c.cyan = "#7db8d8"
        c.green = "#6cc48e"
        c.green1 = "#8adaa8"
        c.green2 = "#8adaa8"
        c.magenta = "#9d8ccc"
        c.magenta2 = "#b5a7dd"
        c.orange = "#d1b366"
        c.purple = "#9d8ccc"
        c.red = "#e0736e"
        c.red1 = "#ec8f88"
        c.teal = "#3fc4b7"
        c.yellow = "#d1b366"
      end,
      on_highlights = function(hl, c)
        -- Markdown heading banners matching the screenshot
        hl["@markup.heading.1"] = { bg = "#35d0c0", fg = "#0c1618", bold = true }
        hl["@markup.heading.2"] = { bg = "#17393d", fg = "#6cc48e", bold = true }
        hl["@markup.heading.3"] = { bg = "#203b31", fg = "#8adaa8", bold = true }
        hl["@markup.raw.inline"] = { bg = "#17393d", fg = "#8adaa8" }
        hl["@markup.raw.block"] = { bg = "#101c1e" }
        hl["@markup.link"] = { fg = "#35d0c0", underline = true }

        -- Statusline matching the screenshot (sage green normal mode + dark teal bar)
        hl.StatusLine = { bg = "#152325", fg = "#c2d8d8" }
        hl.StatusLineNC = { bg = "#180f20", fg = "#4d6467" }
        hl.WinSeparator = { fg = "#2a3f42", bg = "NONE" }
        hl.NormalFloat = { bg = "#101c1e", fg = "#c2d8d8" }
        hl.FloatBorder = { bg = "#101c1e", fg = "#2a3f42" }
        hl.LineNr = { fg = "#4d6467" }
        hl.CursorLineNr = { fg = "#35d0c0", bold = true }
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
